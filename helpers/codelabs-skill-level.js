'use strict';

// Codelabs difficulty set in the tags metadata of the codelab MD file
const CODELABS_SKILL_LEVELS = {
    "introduction": 0,
    "beginner": 1,
    "intermediate": 2,
    "advanced": 3
};

// Sort codelabs by the difficulty set in the tags metadata of the codelab MD file
exports.SortByLevel = (a, b) => {
    // If tag metadata not provided or empty, 
    // continue sort and codelab will appear first in category
    if (a.tags.length == 0) return 1;

    if (CODELABS_SKILL_LEVELS[a.tags[0]] < CODELABS_SKILL_LEVELS[b.tags[0]]) return -1;

    if (CODELABS_SKILL_LEVELS[a.tags[0]] > CODELABS_SKILL_LEVELS[b.tags[0]]) return 1;

    return 0;
};