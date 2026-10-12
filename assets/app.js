'use strict';
const SITES = `vseigru.net
roblox.com
rbx.com
rbxcdn.com
yandex.ru/games
yandex.kz/games
yandex.com/games
yandex.by/games
games.yandex.ru
games.yandex.kz
playhop.com
playhop.ru
poki.com
crazygames.com
friv.com
friv4school.com
gamepix.com
1001games.com
kizi.com
y8.com
lagged.com
minigames.com
silvergames.com
kongregate.com
addictinggames.com
armorgames.com
coolmathgames.com
gamedistribution.com
newgrounds.com
itch.io
now.gg
gameflare.com
gamesgames.com
girlsgogames.com
agame.com
games.lol
onlinegames.io
iogames.space
1v1.lol
krunker.io
shellshock.io
slowroads.io
agar.io
slither.io
paper-io.com
diep.io
tbg95.com
unblockedgames66ez.com
unblockedgames76.net
geometrydash.io
blockblast.io
littlealchemy2.com
minecraft.net
minecraftservices.com
mojang.com
steampowered.com
steamcommunity.com
epicgames.com
fortnite.com
ru.sgames.org
sgames.org
multoigri.ru
igroutka.ru
games.pikabu.ru
igru.net
bouncybasketball.com
gamelayer.ru
aif.ru/onlinegames
games.yandex.by
yandex.com.tr/games
igry.ru
onlineminiigry.ru
igryman.ru
online-igry.net
igry-dlya-devochek.ru
igry-na-dvoih.ru
igraem.pro
igrat.online`.split('\n');

const list = document.querySelector('#siteList');
const search = document.querySelector('#siteSearch');
const counter = document.querySelector('#siteCount');
let expanded = false;

function renderSites() {
  const query = search.value.trim().toLocaleLowerCase();
  const matched = SITES.filter(site => site.toLocaleLowerCase().includes(query));
  const shown = (query || expanded) ? matched : matched.slice(0, 12);
  list.replaceChildren();
  const frag = document.createDocumentFragment();
  for (const site of shown) {
    const item = document.createElement('div');
    item.className = 'site-item';
    const dot = document.createElement('span'); dot.className = 'site-icon'; dot.textContent = '↗';
    const name = document.createElement('span'); name.textContent = site;
    const badge = document.createElement('span'); badge.className = 'blocked-label'; badge.textContent = 'В СПИСКЕ';
    item.append(dot, name, badge);
    frag.append(item);
  }
  if (matched.length === 0) {
    const empty = document.createElement('p'); empty.className='empty-sites'; empty.textContent = 'По вашему запросу адресов не найдено'; frag.append(empty);
  }
  if (!query && matched.length > 12) {
    const footer = document.createElement('button');
    footer.type = 'button'; footer.className = 'see-all';
    footer.textContent = expanded ? 'Свернуть список ↑' : `Показать все ${matched.length} адресов ↓`;
    footer.addEventListener('click', () => { expanded = !expanded; renderSites(); });
    frag.append(footer);
  }
  list.append(frag);
  counter.textContent = `${matched.length} из ${SITES.length}`;
}
search?.addEventListener('input', renderSites);
renderSites();

const menuButton = document.getElementById('menuToggle');
const mobileNav = document.getElementById('mobileNav');
menuButton?.addEventListener('click', () => {
  const open = menuButton.getAttribute('aria-expanded') !== 'true';
  menuButton.setAttribute('aria-expanded', String(open));
  mobileNav.hidden = !open;
});
mobileNav?.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
  mobileNav.hidden = true;
  menuButton.setAttribute('aria-expanded', 'false');
}));
