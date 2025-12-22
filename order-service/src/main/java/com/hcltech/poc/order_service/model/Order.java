package com.hcltech.poc.order_service.model;

import org.hibernate.annotations.CreationTimestamp;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "ORDERS")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    @NotBlank
    private String description;

    @Column(nullable = false)
    @NotBlank
    private String product;

    @Column(nullable = false)
    @NotNull
    @Positive
    private Integer quantity;

    @Column(nullable = false, precision = 12, scale = 2)
    @NotNull
    @Positive
    private BigDecimal price;

    @Column(name = "order_submitted_date", updatable = false)
    @CreationTimestamp
    private LocalDateTime orderSubmittedDate;

    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getProduct() { return product; }
    public void setProduct(String product) { this.product = product; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public LocalDateTime getOrderSubmittedDate() { return orderSubmittedDate; }
    public void setOrderSubmittedDate(LocalDateTime orderSubmittedDate) { this.orderSubmittedDate = orderSubmittedDate; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
