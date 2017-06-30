Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47836 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752026AbdF3NYS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:18 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 05/14] VSOCK: add tcp_read_sock()-like vsock_read_sock() function
Date: Fri, 30 Jun 2017 14:23:43 +0100
Message-Id: <20170630132352.32133-6-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
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
 include/linux/virtio_vsock.h            |  4 ++
 include/net/af_vsock.h                  |  5 +++
 drivers/vhost/vsock.c                   |  1 +
 net/vmw_vsock/af_vsock.c                | 16 ++++++++
 net/vmw_vsock/virtio_transport.c        |  1 +
 net/vmw_vsock/virtio_transport_common.c | 66 +++++++++++++++++++++++++++++++++
 net/vmw_vsock/vmci_transport.c          |  8 ++++
 7 files changed, 101 insertions(+)

diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
index ab13f07..d6cf428 100644
--- a/include/linux/virtio_vsock.h
+++ b/include/linux/virtio_vsock.h
@@ -5,6 +5,7 @@
 #include <linux/socket.h>
 #include <net/sock.h>
 #include <net/af_vsock.h>
+#include <net/tcp.h> /* for sk_read_actor_t */
 
 #define VIRTIO_VSOCK_DEFAULT_MIN_BUF_SIZE	128
 #define VIRTIO_VSOCK_DEFAULT_BUF_SIZE		(1024 * 256)
@@ -126,6 +127,9 @@ int virtio_transport_notify_send_post_enqueue(struct vsock_sock *vsk,
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
index f9fb566..85fa345 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -19,6 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/workqueue.h>
 #include <linux/vm_sockets.h>
+#include <net/tcp.h> /* for sk_read_actor_t */
 
 #include "vsock_addr.h"
 
@@ -73,6 +74,8 @@ struct vsock_sock {
 	void *trans;
 };
 
+int vsock_read_sock(struct sock *sk, read_descriptor_t *desc,
+		    sk_read_actor_t recv_actor);
 s64 vsock_stream_has_data(struct vsock_sock *vsk);
 s64 vsock_stream_has_space(struct vsock_sock *vsk);
 void vsock_pending_work(struct work_struct *work);
@@ -125,6 +128,8 @@ struct vsock_transport {
 	u64 (*stream_rcvhiwat)(struct vsock_sock *);
 	bool (*stream_is_active)(struct vsock_sock *);
 	bool (*stream_allow)(u32 cid, u32 port);
+	int (*stream_read_sock)(struct vsock_sock *, read_descriptor_t *desc,
+				sk_read_actor_t recv_actor);
 
 	/* Notification. */
 	int (*notify_poll_in)(struct vsock_sock *, size_t, bool *);
diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index 3acef3c..5128e41 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -734,6 +734,7 @@ static struct virtio_transport vhost_transport = {
 		.stream_rcvhiwat          = virtio_transport_stream_rcvhiwat,
 		.stream_is_active         = virtio_transport_stream_is_active,
 		.stream_allow             = virtio_transport_stream_allow,
+		.stream_read_sock         = virtio_transport_stream_read_sock,
 
 		.notify_poll_in           = virtio_transport_notify_poll_in,
 		.notify_poll_out          = virtio_transport_notify_poll_out,
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index dfc8c51e..2ae94b5a 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -706,6 +706,22 @@ static void vsock_sk_destruct(struct sock *sk)
 	put_cred(vsk->owner);
 }
 
+/* See documentation for tcp_read_sock() */
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
index 403d86e80..8264307 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -520,6 +520,7 @@ static struct virtio_transport virtio_transport = {
 		.stream_rcvhiwat          = virtio_transport_stream_rcvhiwat,
 		.stream_is_active         = virtio_transport_stream_is_active,
 		.stream_allow             = virtio_transport_stream_allow,
+		.stream_read_sock         = virtio_transport_stream_read_sock,
 
 		.notify_poll_in           = virtio_transport_notify_poll_in,
 		.notify_poll_out          = virtio_transport_notify_poll_out,
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index 18e2479..510d9e1 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -316,6 +316,72 @@ virtio_transport_stream_dequeue(struct vsock_sock *vsk,
 EXPORT_SYMBOL_GPL(virtio_transport_stream_dequeue);
 
 int
+virtio_transport_stream_read_sock(struct vsock_sock *vsk,
+				  read_descriptor_t *desc,
+				  sk_read_actor_t recv_actor)
+{
+	struct virtio_vsock_sock *vvs;
+	int ret = 0;
+
+	vvs = vsk->trans;
+
+	spin_lock_bh(&vvs->rx_lock);
+	while (!list_empty(&vvs->rx_queue)) {
+		struct virtio_vsock_pkt *pkt;
+		struct sk_buff *skb;
+		size_t len;
+		int used;
+
+		pkt = list_first_entry(&vvs->rx_queue,
+				       struct virtio_vsock_pkt, list);
+
+		/* sk_lock is held by caller so no one else can dequeue.
+		 * Unlock rx_lock so recv_actor() can sleep.
+		 */
+		spin_unlock_bh(&vvs->rx_lock);
+
+		len = pkt->len - pkt->off;
+		skb = alloc_skb(len, GFP_KERNEL);
+		if (!skb) {
+			ret = -ENOMEM;
+			goto out_nolock;
+		}
+
+		memcpy(skb_put(skb, len),
+		       pkt->buf + pkt->off,
+		       len);
+
+		used = recv_actor(desc, skb, 0, len);
+
+		kfree_skb(skb);
+
+		spin_lock_bh(&vvs->rx_lock);
+
+		if (used > 0) {
+			ret += used;
+			pkt->off += used;
+			if (pkt->off == pkt->len) {
+				virtio_transport_dec_rx_pkt(vvs, pkt);
+				list_del(&pkt->list);
+				virtio_transport_free_pkt(pkt);
+			}
+		}
+
+		if (used <= 0 || !desc->count)
+			break;
+	}
+	spin_unlock_bh(&vvs->rx_lock);
+
+out_nolock:
+	if (ret > 0)
+		virtio_transport_send_credit_update(vsk,
+				VIRTIO_VSOCK_TYPE_STREAM, NULL);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(virtio_transport_stream_read_sock);
+
+int
 virtio_transport_dgram_dequeue(struct vsock_sock *vsk,
 			       struct msghdr *msg,
 			       size_t len, int flags)
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 10ae782..dfbdb4c 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -646,6 +646,13 @@ static bool vmci_transport_stream_allow(u32 cid, u32 port)
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
@@ -2061,6 +2068,7 @@ static const struct vsock_transport vmci_transport = {
 	.stream_rcvhiwat = vmci_transport_stream_rcvhiwat,
 	.stream_is_active = vmci_transport_stream_is_active,
 	.stream_allow = vmci_transport_stream_allow,
+	.stream_read_sock = vmci_transport_stream_read_sock,
 	.notify_poll_in = vmci_transport_notify_poll_in,
 	.notify_poll_out = vmci_transport_notify_poll_out,
 	.notify_recv_init = vmci_transport_notify_recv_init,
-- 
2.9.4

