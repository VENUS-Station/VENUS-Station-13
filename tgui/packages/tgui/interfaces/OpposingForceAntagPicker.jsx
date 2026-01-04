// THIS IS A VENUS UI FILE
import { binaryInsertWith } from 'common/collections';
import {
  Box,
  Divider,
  Flex,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Category } from './PreferencesMenu/antagonists/base';

const requireAntag = require.context(
  './PreferencesMenu/antagonists/antagonists',
  false,
  /.ts$/,
);

const antagsByCategory = new Map();

function binaryInsertAntag(collection, value) {
  return binaryInsertWith(collection, value, (antag) => {
    return `${antag.priority}_${antag.name}`;
  });
}

for (const antagKey of requireAntag.keys()) {
  const antag = requireAntag(antagKey).default;

  if (!antag) {
    continue;
  }

  antagsByCategory.set(
    antag.category,
    binaryInsertAntag(antagsByCategory.get(antag.category) || [], antag),
  );
}

const antagCategories = [
  { name: 'Roundstart', category: Category.Roundstart },
  { name: 'Midround', category: Category.Midround },
  { name: 'Latejoin', category: Category.Latejoin },
];

export const OpposingForceAntagPicker = () => {
  const { act, data } = useBackend();
  const { creator_ckey, owner_antag, can_edit, selected_antag_key } = data;

  return (
    <Window
      title={`Opposing Force: ${creator_ckey} - Antag Selection`}
      width={620}
      height={440}
      theme={owner_antag ? 'syndicate' : 'admin'}
    >
      <Window.Content className="OpposingForceAntagPicker">
        <Section title="Antag Selection">
          <Box color="label" mb={1}>
            Pick an antag to tag your OPFOR request.
          </Box>
          <Box className="OpposingForceAntagPicker__Scroll">
            <Stack vertical>
              {antagCategories.map(({ name, category }) => {
                const antagonists = antagsByCategory.get(category) || [];
                if (!antagonists.length) {
                  return null;
                }

                return (
                  <Stack.Item key={name}>
                    <Box color="label" mb={1}>
                      {name}
                    </Box>
                    <Flex
                      className="OpposingForceAntagPicker__Grid"
                      align="flex-end"
                      wrap
                    >
                      {antagonists.map((antagonist) => (
                        <Flex.Item
                          className="OpposingForceAntagPicker__Item"
                          key={antagonist.key}
                        >
                          <Stack align="center" vertical>
                            <Stack.Item
                              style={{
                                fontWeight: 'bold',
                                marginTop: 'auto',
                                maxWidth: '100px',
                                textAlign: 'center',
                              }}
                            >
                              {antagonist.name}
                            </Stack.Item>
                            <Stack.Item align="center">
                              <Tooltip
                                content={antagonist.description.map(
                                  (text, index) => (
                                    <div
                                      key={`${antagonist.key}-${index}`}
                                    >
                                      {text}
                                      {index !==
                                        antagonist.description.length - 1 && (
                                        <Divider />
                                      )}
                                    </div>
                                  ),
                                )}
                                position="bottom"
                              >
                                <Box
                                  className={classes([
                                    'antagonist-icon-parent',
                                    !can_edit &&
                                      'antagonist-icon-parent--disabled',
                                    selected_antag_key === antagonist.key &&
                                      'antagonist-icon-parent--selected',
                                  ])}
                                  onClick={() => {
                                    if (!can_edit) {
                                      return;
                                    }
                                    act('set_selected_antag', {
                                      antag_key: antagonist.key,
                                      antag_name: antagonist.name,
                                    });
                                  }}
                                >
                                  <Box
                                    className={classes([
                                      'antagonists96x96',
                                      antagonist.key,
                                      'antagonist-icon',
                                    ])}
                                  />
                                </Box>
                              </Tooltip>
                            </Stack.Item>
                          </Stack>
                        </Flex.Item>
                      ))}
                    </Flex>
                  </Stack.Item>
                );
              })}
            </Stack>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
