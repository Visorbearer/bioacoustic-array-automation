# Define distance matrix (meters)
distances <- matrix(c(
  0,      45.001, 26.929, 30.965,  # South to others
  45.001, 0,      37.295, 28.220,  # North
  26.929, 37.295, 0,      43.631,  # East
  30.965, 28.220, 43.631, 0        # West
), nrow = 4, byrow = TRUE)

# S N E W

rownames(distances) <- colnames(distances) <- c("South", "North", "East", "West")

# Add radar as 5th point
radar_dists <- c(24.633, 19.716, 21.352, 22.364)
distances_radar <- as.matrix(rbind(
  cbind(distances, radar = radar_dists),
  radar = c(radar_dists, 0)
))

# Get relative coordinates (2D scaling)
coords <- cmdscale(as.dist(distances_radar), k = 2)

# Shift so radar is at (0,0)
coords_shifted <- sweep(coords, 2, coords["radar", ])

# Rotate so North is on +Y axis
theta <- atan2(coords_shifted["North", 2], coords_shifted["North", 1])
rotation_matrix <- matrix(c(cos(-theta), -sin(-theta),
                            sin(-theta),  cos(-theta)), ncol = 2)
coords_aligned <- as.matrix(coords_shifted) %*% rotation_matrix

# Flip horizontally if East/West reversed
if (coords_aligned["East",1] < coords_aligned["West",1]) {
  coords_aligned[,1] <- -coords_aligned[,1]
}

# Rotate 90 deg clockwise so North is "up"
rotation_90 <- matrix(c(0, 1, -1, 0), ncol = 2)
coords_aligned <- coords_aligned %*% rotation_90

# Create final data frame
utm_coords <- data.frame(
  direction = rownames(coords_aligned),
  x = coords_aligned[,1],
  y = coords_aligned[,2]
)

print(utm_coords)

# Write out
write.csv(utm_coords, "aru_coords.csv", row.names = FALSE)

# View the locations to laugh at how bad my placement was
plot(
  utm_coords$x, utm_coords$y,
  xlab = "Meters, East-West",
  ylab = "Meters, North-South",
  asp = 1, pch = 19,
  col = ifelse(utm_coords$direction == "radar", "gray65", "#4a6d3e"),
  main = "Grosbeak and Radar Layout",
  cex = 2,        # make points bigger
  cex.axis = 1.5, # make axis tick labels bigger
  cex.lab = 1.8,  # make axis titles bigger
  cex.main = 2    # make plot title bigger
)
text(
  utm_coords$x, utm_coords$y,
  labels = utm_coords$direction,
  pos = 3,
  cex = 1.5,      # make text labels bigger
  col = "black"
)
abline(h = 0, v = 0, lty = 2, col = "gray35")
