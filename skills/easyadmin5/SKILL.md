# EasyAdmin 5 — Quick Reference for Symfony Projects

Version: 5.0.x (March 2026)
Bundle: `easycorp/easyadmin-bundle`

This skill is a verified reference extracted from official documentation.
**Always consult this before writing any EasyAdmin code.**

Sources:
- https://symfony.com/bundles/EasyAdminBundle/current/index.html
- https://github.com/EasyCorp/EasyAdminBundle/blob/5.x/UPGRADE.md

---

## Breaking Changes from EasyAdmin 4

| EasyAdmin 4 | EasyAdmin 5 |
|---|---|
| `MenuItem::linkToCrud(label, icon, Entity::class)` | `MenuItem::linkTo(Controller::class, label, icon)` |
| `FormField::addPanel('Title')` | `FormField::addFieldset('Title')` |
| `->displayAsLink()` | `->renderAsLink()` |
| `->displayAsButton()` | `->renderAsButton()` |
| `->displayAsForm()` | `->renderAsForm()` |
| `{{ ea.property }}` in Twig | `{{ ea().property }}` |
| `AdminContext::getReferrer()` | `getRequest()->headers->get('referer')` |
| `AdminContext::getSignedUrls()` | Removed |
| `getCrudControllers()` | `getAdminControllers()` |
| Pretty URLs optional | Pretty URLs mandatory (only format) |
| `BatchActionDto::referrerUrl` | Removed |
| `MenuItemMatcherInterface::isSelected()/isExpanded()` | Removed; use `markSelectedMenuItem()` |

### Required route config (mandatory in 5.x)

```yaml
# config/routes/easyadmin.yaml
easyadmin:
    resource: .
    type: easyadmin.routes
```

### PHPStan generic type (if using static analysis)

```php
/** @extends AbstractCrudController<Product> */
class ProductCrudController extends AbstractCrudController
```

---

## Dashboard Controller

```php
use EasyCorp\Bundle\EasyAdminBundle\Attribute\AdminDashboard;
use EasyCorp\Bundle\EasyAdminBundle\Config\Dashboard;
use EasyCorp\Bundle\EasyAdminBundle\Config\MenuItem;
use EasyCorp\Bundle\EasyAdminBundle\Config\Assets;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractDashboardController;

#[AdminDashboard(routePath: '/admin', routeName: 'app_admin')]
class DashboardController extends AbstractDashboardController
{
    public function index(): Response
    {
        // Option A: redirect to a CRUD controller
        $url = $this->container->get(AdminUrlGenerator::class)
            ->setController(ProductCrudController::class)
            ->generateUrl();
        return $this->redirect($url);

        // Option B: render custom template
        return $this->render('admin/dashboard.html.twig');

        // Option C: default EasyAdmin dashboard
        return parent::index();
    }

    public function configureDashboard(): Dashboard
    {
        return Dashboard::new()
            ->setTitle('My App')                    // supports HTML
            ->setFaviconPath('favicon.svg')
            ->renderContentMaximized()              // full width
            ->renderSidebarMinimized()              // narrow sidebar
            ->disableDarkMode()
            ->setDefaultColorScheme('light')         // 'light', 'dark', 'auto'
            ->setTranslationDomain('admin')
            ->generateRelativeUrls()
            ->setLocales(['en' => 'English', 'es' => 'Español']);
    }
}
```

---

## MenuItem API (complete)

```php
// Link to dashboard
MenuItem::linkToDashboard(string $label, ?string $icon = null)

// Link to a CRUD controller (REPLACES linkToCrud from v4)
MenuItem::linkTo(string $controllerFqcn, ?string $label = null, ?string $icon = null)
    ->setAction(string $action)         // e.g. Action::NEW
    ->setEntityId(mixed $entityId)
    ->setDefaultSort(['field' => 'DESC'])

// Link to a Symfony route
MenuItem::linkToRoute(string $label, ?string $icon, string $routeName, array $routeParameters = [])

// Link to external URL
MenuItem::linkToUrl(string $label, ?string $icon, string $url)

// Visual separator
MenuItem::section(?string $label = null, ?string $icon = null)

// Dropdown submenu (max 2 levels)
MenuItem::subMenu(string $label, ?string $icon = null)
    ->setSubItems(array $items)

// Logout
MenuItem::linkToLogout(string $label, ?string $icon)

// Exit impersonation
MenuItem::linkToExitImpersonation(string $label, ?string $icon)
```

### Common methods on all MenuItems

```php
->setCssClass(string $cssClass)
->setLinkRel(string $rel)
->setLinkTarget(string $target)             // '_blank', '_self'
->setPermission(string $permission)         // 'ROLE_ADMIN'
->setHtmlAttribute(string $name, mixed $value)
->setBadge(mixed $content, string $style = 'secondary', array $htmlAttributes = [])
```

### Top menu example (submenus)

```php
public function configureMenuItems(): iterable
{
    yield MenuItem::linkToDashboard('Dashboard', 'fa fa-home');

    yield MenuItem::subMenu('CRM', 'fa-solid fa-users-gear')->setSubItems([
        MenuItem::linkTo(CompanyCrudController::class, 'Companies', 'fas fa-building'),
        MenuItem::linkTo(UserCrudController::class, 'Users', 'fas fa-user'),
    ]);

    yield MenuItem::subMenu('Monitoring', 'fa fa-chart-line')->setSubItems([
        MenuItem::linkTo(LogCrudController::class, 'Logs', 'fa fa-list'),
    ]);
}
```

---

## CRUD Controller

```php
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Config\Crud;
use EasyCorp\Bundle\EasyAdminBundle\Config\Action;
use EasyCorp\Bundle\EasyAdminBundle\Config\Actions;

class ProductCrudController extends AbstractCrudController
{
    public static function getEntityFqcn(): string
    {
        return Product::class;
    }

    public function configureCrud(Crud $crud): Crud
    {
        return $crud
            ->setEntityLabelInSingular('Product')
            ->setEntityLabelInPlural('Products')
            ->setDefaultSort(['id' => 'DESC'])
            ->setSearchFields(['name', 'description'])
            ->setPaginatorPageSize(30)
            ->renderContentMaximized()
            ->setEntityPermission('ROLE_EDITOR');
    }

    public function configureActions(Actions $actions): Actions
    {
        return $actions
            ->add(Crud::PAGE_INDEX, Action::DETAIL);
    }

    public function configureFields(string $pageName): iterable
    {
        // See Fields section below
    }
}
```

### Entity persistence overrides

```php
public function createEntity(string $entityFqcn): object
{
    $entity = new Product();
    $entity->setCreatedBy($this->getUser());
    return $entity;
}

public function persistEntity(EntityManagerInterface $em, mixed $entityInstance): void
{
    parent::persistEntity($em, $entityInstance);
}

public function updateEntity(EntityManagerInterface $em, mixed $entityInstance): void
{
    parent::updateEntity($em, $entityInstance);
}

public function deleteEntity(EntityManagerInterface $em, mixed $entityInstance): void
{
    parent::deleteEntity($em, $entityInstance);
}
```

---

## Fields (34 built-in types)

ArrayField, AssociationField, AvatarField, BooleanField, ChoiceField,
CodeEditorField, CollectionField, ColorField, CountryField, CurrencyField,
DateField, DateTimeField, EmailField, HiddenField, IdField, ImageField,
IntegerField, LanguageField, LocaleField, MoneyField, NumberField,
PercentField, SlugField, TelephoneField, TextareaField, TextEditorField,
TextField, TimeField, TimezoneField, UrlField.

### Common field methods

```php
->hideOnIndex() / ->hideOnDetail() / ->hideOnForm()
->hideWhenCreating() / ->hideWhenUpdating()
->onlyOnIndex() / ->onlyOnDetail() / ->onlyOnForms()
->setColumns(6)                              // Bootstrap grid width
->setColumns('col-sm-6 col-lg-4')           // Responsive
->setLabel('Custom Label')
->setHelp('Help text')
->setSortable(false)
->setPermission('ROLE_ADMIN')
->setFormType(TextType::class)
->setFormTypeOptions(['attr' => ['placeholder' => '...']])
->setTemplatePath('admin/field/custom.html.twig')
->addCssClass('text-bold')
->formatValue(fn($value, $entity) => '...')
```

### Layout fields (FormField)

```php
FormField::addTab('Tab Label')->setIcon('fas fa-icon')
FormField::addColumn(8)                      // or 'col-lg-8 col-xl-6'
FormField::addFieldset('Title')              // replaces addPanel() from v4
    ->collapsible()
    ->renderCollapsed()
FormField::addRow()                          // force new row
```

---

## Actions API

### Built-in action names

```php
Action::INDEX, Action::DETAIL, Action::NEW, Action::EDIT,
Action::DELETE, Action::SAVE_AND_RETURN, Action::SAVE_AND_CONTINUE,
Action::SAVE_AND_ADD_ANOTHER
```

### Custom actions

```php
$reviewAction = Action::new('review', 'Review', 'fa fa-eye')
    ->linkToCrudAction('reviewProduct')         // method in this controller
    ->linkToRoute('app_review', ['id' => '...']) // or Symfony route
    ->linkToUrl('https://...')                   // or external URL
    ->setCssClass('btn btn-primary')
    ->setIcon('fa fa-check')
    ->displayIf(fn(Product $p) => !$p->isReviewed())
    ->setPermission('ROLE_REVIEWER')
    ->askConfirmation('Are you sure?')
    ->renderAsButton()                          // NOT displayAsButton (v4)
    ->asPrimaryAction()                         // or asWarningAction(), asDangerAction()
    ->createAsGlobalAction();                   // for index page header
```

### Action styling variants

```php
->asPrimaryAction()   ->asDefaultAction()   ->asSuccessAction()
->asWarningAction()   ->asDangerAction()
->renderAsLink()      ->renderAsButton()    ->renderAsForm()
```

---

## Design Customization

### Custom CSS via configureAssets()

```php
public function configureAssets(): Assets
{
    return Assets::new()
        ->addCssFile('css/admin.css')
        ->addJsFile('js/admin.js')
        ->addAssetMapperEntry('admin')
        ->addWebpackEncoreEntry('admin-app')
        ->useCustomIconSet()                    // use non-FontAwesome icons
        ;
}
```

### CSS Variables (override in custom CSS)

```css
:root {
    --body-max-width: 100%;
    --body-bg: #f5f5f5;
    --font-size-base: 13px;
    --border-radius: 0px;
}
```

### Template overrides

Place in `templates/bundles/EasyAdminBundle/`:

```twig
{# templates/bundles/EasyAdminBundle/layout.html.twig #}
{% extends '@!EasyAdmin/layout.html.twig' %}

{% block sidebar %}
    {# custom sidebar #}
{% endblock %}
```

### Body CSS selectors (per-page styling)

| Page | body id | body class |
|---|---|---|
| index | `ea-index-Product` | `ea-index ea-index-Product` |
| detail | `ea-detail-Product-42` | `ea-detail ea-detail-Product` |
| edit | `ea-edit-Product-42` | `ea-edit ea-edit-Product` |
| new | `ea-new-Product` | `ea-new ea-new-Product` |

---

## User Menu

```php
public function configureUserMenu(UserInterface $user): UserMenu
{
    return parent::configureUserMenu($user)
        ->setName($user->getFullName())
        ->setAvatarUrl($user->getAvatarUrl())
        ->setGravatarEmail($user->getEmail())
        ->addMenuItems([
            MenuItem::linkToRoute('My Profile', 'fa fa-id-card', 'user_profile'),
            MenuItem::section(),
            MenuItem::linkToLogout('Logout', 'fa fa-sign-out'),
        ]);
}
```

---

## URL Generation

```php
use EasyCorp\Bundle\EasyAdminBundle\Router\AdminUrlGenerator;

// In a controller
$url = $this->container->get(AdminUrlGenerator::class)
    ->setController(ProductCrudController::class)
    ->setAction(Action::EDIT)
    ->setEntityId($product->getId())
    ->generateUrl();

// In Twig
{% set url = ea_url()
    .setController('App\\Controller\\Admin\\ProductCrudController')
    .setAction('edit')
    .setEntityId(product.id) %}
```
