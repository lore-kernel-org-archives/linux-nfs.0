Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FCA34915B7
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048504; cv=none; b=qufCmfcnk+3DT9XBcg9oQmMhgsw3VxVoiPxSAbSGt2eLx05d3tnlUkjMX27fFIAwmcfnkHyxn1zWaA14uBjplkABQhhE8DmLJdlc/I4CCnGLwGjzrDc9mrXhWLpDJbh3f/Sv/jnOD+24SrtVf3M+rG0zUFyKW4qyukMu1+NikVA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048504; c=relaxed/simple;
	bh=RoGVMP68ArO7CK//Jqnx1b/pVn4Wpmp11SPlkUAQImk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=BsQzHfuSPWq3DJtqW5SBLbuNtxJsrcR3VfiECMTZpZmboYdGPzXAWgxPZijiwJLanwAgBA0jgEN8LKhEpgT/o81kmRZw0E0iC1Bg25KLon9LxnKkLmrdfRljAK85eJvKpRtIik/0ImKb9Q8STo2V8HMNuXV/6K+mlmAJeXTYqbs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jGvkpQp+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jGvkpQp+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B70AF1F00898;
	Thu, 10 Sep 2026 13:55:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048503;
	bh=Jll68PPSds+1J4SUZmRvY0kDO+znWtGBHjoPCJjXYWg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jGvkpQp+DUIA9YOLflZEvU0M9qu2sc3koNOFNbNXPBufHVdTOL18duQmOYv19ceAR
	 9DvsjXujgYw3zkt1dkSJ0mq+BD53MVRs5pPDo765LLFGEFbjduVvdMcr6YfJ+FaZ43
	 s/bSgY9xmyKLCKMtPtX3mlbnxuvxuZJhBmlLPhRIPuzD/Xo5CyKgc+iZOTE5KSPd2k
	 Zohhjdlan5jRvYF6RRtsfVG6MMGKBRBt8d4Z/55qvXYe7DXmdC6aSPcEKjq3GIqUXf
	 mmybbidpyOtSsg9tozfEyhFF2fkCbzJKmOr/IjHpIuglmE63ZC2/ZWK7M596z6Z1Cd
	 a8VhPi8skcQJg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:47 -0400
Subject: [PATCH v3 07/12] SUNRPC: Add TCP sequence-number ACK tracking for
 reply delivery
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-7-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=10267; i=cel@kernel.org;
 h=from:subject:message-id; bh=RoGVMP68ArO7CK//Jqnx1b/pVn4Wpmp11SPlkUAQImk=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGqitrCiGNlUNJzelFOKbAe7Wyv/Nl6LpaOc7vVTvTuULJg4B
 okCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJqorawAAoJEDNqszNvZn+XgKUP/iSf
 Mzf9CNIv5v1lW4q8Bg6Hq+NTpLz3CST8Ph5Txa6B3zLrLkbsCysNLb9BbBXJjJMHI+81ZYJ9oc2
 J+ABvLOOA2pkQtLadRHYO1ETnC694KZxT7VyNG5n/tFAcIm08My0O/GDZW+rO1VmrDUXY60cEIu
 Mfbyk1GWcqyJOmk4eq8tx3FRqx0YDZ/bB0DvePueZbGRxxujMagmDLV8xm9ypv6fCwlnLGLoU7b
 1vlqdXwarhkEGIgzuDboAHsIxxg6aImALikkGJmayHW0zB+gffKmhHhYkvDUlH77Ice0XooohR/
 C79ZQUcIVntMginfH/JvaltBZ++jyq3D72KR+cT7hXHkLluoqe+GLhXx6J/OujiHuE3Bzp4IDJZ
 VDkqkOZA/jphMjxL8UbN24K+SJkcpQZmp9ML0n+QPwwtmprFbyv7kE9MH+NEYUIMCDbTYmsCiuF
 HqV7HioOCWbTmTCGYDO+anzR18CR0krIJ16/UjO68Oe9fD5vtBGbmkPIuort++4sZ9iZykmlS4P
 9JiARm+utDunYd70PvHl5cKA7J48kzwnVK3Bz5n/JducSu0jY4UJJYI4clROIVjPlRh50UXc7wk
 Ej0B4SOyl3VNDc2s6InUvyy1R9//8okpi7H5MU83cqarZjT+56m3DtmEJ+hJUcpGA4ugy0R0b/D
 VP0+b
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A DRC entry for a reply sent over TCP lingers until RC_EXPIRE even
though the peer's TCP acknowledgment has already confirmed that the
reply arrived.

The acknowledgment confirms only that the reply reached the peer's
TCP stack. If the connection drops before the NFS client reads it,
the client retransmits the call and the evicted entry cannot answer
it. Memory pressure and RC_EXPIRE already open the same window.

When the upper layer caches a reply it stores a cookie on the
svc_rqst. After svc_tcp_sendto() transmits the reply, record the
cookie with the current write_seq in a fixed-size per-socket ring.
Before appending, drain entries whose sequence number is at or before
snd_una and report each as delivered. The send path is
single-threaded, so the ring needs no locking. sk_wmem_queued cannot
be used for this because it counts per-skb truesize, not payload
bytes.

On a kTLS session the snapshot needs one more check. A short push
inside the TLS layer leaves the rest of the record as
partially_sent_record, and tls_sw_sendmsg() still returns the full
plaintext count, so write_seq can fall short of the reply. Record the
reply only when no partially_sent_record remains after the send.

Some replies get no ring entry: the ring is full, the send fails, the
transport is already dead, or a kTLS record is still partly unsent.
Report each of these as untracked at once, so the upper layer knows no
delivery report will follow. When the socket is freed, report entries
still in the ring as undelivered. Set XPT_REPLY_ACK on TCP transports
so the upper layer expects these reports.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c             | 15 +++++---
 include/linux/sunrpc/svc.h     |  3 ++
 include/linux/sunrpc/svcsock.h | 10 +++++
 net/sunrpc/svc.c               |  1 +
 net/sunrpc/svcsock.c           | 85 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 108 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index b0231c659237..473bf825c37a 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -289,12 +289,14 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net *nn)
 }
 
 /*
- * The generation match keeps a stale cookie from acknowledging a
- * later entry that reuses the same XID and transport. The walk
- * starts at the MRU end of the bucket LRU, where the entry for a
- * just-sent reply sits. The visit cap bounds the time spent under
- * cache_lock when a client packs the bucket; an entry missed under
- * the cap is left to the other eviction reasons.
+ * The generation match keeps a stale cookie from acknowledging a later
+ * entry that reuses the same XID and transport.
+ *
+ * Average bucket occupancy is small (TARGET_BUCKET_SIZE), so a linear walk
+ * of the bucket LRU beats an rb-tree lookup. The walk starts at the MRU
+ * end, where the entry for a just-sent reply sits. The visit cap bounds
+ * the time spent under cache_lock when a client packs the bucket; an entry
+ * missed under the cap is left to the other eviction reasons.
  */
 static void nfsd_reply_ack(void *data, const svc_ack_cookie_t *cookie,
 			   bool delivered)
@@ -723,6 +725,7 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 	rp->c_ack_gen = nfsd_cache_next_ack_gen();
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
+	rqstp->rq_ack_cookie = nfsd_cache_ack_cookie(rp);
 	spin_unlock(&b->cache_lock);
 	return;
 }
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8c9e27752698..da3822c54f3e 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -315,6 +315,9 @@ struct svc_rqst {
 	unsigned int		bc_to_retries;
 	unsigned int		rq_status_counter; /* RPC processing counter */
 	void			*rq_private;	/* For use by the service thread */
+
+	svc_ack_cookie_t	rq_ack_cookie;	/* zero when no reply-ack
+						 * tracking is requested */
 };
 
 /* bits for rq_flags */
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 372a00882ca6..595be631b68b 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -41,6 +41,16 @@ struct svc_sock {
 
 	struct page_frag_cache  sk_frag_cache;
 
+	/* TCP reply-ACK tracking (single-threaded send path) */
+#define SVC_ACK_RING_BITS	6
+#define SVC_ACK_RING_SIZE	(1 << SVC_ACK_RING_BITS)
+	struct {
+		u32		ae_pos;		/* write_seq after send */
+		svc_ack_cookie_t ae_cookie;	/* opaque DRC cookie */
+	}			sk_ack_ring[SVC_ACK_RING_SIZE];
+	unsigned int		sk_ack_head;
+	unsigned int		sk_ack_tail;
+
 	struct completion	sk_handshake_done;
 
 	/* received data */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f73412e123a1..33dd9cbaff42 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1488,6 +1488,7 @@ svc_process_common(struct svc_rqst *rqstp)
 
 	/* Reset the accept_stat for the RPC */
 	rqstp->rq_accept_statp = NULL;
+	rqstp->rq_ack_cookie = (svc_ack_cookie_t){};
 
 	/* Will be turned off only when NFSv4 Sessions are used */
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 625aebbbc6b3..a28905181589 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -28,6 +28,7 @@
 #include <linux/file.h>
 #include <linux/freezer.h>
 #include <linux/bvec.h>
+#include <linux/circ_buf.h>
 
 #include <net/sock.h>
 #include <net/checksum.h>
@@ -36,6 +37,7 @@
 #include <net/udp.h>
 #include <net/tcp.h>
 #include <net/tcp_states.h>
+#include <net/tls.h>
 #include <net/tls_prot.h>
 #include <net/handshake.h>
 #include <linux/uaccess.h>
@@ -88,6 +90,7 @@ static void		svc_sock_free(struct svc_xprt *);
 static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
 					  struct net *, struct sockaddr *,
 					  int, int);
+
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key svc_key[2];
 static struct lock_class_key svc_slock_key[2];
@@ -379,6 +382,45 @@ static void svc_data_ready(struct sock *sk)
 	}
 }
 
+/*
+ * Report as delivered each recorded reply that the peer's cumulative ACK
+ * now covers.
+ */
+static void svc_tcp_ack_drain(struct svc_sock *svsk)
+{
+	struct svc_serv *serv = svsk->sk_xprt.xpt_server;
+	u32 snd_una = READ_ONCE(tcp_sk(svsk->sk_sk)->snd_una);
+
+	while (svsk->sk_ack_head != svsk->sk_ack_tail) {
+		unsigned int idx = svsk->sk_ack_tail &
+				   (SVC_ACK_RING_SIZE - 1);
+
+		if (after(svsk->sk_ack_ring[idx].ae_pos, snd_una))
+			break;
+		svc_reply_acked(serv,
+				&svsk->sk_ack_ring[idx].ae_cookie, true);
+		svsk->sk_ack_tail++;
+	}
+}
+
+/*
+ * Once the socket is freed, acknowledgments for replies still in the ring
+ * can no longer be observed.
+ */
+static void svc_tcp_ack_purge(struct svc_sock *svsk)
+{
+	struct svc_serv *serv = svsk->sk_xprt.xpt_server;
+
+	while (svsk->sk_ack_head != svsk->sk_ack_tail) {
+		unsigned int idx = svsk->sk_ack_tail &
+				   (SVC_ACK_RING_SIZE - 1);
+
+		svc_reply_acked(serv,
+				&svsk->sk_ack_ring[idx].ae_cookie, false);
+		svsk->sk_ack_tail++;
+	}
+}
+
 /*
  * INET callback when space is newly available on the socket.
  */
@@ -1392,6 +1434,19 @@ static int svc_tcp_sendmsg(struct svc_sock *svsk, struct svc_rqst *rqstp,
 	return ret;
 }
 
+/*
+ * tls_sw_sendmsg() can return the full plaintext count with part of a
+ * record still waiting for socket write space, leaving write_seq short
+ * of the reply. The TLS layer keeps that record as partially_sent_record
+ * until it is pushed.
+ */
+static bool svc_tcp_reply_queued(struct svc_sock *svsk)
+{
+	if (!test_bit(XPT_TLS_SESSION, &svsk->sk_xprt.xpt_flags))
+		return true;
+	return !READ_ONCE(tls_get_ctx(svsk->sk_sk)->partially_sent_record);
+}
+
 /**
  * svc_tcp_sendto - Send out a reply on a TCP socket
  * @rqstp: completed svc_rqst
@@ -1420,10 +1475,32 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	trace_svcsock_tcp_send(xprt, sent);
 	if (sent < 0 || sent != (xdr->len + sizeof(marker)))
 		goto out_close;
+
+	svc_tcp_ack_drain(svsk);
+	if (svc_ack_cookie_present(&rqstp->rq_ack_cookie)) {
+		if (svc_tcp_reply_queued(svsk) &&
+		    CIRC_SPACE(svsk->sk_ack_head, svsk->sk_ack_tail,
+			       SVC_ACK_RING_SIZE) > 0) {
+			unsigned int idx = svsk->sk_ack_head &
+					   (SVC_ACK_RING_SIZE - 1);
+
+			svsk->sk_ack_ring[idx].ae_pos =
+				tcp_sk(svsk->sk_sk)->write_seq;
+			svsk->sk_ack_ring[idx].ae_cookie =
+				rqstp->rq_ack_cookie;
+			svsk->sk_ack_head++;
+		} else {
+			svc_reply_acked(xprt->xpt_server, &rqstp->rq_ack_cookie,
+					false);
+		}
+	}
+
 	mutex_unlock(&xprt->xpt_mutex);
 	return sent;
 
 out_notconn:
+	if (svc_ack_cookie_present(&rqstp->rq_ack_cookie))
+		svc_reply_acked(xprt->xpt_server, &rqstp->rq_ack_cookie, false);
 	mutex_unlock(&xprt->xpt_mutex);
 	return -ENOTCONN;
 out_close:
@@ -1431,6 +1508,8 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 		  xprt->xpt_server->sv_name,
 		  (sent < 0) ? "got error" : "sent",
 		  sent, xdr->len + sizeof(marker));
+	if (svc_ack_cookie_present(&rqstp->rq_ack_cookie))
+		svc_reply_acked(xprt->xpt_server, &rqstp->rq_ack_cookie, false);
 	svc_xprt_deferred_close(xprt);
 	mutex_unlock(&xprt->xpt_mutex);
 	return -EAGAIN;
@@ -1487,6 +1566,7 @@ static bool svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 		return false;
 	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
+	set_bit(XPT_REPLY_ACK, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
 		strcpy(svsk->sk_xprt.xpt_remotebuf, "listener");
 		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
@@ -1593,6 +1673,9 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 		}
 	}
 
+	svsk->sk_ack_head = 0;
+	svsk->sk_ack_tail = 0;
+
 	svsk->sk_sock = sock;
 	svsk->sk_sk = inet;
 	svsk->sk_ostate = inet->sk_state_change;
@@ -1810,6 +1893,8 @@ static void svc_sock_free(struct svc_xprt *xprt)
 
 	trace_svcsock_free(svsk, sock);
 
+	svc_tcp_ack_purge(svsk);
+
 	tls_handshake_cancel(sock->sk);
 	if (sock->file)
 		sockfd_put(sock);

-- 
2.55.0

