module.exports = (io) => {
    io.on('connection', (socket) => {
        console.log('New client connected:', socket.id);

        // Join a room based on orderId
        socket.on('join_room', (orderId) => {
            socket.join(orderId);
            console.log(`Socket ${socket.id} joined room ${orderId}`);
        });

        // Driver sends location updates
        socket.on('update_location', (data) => {
            // data: { orderId, lat, lng }
            const { orderId, lat, lng } = data;
            console.log(`Location update for order ${orderId}: ${lat}, ${lng}`);

            // Broadcast to everyone in the room except the sender (though handy if sender sees it too, but typically for customer)
            // actually using io.to(orderId) sends to everyone in room including sender if they are in it. 
            // socket.to(orderId) sends to everyone else.
            socket.to(orderId).emit('receive_location', { lat, lng });

            // TODO: Save to Firebase here if needed
        });

        socket.on('disconnect', () => {
            console.log('Client disconnected:', socket.id);
        });
    });
};
