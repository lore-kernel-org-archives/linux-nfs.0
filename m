Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56925 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752702AbdGDM6c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:58:32 -0400
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
Subject: [PATCH 31/36] net, sctp: convert sctp_chunk.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:26 +0300
Message-Id: <1499172811-16271-32-git-send-email-elena.reshetova@intel.com>
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
 net/sctp/sm_make_chunk.c   | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4d7c855..0dfc5c1 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -524,7 +524,7 @@ int sctp_chunk_abandoned(struct sctp_chunk *);
 struct sctp_chunk {
 	struct list_head list;
 
-	atomic_t refcnt;
+	refcount_t refcnt;
 
 	/* How many times this chunk have been sent, for prsctp RTX policy */
 	int sent_count;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 3af4dd0..4e16b02 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1345,7 +1345,7 @@ struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
 	INIT_LIST_HEAD(&retval->transmitted_list);
 	INIT_LIST_HEAD(&retval->frag_list);
 	SCTP_DBG_OBJCNT_INC(chunk);
-	atomic_set(&retval->refcnt, 1);
+	refcount_set(&retval->refcnt, 1);
 
 nodata:
 	return retval;
@@ -1458,13 +1458,13 @@ void sctp_chunk_free(struct sctp_chunk *chunk)
 /* Grab a reference to the chunk. */
 void sctp_chunk_hold(struct sctp_chunk *ch)
 {
-	atomic_inc(&ch->refcnt);
+	refcount_inc(&ch->refcnt);
 }
 
 /* Release a reference to the chunk. */
 void sctp_chunk_put(struct sctp_chunk *ch)
 {
-	if (atomic_dec_and_test(&ch->refcnt))
+	if (refcount_dec_and_test(&ch->refcnt))
 		sctp_chunk_destroy(ch);
 }
 
-- 
2.7.4

