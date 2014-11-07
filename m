Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:61939 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbaKGTod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Nov 2014 14:44:33 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 3/3] nfsd: Add DEALLOCATE support
Date: Fri, 7 Nov 2014 14:44:27 -0500
Message-ID: <1415389467-16547-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1415389467-16547-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1415389467-16547-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

DEALLOCATE only returns a status value, meaning we can use the noop()
xdr encoder to reply to the client.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c | 15 +++++++++++++++
 fs/nfsd/nfs4xdr.c  |  2 +-
 fs/nfsd/xdr4.h     |  1 +
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a261f18..74fb15e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -33,6 +33,7 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 #include <linux/file.h>
+#include <linux/falloc.h>
 #include <linux/slab.h>
 
 #include "idmap.h"
@@ -1044,6 +1045,14 @@ nfsd4_allocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 static __be32
+nfsd4_deallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		 struct nfsd4_fallocate *fallocate)
+{
+	return nfsd4_fallocate(rqstp, cstate, fallocate,
+			       FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE);
+}
+
+static __be32
 nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_seek *seek)
 {
@@ -1965,6 +1974,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_ALLOCATE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
 	},
+	[OP_DEALLOCATE] = {
+		.op_func = (nfsd4op_func)nfsd4_deallocate,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_DEALLOCATE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a60cff8..0622d4f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1624,7 +1624,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index eeaa0d0..90a5925 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -494,6 +494,7 @@ struct nfsd4_op {
 
 		/* NFSv4.2 */
 		struct nfsd4_fallocate		allocate;
+		struct nfsd4_fallocate		deallocate;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
-- 
2.1.3

