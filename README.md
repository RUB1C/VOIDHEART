# 🖤 VOIDHEART

> Un juego indie de terror atmosférico en 2D/3D híbrido desarrollado con Godot Engine.

VOIDHEART es un proyecto de terror y supervivencia que combina los controles precisos y fluidos de los plataformas 2D clásicos con un entorno 2.5D profundo, inmersivo y lleno de tensión.

---

## ✨ Características Principales

* **Pipeline Visual Híbrido:** Los personajes y entidades se modelan y animan en 3D, para luego procesarse en pixel art dinámico junto con **Mapas de Normales (Normal Maps)** en tiempo real, logrando interacciones de iluminación orgánicas (inspirado en técnicas modernas vistas en títulos como *Dead Cells*).
* **Entornos 2.5D Atmosféricos:** Fondos con parallax en múltiples capas y profundidad de perspectiva trabajada a mano, diseñados para evocar una atmósfera de terror claustrofóbica y tensa.
* **Iluminación 2D y Sombras Dinámicas:** Luces puntuales en tiempo real, colisionadores de oclusión personalizados y una sutil oscuridad ambiental impulsada nativamente por el motor de iluminación 2D de Godot.
* **Sistemas Personalizados:** Desarrollados desde cero utilizando **GDScript**, incluyendo controladores de movimiento modulares, máquinas de estados e interacciones lumínicas.

---

## 🛠️ Tecnologías y Herramientas

* **Motor de Juegos:** [Godot Engine](https://godotengine.org/) (Godot 4+)
* **Lenguaje de Programación:** GDScript
* **Pipeline de Activos 3D / Animación:** Blender (para renderizado de modelos, sprites y mapas de normales)
* **Control de Versiones:** Git y GitHub

---

## 📂 Estructura del Proyecto

voidheart/

├── assets/

│   ├── sprites/       # Hojas de sprites de personajes y enemigos y mapas de normales

│   ├── environments/  # Capas de parallax y arte de fondos

│   └── audio/         # Efectos de sonido y bandas sonoras ambientales

├── scenes/

│   ├── levels/        # Niveles del juego y escenas de habitaciones

│   └── entities/      # Jugador, enemigos y objetos interactivos

└── scripts/           # Controladores en GDScript y lógica del juego


🚀 Primeros Pasos
Para clonar y probar el proyecto de manera local:

Clona el repositorio:

Bash
git clone [https://github.com/R1UB1Q/voidheart.git](https://github.com/R1UB1Q/voidheart.git)
Abre Godot Engine (versión 4.x recomendada).

Haz clic en Importar y selecciona el archivo project.godot ubicado en la carpeta del repositorio clonado.

¡Presiona F5 para ejecutar el juego!

## 💻 1. Guía Rápida: GitHub Desktop

1. **Sincronizar al iniciar:**
   * Abre GitHub Desktop.
   * Ve a **Repository > Fetch origin** y luego **Pull origin** para asegurarte de tener los últimos cambios antes de programar.
2. **Crear o cambiar de rama:**
   * Haz clic en **Current Branch** en la parte superior izquierda y selecciona la rama sobre la que vas a trabajar (tu rama `feature/...`).
3. **Guardar cambios (Commit):**
   * Tras modificar archivos en Godot, revisa la pestaña *Changes*.
   * Escribe un mensaje claro y descriptivo en el **Summary** (siguiendo las reglas de commits de abajo).
   * Haz clic en **Commit to [nombre-de-rama]**.
4. **Subir cambios (Push):**
   * Haz clic en **Push origin** en la esquina superior derecha para respaldar tu trabajo en el repositorio remoto.

---

## 🌳 2. Estrategia de Ramas (Branching)

Está estrictamente prohibido commitear o hacer push directamente sobre la rama principal. La estructura se divide de la siguiente manera:

* `main`
  * **Propósito:** Rama de producción. Contiene únicamente versiones estables, probadas y funcionales del juego.
  * **Reglas:** No se edita directamente. Solo recibe fusiones (merges) provenientes de las `feature` mediante Pull Request validado.
* `feature/<nombre-de-la-tarea>`
  * **Propósito:** Ramas temporales creadas a partir de `main` para desarrollar mecánicas, scripts, niveles o apartados visuales específicos (ej: `feature/sistema-de-iluminacion`, `feature/movimiento-jugador`).

---

## 📝 3. Convención de Mensajes de Commit (Conventional Commits)

Todos los mensajes de commit deben seguir el siguiente formato estándar para facilitar el seguimiento de cambios:

`<tipo>: <descripción corta y directa en imperativo>`

### Tipos permitidos:
* `feat:` Nuevas características, mecánicas o sistemas del juego (ej: `feat: añadir física de salto y gravedad al personaje`).
* `fix:` Corrección de errores o bugs (ej: `fix: corregir fallo de colisión en el TileMap del nivel 1`).
* `refactor:` Reestructuración de código o escenas sin alterar la funcionalidad (ej: `refactor: optimizar script de movimiento del player`).
* `docs:` Cambios o adiciones en la documentación, README o guías (ej: `docs: actualizar guía de flujo de trabajo git`).
* `assets:` Importación, actualización o modificación de recursos visuales, sprites, normales o audio (ej: `assets: importar sprites provisionales de prueba`).

---

## 🔀 4. Proceso de Pull Requests (PRs)

Cuando una característica en tu rama `feature/` esté lista, probada y funcionando en local:

1. Sube tu rama al repositorio remoto mediante un **Push**.
2. Entra a GitHub, ve a la pestaña **Pull Requests** y haz clic en **New Pull Request**.
3. Configura la base para que apunte a `main` y la comparación a tu rama `feature/...`.
4. Asigna un título descriptivo y detalla brevemente qué se implementó o corrigió.
5. Solicita la revisión del equipo o realiza el **Merge Pull Request** una vez verificado que el proyecto compila y corre sin errores en Godot.

👤 Autores
Desarrollado por 
David Ernesto Ospina Piñeros (R1UB1Q)
Juan David Reyes Lazo (JReyes765)
Andres Mateo Boada Baquero ().
