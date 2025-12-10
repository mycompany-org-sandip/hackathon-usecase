package com.hcltech.poc.order_service.service;

import com.hcltech.poc.order_service.model.Order;
import com.hcltech.poc.order_service.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    public Order createOrder(Order order) {
        return orderRepository.save(order);
    }

    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    public Order getOrderById(Long id) {
        return orderRepository.findById(id).orElse(null);
    }

    public Order updateOrder(Long id, Order order) {
        Optional<Order> existing = orderRepository.findById(id);
        if (existing.isPresent()) {
            Order o = existing.get();
            o.setDescription(order.getDescription());
            o.setProduct(order.getProduct());
            o.setQuantity(order.getQuantity());
            o.setPrice(order.getPrice());
            return orderRepository.save(o);
        }
        return null;
    }

    public boolean deleteOrder(Long id) {
        if (orderRepository.existsById(id)) {
            orderRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
