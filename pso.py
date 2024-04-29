import numpy as np

def himmelblau_function(x):
    """Calculate Himmelblau's function at coordinates x[0] (x) and x[1] (y)."""
    return (x[0]**2 + x[1] - 11)**2 + (x[0] + x[1]**2 - 7)**2


def pso(n_particles, dimensions, iterations, bounds):
    cognitive_weight = 1.49
    social_weight = 1.49
    inertia_weight = 0.5

    # Initialize positions and velocities
    positions = np.random.uniform(bounds[0], bounds[1], (n_particles, dimensions))
    velocities = np.random.uniform(-1, 1, (n_particles, dimensions))

    # Initialize personal best positions and their values
    personal_best_positions = np.copy(positions)
    personal_best_values = np.array([himmelblau_function(pos) for pos in personal_best_positions])

    # Identify the global best from the personal bests
    g_best_index = np.argmin(personal_best_values)
    g_best_value = personal_best_values[g_best_index]
    g_best_position = personal_best_positions[g_best_index]

    # Iterations of PSO
    for _ in range(iterations):
        for i in range(n_particles):
            r1 = np.random.rand(dimensions)
            r2 = np.random.rand(dimensions)

            # Update velocities
            velocities[i] = (inertia_weight * velocities[i] +
                             cognitive_weight * r1 * (personal_best_positions[i] - positions[i]) +
                             social_weight * r2 * (g_best_position - positions[i]))

            # Update positions
            positions[i] += velocities[i]

            # Evaluate new positions
            current_value = himmelblau_function(positions[i])
            if current_value < personal_best_values[i]:
                personal_best_values[i] = current_value
                personal_best_positions[i] = positions[i]

            # Update the global best if needed
            if current_value < g_best_value:
                g_best_value = current_value
                g_best_position = positions[i]

    print(f"Best position: {g_best_position} with value: {g_best_value}")
    return g_best_position, g_best_value

# Parameters
n_particles = 100
dimensions = 2  # Himmelblau's function is a 2D function
iterations = 100
bounds = (-10, 10)  # Define bounds for initialization of positions within typical problem space

# Run PSO
best_position, best_value = pso(n_particles, dimensions, iterations, bounds)
