/*
  CONFIGURACION - LA FAMILIA
*/

export const tenant = {
    shortName: 'LA FAMILIA',
    location: 'La Familia',
    franchiseName: 'La Familia',
    address: '',
    city: '',
    domain: 'lafamilia.vercel.app',
    systemName: 'La Familia',
    navLogo: '/seitu_ico.ico',
    mainLogo: '/seitu_ico.ico',
    titleSize: 'text-5xl sm:text-7xl',
    establishedYear: '2026',
    adminEmail: 'lafamiliacafeteriakm36@gmail.com',
    social: {
        instagram: '',
        tiktok: '',
        facebook: '',
        whatsapp: '',
        googleMaps: ''
    },
    get instagramUrl() { return `https://instagram.com/${this.social.instagram}`; },
    get tiktokUrl() { return `https://tiktok.com/@${this.social.tiktok}`; },
    get facebookUrl() { return `https://facebook.com/${this.social.facebook}`; },
    get whatsappUrl() {
        return `https://wa.me/${this.social.whatsapp}?text=${encodeURIComponent(`Hola! Vengo desde la web ${this.franchiseName} y quería hacer una consulta.`)}`;
    }
};
