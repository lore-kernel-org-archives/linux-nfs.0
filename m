Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47714 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752707AbdGDM6e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:58:34 -0400
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
Subject: [PATCH 33/36] net, sctp: convert sctp_ep_common.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:28 +0300
Message-Id: <1499172811-16271-34-git-send-email-elena.reshetova@intel.com>
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
 net/sctp/associola.c       | 6 +++---
 net/sctp/endpointola.c     | 6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6a0d372..5ab29af 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1174,7 +1174,7 @@ struct sctp_ep_common {
 	 *   refcnt   - Reference count access to this object.
 	 *   dead     - Do not attempt to use this object.
 	 */
-	atomic_t    refcnt;
+	refcount_t    refcnt;
 	bool	    dead;
 
 	/* What socket does this endpoint belong to?  */
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index fa4f530..40ec836 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -88,7 +88,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->base.type = SCTP_EP_TYPE_ASSOCIATION;
 
 	/* Initialize the object handling fields.  */
-	atomic_set(&asoc->base.refcnt, 1);
+	refcount_set(&asoc->base.refcnt, 1);
 
 	/* Initialize the bind addr area.  */
 	sctp_bind_addr_init(&asoc->base.bind_addr, ep->base.bind_addr.port);
@@ -873,7 +873,7 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 /* Hold a reference to an association. */
 void sctp_association_hold(struct sctp_association *asoc)
 {
-	atomic_inc(&asoc->base.refcnt);
+	refcount_inc(&asoc->base.refcnt);
 }
 
 /* Release a reference to an association and cleanup
@@ -881,7 +881,7 @@ void sctp_association_hold(struct sctp_association *asoc)
  */
 void sctp_association_put(struct sctp_association *asoc)
 {
-	if (atomic_dec_and_test(&asoc->base.refcnt))
+	if (refcount_dec_and_test(&asoc->base.refcnt))
 		sctp_association_destroy(asoc);
 }
 
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index efbc318..0e86f98 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -114,7 +114,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	ep->base.type = SCTP_EP_TYPE_SOCKET;
 
 	/* Initialize the basic object fields. */
-	atomic_set(&ep->base.refcnt, 1);
+	refcount_set(&ep->base.refcnt, 1);
 	ep->base.dead = false;
 
 	/* Create an input queue.  */
@@ -285,7 +285,7 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 /* Hold a reference to an endpoint. */
 void sctp_endpoint_hold(struct sctp_endpoint *ep)
 {
-	atomic_inc(&ep->base.refcnt);
+	refcount_inc(&ep->base.refcnt);
 }
 
 /* Release a reference to an endpoint and clean up if there are
@@ -293,7 +293,7 @@ void sctp_endpoint_hold(struct sctp_endpoint *ep)
  */
 void sctp_endpoint_put(struct sctp_endpoint *ep)
 {
-	if (atomic_dec_and_test(&ep->base.refcnt))
+	if (refcount_dec_and_test(&ep->base.refcnt))
 		sctp_endpoint_destroy(ep);
 }
 
-- 
2.7.4

