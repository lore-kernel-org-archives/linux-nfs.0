Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:29824 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752707AbdGDM63 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:58:29 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, peterz@infradead.org,
        keescook@chromium.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-nfs@vger.kernel.org, zyan@redhat.com,
        sage@redhat.com, bfields@fieldses.org, jlayton@poochiereds.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        santosh.shilimkar@oracle.com, jreuter@yaina.de,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 32/36] net, sctp: convert sctp_transport.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:27 +0300
Message-Id: <1499172811-16271-33-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
References: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/sctp/structs.h | 2 +-
 net/sctp/transport.c       | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0dfc5c1..6a0d372 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -735,7 +735,7 @@ struct sctp_transport {
 	struct rhlist_head node;
 
 	/* Reference counting. */
-	atomic_t refcnt;
+	refcount_t refcnt;
 		/* RTO-Pending : A flag used to track if one of the DATA
 		 *		chunks sent to this address is currently being
 		 *		used to compute a RTT. If this flag is 0,
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 7cdd6bc..80a97c8 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -99,7 +99,7 @@ static struct sctp_transport *sctp_transport_init(struct net *net,
 	/* Initialize the 64-bit random nonce sent with heartbeat. */
 	get_random_bytes(&peer->hb_nonce, sizeof(peer->hb_nonce));
 
-	atomic_set(&peer->refcnt, 1);
+	refcount_set(&peer->refcnt, 1);
 
 	return peer;
 }
@@ -172,7 +172,7 @@ static void sctp_transport_destroy_rcu(struct rcu_head *head)
  */
 static void sctp_transport_destroy(struct sctp_transport *transport)
 {
-	if (unlikely(atomic_read(&transport->refcnt))) {
+	if (unlikely(refcount_read(&transport->refcnt))) {
 		WARN(1, "Attempt to destroy undead transport %p!\n", transport);
 		return;
 	}
@@ -311,7 +311,7 @@ void sctp_transport_route(struct sctp_transport *transport,
 /* Hold a reference to a transport.  */
 int sctp_transport_hold(struct sctp_transport *transport)
 {
-	return atomic_add_unless(&transport->refcnt, 1, 0);
+	return refcount_inc_not_zero(&transport->refcnt);
 }
 
 /* Release a reference to a transport and clean up
@@ -319,7 +319,7 @@ int sctp_transport_hold(struct sctp_transport *transport)
  */
 void sctp_transport_put(struct sctp_transport *transport)
 {
-	if (atomic_dec_and_test(&transport->refcnt))
+	if (refcount_dec_and_test(&transport->refcnt))
 		sctp_transport_destroy(transport);
 }
 
-- 
2.7.4

