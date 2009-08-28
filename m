From: andros@netapp.com
Subject: [PATCH 1/4] nfsd41: bound forechannel drc size by memory usage
Date: Fri, 28 Aug 2009 08:45:01 -0400
Message-ID: <1251463504-3376-2-git-send-email-andros@netapp.com>
References: <1251463504-3376-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016AbZIAVC3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 17:02:29 -0400
In-Reply-To: <1251463504-3376-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

By using the requested ca_maxresponsesize_cached * ca_maxresponses to bound
a forechannel drc request size, clients can tailor a session to usage.

For example, an I/O session (READ/WRITE only) can have a much smaller
ca_maxresponsesize_cached (for only WRITE compound responses) and a lot larger
ca_maxresponses to service a large in-flight data window.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   66 ++++++++++++++++++++++++++++++++------------
 include/linux/nfsd/state.h |    8 ++++-
 2 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b44a2cf..02b3ddd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -414,34 +414,64 @@ gen_sessionid(struct nfsd4_session *ses)
 }
 
 /*
- * Give the client the number of slots it requests bound by
- * NFSD_MAX_SLOTS_PER_SESSION and by nfsd_drc_max_mem.
+ * The protocol defines ca_maxresponssize_cached to include the size of
+ * the rpc header, but all we need to cache is the data starting after
+ * the end of the initial SEQUENCE operation--the rest we regenerate
+ * each time.  Therefore we can advertise a ca_maxresponssize_cached
+ * value that is the number of bytes in our cache plus a few additional
+ * bytes.  In order to stay on the safe side, and not promise more than
+ * we can cache, those additional bytes must be the minimum possible: 24
+ * bytes of rpc header (xid through accept state, with AUTH_NULL
+ * verifier), 12 for the compound header (with zero-length tag), and 44
+ * for the SEQUENCE op response:
+ */
+#define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
+
+/*
+ * Give the client the number of ca_maxresponsesize_cached slots it
+ * requests, of size bounded by NFSD_SLOT_CACHE_SIZE,
+ * NFSD_MAX_MEM_PER_SESSION, and nfsd_drc_max_mem. Do not allow more
+ * than NFSD_MAX_SLOTS_PER_SESSION.
  *
- * If we run out of reserved DRC memory we should (up to a point) re-negotiate
- * active sessions and reduce their slot usage to make rooom for new
- * connections. For now we just fail the create session.
+ * If we run out of reserved DRC memory we should (up to a point)
+ * re-negotiate active sessions and reduce their slot usage to make
+ * rooom for new connections. For now we just fail the create session.
  */
-static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
+static int set_forechannel_drc_size(struct nfsd4_channel_attrs *fchan)
 {
-	int mem;
+	int mem, size = fchan->maxresp_cached;
 
 	if (fchan->maxreqs < 1)
 		return nfserr_inval;
-	else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
-		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
 
-	mem = fchan->maxreqs * NFSD_SLOT_CACHE_SIZE;
+	if (size < NFSD_MIN_HDR_SEQ_SZ)
+		size = NFSD_MIN_HDR_SEQ_SZ;
+	size -= NFSD_MIN_HDR_SEQ_SZ;
+	if (size > NFSD_SLOT_CACHE_SIZE)
+		size = NFSD_SLOT_CACHE_SIZE;
+
+	/* bound the maxreqs by NFSD_MAX_MEM_PER_SESSION */
+	mem = fchan->maxreqs * size;
+	if (mem > NFSD_MAX_MEM_PER_SESSION) {
+		fchan->maxreqs = NFSD_MAX_MEM_PER_SESSION / size;
+		if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
+			fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
+		mem = fchan->maxreqs * size;
+	}
 
 	spin_lock(&nfsd_drc_lock);
-	if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem)
-		mem = ((nfsd_drc_max_mem - nfsd_drc_mem_used) /
-				NFSD_SLOT_CACHE_SIZE) * NFSD_SLOT_CACHE_SIZE;
+	/* bound the total session drc memory ussage */
+	if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem) {
+		fchan->maxreqs = (nfsd_drc_max_mem - nfsd_drc_mem_used) / size;
+		mem = fchan->maxreqs * size;
+	}
 	nfsd_drc_mem_used += mem;
 	spin_unlock(&nfsd_drc_lock);
 
-	fchan->maxreqs = mem / NFSD_SLOT_CACHE_SIZE;
 	if (fchan->maxreqs == 0)
 		return nfserr_resource;
+
+	fchan->maxresp_cached = size + NFSD_MIN_HDR_SEQ_SZ;
 	return 0;
 }
 
@@ -466,9 +496,6 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 		fchan->maxresp_sz = maxcount;
 	session_fchan->maxresp_sz = fchan->maxresp_sz;
 
-	session_fchan->maxresp_cached = NFSD_SLOT_CACHE_SIZE;
-	fchan->maxresp_cached = session_fchan->maxresp_cached;
-
 	/* Use the client's maxops if possible */
 	if (fchan->maxops > NFSD_MAX_OPS_PER_COMPOUND)
 		fchan->maxops = NFSD_MAX_OPS_PER_COMPOUND;
@@ -478,9 +505,12 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 	 * recover pages from existing sessions. For now fail session
 	 * creation.
 	 */
-	status = set_forechannel_maxreqs(fchan);
+	status = set_forechannel_drc_size(fchan);
 
+	session_fchan->maxresp_cached = fchan->maxresp_cached;
 	session_fchan->maxreqs = fchan->maxreqs;
+
+	dprintk("%s status %d\n", __func__, status);
 	return status;
 }
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index fb0c404..ff0b771 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -92,13 +92,17 @@ struct nfs4_cb_conn {
 	struct rpc_cred	*	cb_cred;
 };
 
-/* Maximum number of slots per session. 128 is useful for long haul TCP */
-#define NFSD_MAX_SLOTS_PER_SESSION	128
+/* Maximum number of slots per session. 160 is useful for long haul TCP */
+#define NFSD_MAX_SLOTS_PER_SESSION     160
 /* Maximum number of pages per slot cache entry */
 #define NFSD_PAGES_PER_SLOT	1
 #define NFSD_SLOT_CACHE_SIZE		PAGE_SIZE
 /* Maximum number of operations per session compound */
 #define NFSD_MAX_OPS_PER_COMPOUND	16
+/* Maximum number of NFSD_SLOT_CACHE_SIZE slots per session */
+#define NFSD_CACHE_SIZE_SLOTS_PER_SESSION	32
+#define NFSD_MAX_MEM_PER_SESSION  \
+		(NFSD_CACHE_SIZE_SLOTS_PER_SESSION * NFSD_SLOT_CACHE_SIZE)
 
 struct nfsd4_cache_entry {
 	__be32		ce_status;
-- 
1.6.2.5

