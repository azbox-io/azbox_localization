import 'package:azbox/src/widgets/language.dart';

class Languages {
  static Language get bulgarian => Language('bg_BG', 'Bulgarian');
  static Language get chineseSimplified =>
      Language('zh_Hans', 'Chinese (Simplified)');
  static Language get czech => Language('cs_CZ', 'Czech');
  static Language get danish => Language('da_DK', 'Danish');
  static Language get dutch => Language('nl_NL', 'Dutch');
  static Language get english => Language('en_US', 'English');
  static Language get englishgb => Language('en_GB', 'English GB');
  static Language get estonian => Language('et_EE', 'Estonian');
  static Language get finnish => Language('fi_FI', 'Finnish');
  static Language get french => Language('fr_FR', 'French');
  static Language get german => Language('de_DE', 'German');
  static Language get greek => Language('el_GR', 'Greek');
  static Language get hungarian => Language('hu_HU', 'Hungarian');
  static Language get indonesian => Language('id_ID', 'Indonesian');
  static Language get italian => Language('it_IT', 'Italian');
  static Language get japanese => Language('ja_JP', 'Japanese');
  static Language get korean => Language('ko_KR', 'Korean');
  static Language get latvian => Language('lv_LV', 'Latvian');
  static Language get lithuanian => Language('lt_LT', 'Lithuanian');
  static Language get norwegian => Language('nb_NO', 'Norwegian');
  static Language get polish => Language('pl_PL', 'Polish');
  static Language get portuguese => Language('pt_PT', 'Portuguese');
  static Language get portuguesebr => Language('pt_BR', 'Portuguese BR');
  static Language get romanian => Language('ro_RO', 'Romanian');
  static Language get russian => Language('ru_RU', 'Russian');
  static Language get slovak => Language('sk_SK', 'Slovak');
  static Language get slovenian => Language('sl_SI', 'Slovenian');
  static Language get spanish => Language('es_ES', 'Spanish');
  static Language get swedish => Language('sv_SE', 'Swedish');
  static Language get turkish => Language('tr_TR', 'Turkish');
  static Language get ukrainian => Language('uk_UA', 'Ukrainian');

  static List<Language> defaultLanguages = [
    Languages.bulgarian,
    Languages.englishgb,
    Languages.chineseSimplified,
    Languages.czech,
    Languages.danish,
    Languages.dutch,
    Languages.english,
    Languages.estonian,
    Languages.finnish,
    Languages.french,
    Languages.german,
    Languages.greek,
    Languages.hungarian,
    Languages.indonesian,
    Languages.italian,
    Languages.japanese,
    Languages.korean,
    Languages.latvian,
    Languages.lithuanian,
    Languages.norwegian,
    Languages.polish,
    Languages.portuguese,
    Languages.portuguesebr,
    Languages.romanian,
    Languages.russian,
    Languages.slovak,
    Languages.slovenian,
    Languages.spanish,
    Languages.swedish,
    Languages.turkish,
    Languages.ukrainian,
  ];
}