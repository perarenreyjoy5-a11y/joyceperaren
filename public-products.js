import { isSupabaseConfigured, supabase } from './supabase-client.js';

const renderProductCard = (product) => {
    const card = document.createElement('div');
    const photoWrap = document.createElement('div');
    const photoLink = document.createElement('a');
    const photo = product.photos?.[0];
    const heading = document.createElement('h3');
    const headingLink = document.createElement('a');
    const description = document.createElement('p');
    const price = document.createElement('div');
    const detailsLink = document.createElement('a');

    card.className = 'card';
    photoWrap.className = 'product-photo';
    photoLink.href = `product.html?item=${encodeURIComponent(product.slug)}`;
    photoLink.setAttribute('aria-label', `View ${product.name} details`);

    if (photo?.src) {
        const image = document.createElement('img');
        image.src = photo.src;
        image.alt = photo.alt || product.name;
        photoLink.append(image);
    } else {
        const placeholder = document.createElement('span');
        placeholder.className = 'product-photo-placeholder';
        placeholder.textContent = 'Photo coming soon';
        photoLink.append(placeholder);
    }

    photoWrap.append(photoLink);
    headingLink.href = photoLink.href;
    headingLink.textContent = product.name;
    heading.append(headingLink);
    description.textContent = product.description;
    price.className = 'price';
    price.textContent = product.price;
    detailsLink.href = photoLink.href;
    detailsLink.className = 'btn';
    detailsLink.style.padding = '8px 20px';
    detailsLink.style.fontSize = '0.9rem';
    detailsLink.textContent = 'View details';
    card.append(photoWrap, heading, description, price, detailsLink);

    return card;
};

const renderProductPage = (product) => {
    const detail = document.getElementById('product-detail');
    const notFound = document.getElementById('not-found');
    const breadcrumb = document.querySelector('.breadcrumb');
    const photos = Array.isArray(product.photos) ? product.photos : [];
    const mainPhotoWrap = document.querySelector('.main-photo-wrap');
    const mainPhoto = document.getElementById('main-photo');
    const mainPhotoLink = document.getElementById('main-photo-link');
    const gallery = document.getElementById('sample-gallery');

    document.title = `${product.name} | Handcrafted Haven`;
    document.getElementById('breadcrumb-name').textContent = product.name;
    document.getElementById('product-name').textContent = product.name;
    document.getElementById('product-description').textContent = product.description;
    document.getElementById('product-price').textContent = product.price;
    document.getElementById('contact-link').href = `mailto:hello@handcraftedhaven.com?subject=${encodeURIComponent(`Question about ${product.name}`)}`;
    detail.hidden = false;
    breadcrumb.hidden = false;
    notFound.hidden = true;
    mainPhotoWrap.querySelectorAll('.product-photo-placeholder').forEach((placeholder) => placeholder.remove());
    gallery.replaceChildren();

    if (photos.length === 0) {
        mainPhoto.hidden = true;
        mainPhotoLink.hidden = true;
        gallery.hidden = true;
        const placeholder = document.createElement('div');
        placeholder.className = 'product-photo-placeholder';
        placeholder.textContent = 'Photo coming soon';
        mainPhotoWrap.append(placeholder);
        return;
    }

    mainPhoto.hidden = false;
    mainPhotoLink.hidden = false;
    gallery.hidden = false;

    photos.forEach((photo, index) => {
        const thumbnail = document.createElement('button');
        const thumbnailImage = document.createElement('img');
        thumbnail.type = 'button';
        thumbnail.className = 'sample-photo';
        thumbnail.setAttribute('aria-label', `Show sample photo ${index + 1}`);
        thumbnail.setAttribute('aria-pressed', String(index === 0));
        thumbnailImage.src = photo.src;
        thumbnailImage.alt = '';
        thumbnail.append(thumbnailImage);
        thumbnail.addEventListener('click', () => {
            mainPhoto.src = photo.src;
            mainPhoto.alt = photo.alt || product.name;
            mainPhotoLink.href = photo.src;
            mainPhotoLink.setAttribute('aria-label', `Open full-size photo: ${photo.alt || product.name}`);
            gallery.querySelectorAll('.sample-photo').forEach((button) => button.setAttribute('aria-pressed', 'false'));
            thumbnail.setAttribute('aria-pressed', 'true');
        });
        gallery.append(thumbnail);
    });

    mainPhoto.src = photos[0].src;
    mainPhoto.alt = photos[0].alt || product.name;
    mainPhotoLink.href = photos[0].src;
    mainPhotoLink.setAttribute('aria-label', `Open full-size photo: ${photos[0].alt || product.name}`);
};

const loadPublicProducts = async () => {
    const { data, error } = await supabase
        .from('products')
        .select('slug, name, price, description, photos, sort_order, active')
        .eq('active', true)
        .order('sort_order', { ascending: true });

    if (error) {
        console.error('Could not load products from Supabase:', error.message);
        return;
    }

    const grid = document.querySelector('.cards-grid');
    if (grid) {
        grid.replaceChildren(...data.map(renderProductCard));
        return;
    }

    const productId = new URLSearchParams(window.location.search).get('item');
    const product = data.find((item) => item.slug === productId);
    if (product) {
        renderProductPage(product);
        return;
    }

    document.getElementById('product-detail').hidden = true;
    document.querySelector('.breadcrumb').hidden = true;
    document.getElementById('not-found').hidden = false;
};

if (isSupabaseConfigured) {
    loadPublicProducts();
}
