import { isSupabaseConfigured, supabase } from './supabase-client.js';

const authPanel = document.getElementById('auth-panel');
const adminPanel = document.getElementById('admin-panel');
const loginForm = document.getElementById('login-form');
const loginStatus = document.getElementById('login-status');
const productForm = document.getElementById('product-form');
const formStatus = document.getElementById('form-status');
const listStatus = document.getElementById('list-status');
const productList = document.getElementById('product-list');
const saveButton = document.getElementById('save-product');
const cancelEditButton = document.getElementById('cancel-edit');
let products = [];
let editingProduct = null;

const setStatus = (element, message, isError = false) => {
    element.textContent = message;
    element.classList.toggle('error', isError);
};

const showLogin = (message = '') => {
    authPanel.hidden = false;
    adminPanel.hidden = true;
    setStatus(loginStatus, message, Boolean(message));
};

const renderProducts = () => {
    productList.replaceChildren();

    products.forEach((product) => {
        const row = document.createElement('article');
        const summary = document.createElement('div');
        const name = document.createElement('h3');
        const details = document.createElement('p');
        const actions = document.createElement('div');
        const editButton = document.createElement('button');
        const deleteButton = document.createElement('button');

        row.className = 'product-row';
        name.textContent = product.name;
        details.textContent = `${product.price} · ${product.active ? 'Visible' : 'Hidden'} · ${product.slug}`;
        summary.append(name, details);
        actions.className = 'row-actions';
        editButton.type = 'button';
        editButton.className = 'btn secondary';
        editButton.dataset.action = 'edit';
        editButton.dataset.slug = product.slug;
        editButton.textContent = 'Edit';
        deleteButton.type = 'button';
        deleteButton.className = 'btn danger';
        deleteButton.dataset.action = 'delete';
        deleteButton.dataset.slug = product.slug;
        deleteButton.textContent = 'Delete';
        actions.append(editButton, deleteButton);
        row.append(summary, actions);
        productList.append(row);
    });
};

const loadProducts = async () => {
    setStatus(listStatus, 'Loading products...');
    const { data, error } = await supabase
        .from('products')
        .select('*')
        .order('sort_order', { ascending: true });

    if (error) {
        setStatus(listStatus, `Could not load products: ${error.message}`, true);
        return;
    }

    products = data;
    renderProducts();
    setStatus(listStatus, products.length ? '' : 'No products yet. Add your first product above.');
};

const openAdmin = async (session) => {
    if (!session) {
        showLogin();
        return;
    }

    setStatus(loginStatus, 'Checking admin access...');
    const { data, error } = await supabase.rpc('is_admin');

    if (error) {
        await supabase.auth.signOut();
        showLogin('Could not verify admin access. Check the setup SQL and admin account assignment.');
        return;
    }

    if (!data) {
        await supabase.auth.signOut();
        showLogin('This account does not have admin access.');
        return;
    }

    authPanel.hidden = true;
    adminPanel.hidden = false;
    document.getElementById('signed-in-as').textContent = `Signed in as ${session.user.email}`;
    await loadProducts();
};

const uploadPhotos = async (files, slug) => {
    const photos = [];

    for (const file of files) {
        if (!file.type.startsWith('image/')) {
            throw new Error(`${file.name} is not an image file.`);
        }

        const safeName = file.name.toLowerCase().replace(/[^a-z0-9._-]+/g, '-');
        const path = `${slug}/${crypto.randomUUID()}-${safeName}`;
        const { error } = await supabase.storage
            .from('product-photos')
            .upload(path, file, { cacheControl: '3600', upsert: false });

        if (error) {
            throw new Error(`Could not upload ${file.name}: ${error.message}`);
        }

        const { data } = supabase.storage.from('product-photos').getPublicUrl(path);
        photos.push({ src: data.publicUrl, alt: file.name.replace(/\.[^.]+$/, '').replace(/[-_]+/g, ' ') });
    }

    return photos;
};

const resetProductForm = () => {
    editingProduct = null;
    productForm.reset();
    productForm.elements.slug.readOnly = false;
    productForm.elements.active.checked = true;
    document.getElementById('form-title').textContent = 'Add a product';
    saveButton.textContent = 'Save product';
    cancelEditButton.hidden = true;
    setStatus(formStatus, '');
};

loginForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    const submitButton = loginForm.querySelector('button[type="submit"]');
    submitButton.disabled = true;
    setStatus(loginStatus, 'Signing in...');

    const { error } = await supabase.auth.signInWithPassword({
        email: loginForm.elements.email.value.trim(),
        password: loginForm.elements.password.value
    });

    submitButton.disabled = false;

    if (error) {
        setStatus(loginStatus, error.message, true);
        return;
    }

    const { data } = await supabase.auth.getSession();
    await openAdmin(data.session);
});

productForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    saveButton.disabled = true;
    setStatus(formStatus, 'Saving product...');

    try {
        const slug = productForm.elements.slug.value.trim();
        const files = Array.from(productForm.elements.photos.files);
        const photos = files.length
            ? await uploadPhotos(files, slug)
            : (editingProduct?.photos || []);
        const record = {
            slug,
            name: productForm.elements.name.value.trim(),
            price: productForm.elements.price.value.trim(),
            description: productForm.elements.description.value.trim(),
            photos,
            sort_order: editingProduct?.sort_order ?? products.length,
            active: productForm.elements.active.checked
        };
        const { error } = await supabase.from('products').upsert(record, { onConflict: 'slug' });

        if (error) {
            throw new Error(error.message);
        }

        resetProductForm();
        await loadProducts();
        setStatus(listStatus, 'Product saved. The customer shop will show the update on its next load.');
    } catch (error) {
        setStatus(formStatus, error.message, true);
    } finally {
        saveButton.disabled = false;
    }
});

productList.addEventListener('click', async (event) => {
    const button = event.target.closest('button[data-action]');
    if (!button) return;

    const product = products.find((item) => item.slug === button.dataset.slug);
    if (!product) return;

    if (button.dataset.action === 'edit') {
        editingProduct = product;
        productForm.elements.slug.value = product.slug;
        productForm.elements.slug.readOnly = true;
        productForm.elements.name.value = product.name;
        productForm.elements.price.value = product.price;
        productForm.elements.description.value = product.description;
        productForm.elements.active.checked = product.active;
        document.getElementById('form-title').textContent = `Edit ${product.name}`;
        saveButton.textContent = 'Update product';
        cancelEditButton.hidden = false;
        setStatus(formStatus, '');
        productForm.scrollIntoView({ behavior: 'smooth', block: 'start' });
        return;
    }

    if (button.dataset.action === 'delete' && window.confirm(`Delete ${product.name}? This cannot be undone.`)) {
        button.disabled = true;
        const { error } = await supabase.from('products').delete().eq('slug', product.slug);
        if (error) {
            setStatus(listStatus, `Could not delete product: ${error.message}`, true);
            button.disabled = false;
            return;
        }
        await loadProducts();
        setStatus(listStatus, 'Product deleted.');
    }
});

cancelEditButton.addEventListener('click', resetProductForm);

document.getElementById('sign-out').addEventListener('click', async () => {
    await supabase.auth.signOut();
    showLogin('You have signed out.');
});

if (!isSupabaseConfigured) {
    loginForm.querySelectorAll('input, button').forEach((control) => {
        control.disabled = true;
    });
    setStatus(loginStatus, 'Add your Supabase project URL and publishable key to supabase-config.js, then reload this page.', true);
} else {
    const { data, error } = await supabase.auth.getSession();
    if (error) {
        showLogin(error.message);
    } else if (data.session) {
        await openAdmin(data.session);
    }
}
