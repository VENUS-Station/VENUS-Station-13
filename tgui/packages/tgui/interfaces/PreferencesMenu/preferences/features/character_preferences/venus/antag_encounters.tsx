import { type FeatureChoiced } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const antagonist_encounters: FeatureChoiced = {
  name: 'Antagonist Encounters',
  category: 'GAMEPLAY',
  description: 'Sets your preferred stakes for antagonist encounters.',
  component: FeatureDropdownInput,
};
