Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932143AbbFDQqH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:46:07 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 05/10] VSOCK: add tcp_read_sock()-like vsock_read_sock() function
Date: Thu,  4 Jun 2015 17:45:48 +0100
Message-Id: <1433436353-6761-6-git-send-email-stefanha@redhat.com>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The tcp_read_sock() interface dequeues skbs and gives them to the
caller's callback function for processing.  This interface can avoid
data copies since the caller accesses the skb instead of using its own
receive buffer.

This patch implements vsock_read_sock() for AF_VSOCK SOCK_STREAM
sockets.  The implementation is only for virtio-vsock at this time, not
for the VMware VMCI transport.  It is not zero-copy yet because the
virtio-vsock receive queue does not consist of skbs.

The tcp_read_sock()-like interface is needed for AF_VSOCK sunrpc
support.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 drivers/vhost/vsock.c                   |  1 +
 include/linux/virtio_vsock.h            |  4 +++
 include/net/af_vsock.h                  |  5 +++
 net/vmw_vsock/af_vsock.c                | 15 +++++++++
 net/vmw_vsock/virtio_transport.c        |  1 +
 net/vmw_vsock/virtio_transport_common.c | 55 +++++++++++++++++++++++++++++++++
 net/vmw_vsock/vmci_transport.c          |  8 +++++
 7 files changed, 89 insertions(+)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 7a6f669..d715863 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -556,6 +556,7 @@ static struct vsock_transport vhost_transport = {
 	.stream_rcvhiwat          = virtio_transport_stream_rcvhiwat,
 	.stream_is_active         = virtio_transport_stream_is_active,
 	.stream_allow             = virtio_transport_stream_allow,
+	.stream_read_sock         = virtio_transport_stream_read_sock,
 
 	.notify_poll_in           = virtio_transport_notify_poll_in,
 	.notify_poll_out          = virtio_transport_notify_poll_out,
diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
index 01d84a5..a8af8f0 100644
--- a/include/linux/virtio_vsock.h
+++ b/include/linux/virtio_vsock.h
@@ -37,6 +37,7 @@
 #include <uapi/linux/virtio_vsock.h>
 #include <linux/socket.h>
 #include <net/sock.h>
+#include <net/tcp.h> /* for sk_read_actor_t */
 
 #define VIRTIO_VSOCK_DEFAULT_MIN_BUF_SIZE	128
 #define VIRTIO_VSOCK_DEFAULT_BUF_SIZE		(1024 * 256)
@@ -176,6 +177,9 @@ int virtio_transport_notify_send_post_enqueue(struct vsock_sock *vsk,
 u64 virtio_transport_stream_rcvhiwat(struct vsock_sock *vsk);
 bool virtio_transport_stream_is_active(struct vsock_sock *vsk);
 bool virtio_transport_stream_allow(u32 cid, u32 port);
+int virtio_transport_stream_read_sock(struct vsock_sock *vsk,
+				      read_descriptor_t *desc,
+				      sk_read_actor_t recv_actor);
 int virtio_transport_dgram_bind(struct vsock_sock *vsk,
 				struct sockaddr_vm *addr);
 bool virtio_transport_dgram_allow(u32 cid, u32 port);
diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index bc9055c..2fb7ea3 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -19,6 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/workqueue.h>
 #include <linux/vm_sockets.h>
+#include <net/tcp.h> /* for sk_read_actor_t */
 
 #include "vsock_addr.h"
 
@@ -69,6 +70,8 @@ struct vsock_sock {
 	void *trans;
 };
 
+int vsock_read_sock(struct sock *sk, read_descriptor_t *desc,
+		    sk_read_actor_t recv_actor);
 s64 vsock_stream_has_data(struct vsock_sock *vsk);
 s64 vsock_stream_has_space(struct vsock_sock *vsk);
 void vsock_pending_work(struct work_struct *work);
@@ -118,6 +121,8 @@ struct vsock_transport {
 	u64 (*stream_rcvhiwat)(struct vsock_sock *);
 	bool (*stream_is_active)(struct vsock_sock *);
 	bool (*stream_allow)(u32 cid, u32 port);
+	int (*stream_read_sock)(struct vsock_sock *, read_descriptor_t *desc,
+				sk_read_actor_t recv_actor);
 
 	/* Notification. */
 	int (*notify_poll_in)(struct vsock_sock *, size_t, bool *);
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 0b3c498..61b412c 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -764,6 +764,21 @@ static void vsock_sk_destruct(struct sock *sk)
 	put_cred(vsk->owner);
 }
 
+int vsock_read_sock(struct sock *sk, read_descriptor_t *desc,
+		    sk_read_actor_t recv_actor)
+{
+	struct vsock_sock *vsp = vsock_sk(sk);
+
+	if (sk->sk_type != SOCK_STREAM)
+		return -EOPNOTSUPP;
+
+	if (sk->sk_state != SS_CONNECTED && sk->sk_state != SS_DISCONNECTING)
+		return -ENOTCONN;
+
+	return transport->stream_read_sock(vsp, desc, recv_actor);
+}
+EXPORT_SYMBOL(vsock_read_sock);
+
 static int vsock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
index 5c35b31..365e8a6 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -315,6 +315,7 @@ static struct vsock_transport virtio_transport = {
 	.stream_rcvhiwat          = virtio_transport_stream_rcvhiwat,
 	.stream_is_active         = virtio_transport_stream_is_active,
 	.stream_allow             = virtio_transport_stream_allow,
+	.stream_read_sock         = virtio_transport_stream_read_sock,
 
 	.notify_poll_in           = virtio_transport_notify_poll_in,
 	.notify_poll_out          = virtio_transport_notify_poll_out,
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index 1153d29..28122e2 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -320,6 +320,61 @@ virtio_transport_stream_dequeue(struct vsock_sock *vsk,
 }
 EXPORT_SYMBOL_GPL(virtio_transport_stream_dequeue);
 
+int
+virtio_transport_stream_read_sock(struct vsock_sock *vsk,
+				  read_descriptor_t *desc,
+				  sk_read_actor_t recv_actor)
+{
+	struct virtio_transport *trans;
+	int ret = 0;
+
+	trans = vsk->trans;
+
+	mutex_lock(&trans->rx_lock);
+	while (trans->rx_bytes) {
+		struct virtio_vsock_pkt *pkt;
+		struct sk_buff *skb;
+		size_t len;
+		int used;
+
+		pkt = list_first_entry(&trans->rx_queue,
+				       struct virtio_vsock_pkt, list);
+
+		len = pkt->len - pkt->off;
+		skb = alloc_skb(len, GFP_KERNEL);
+		if (!skb)
+			break;
+
+		memcpy(skb_put(skb, len),
+		       pkt->buf + pkt->off,
+		       len);
+
+		used = recv_actor(desc, skb, 0, len);
+
+		kfree_skb(skb);
+
+		if (used > 0) {
+			ret += used;
+			pkt->off += used;
+			if (pkt->off == pkt->len) {
+				virtio_transport_dec_rx_pkt(pkt);
+				list_del(&pkt->list);
+				virtio_transport_free_pkt(pkt);
+			}
+		}
+
+		if (used <= 0 || !desc->count)
+			break;
+	}
+	mutex_unlock(&trans->rx_lock);
+
+	if (ret > 0)
+		virtio_transport_send_credit_update(vsk, SOCK_STREAM, NULL);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_read_sock);
+
 struct dgram_skb {
 	struct list_head list;
 	struct sk_buff *skb;
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index c294da0..d329564 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -654,6 +654,13 @@ static bool vmci_transport_stream_allow(u32 cid, u32 port)
 	return true;
 }
 
+static int vmci_transport_stream_read_sock(struct vsock_sock *vsk,
+					   read_descriptor_t *desc,
+					   sk_read_actor_t recv_actor)
+{
+	return -EOPNOTSUPP; /* not yet implemented */
+}
+
 /* This is invoked as part of a tasklet that's scheduled when the VMCI
  * interrupt fires.  This is run in bottom-half context but it defers most of
  * its work to the packet handling work queue.
@@ -2083,6 +2090,7 @@ static struct vsock_transport vmci_transport = {
 	.stream_rcvhiwat = vmci_transport_stream_rcvhiwat,
 	.stream_is_active = vmci_transport_stream_is_active,
 	.stream_allow = vmci_transport_stream_allow,
+	.stream_read_sock = vmci_transport_stream_read_sock,
 	.notify_poll_in = vmci_transport_notify_poll_in,
 	.notify_poll_out = vmci_transport_notify_poll_out,
 	.notify_recv_init = vmci_transport_notify_recv_init,
-- 
2.4.2

