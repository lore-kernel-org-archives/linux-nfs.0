Return-Path: <nfsv4-bounces@ietf.org>
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 31 Jan 2011 16:03:08 +0200
Message-Id: <1296482588-4140-2-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1296482588-4140-1-git-send-email-bhalevy@panasas.com>
References: <1296482588-4140-1-git-send-email-bhalevy@panasas.com>
Cc: nfsv4@ietf.org
Subject: [nfsv4] [PATCH 2/2] layout-sim: allow non-conflicting LAYOUTGETs
	while in layout recall
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 server.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/server.c b/server.c
index b9c90de..7119ab2 100644
--- a/server.c
+++ b/server.c
@@ -65,6 +65,7 @@ verify_stateid(struct msg *m)
 			/* FIXME: use an actual limit on parallelism */
 			return m->status = NFS4ERR_OLD_STATEID;
 		} else if (m->stateid.type == LAYOUT_STATEID) {
+			/* FIXME: is this specified for LAYOUTRETURN. */
 			if (srv_layout.layout_recall_msg &&
 		            m->stateid.seq < srv_layout.layout_recall_msg->stateid.seq)
 				return m->status = NFS4ERR_OLD_STATEID;
@@ -78,10 +79,26 @@ verify_stateid(struct msg *m)
 	return 0;
 }
 
+static bool
+is_conflicting(struct layout_range *lr, struct layout_range *r)
+{
+	if (lr->iomode != IOMODE_ANY && lr->iomode != r->iomode)
+		return false;
+	if (r->offset >= lr->offset)
+		return (lr->length == NFS4_MAX_UINT64) ||
+		       (lr->offset + lr->length > r->offset);
+	else
+		return (r->length == NFS4_MAX_UINT64) ||
+		       (r->offset + r->length > lr->offset);
+}
+
 static void
 srv_recv_layoutget(struct msg *m)
 {
-	if (srv_layout.layout_recall_msg) {
+	struct msg *lrm = srv_layout.layout_recall_msg;
+
+	/* See section 12.5.5.2.1.3 */
+	if (lrm && is_conflicting(&lrm->range, &m->range)) {
 		m->status = NFS4ERR_RECALLCONFLICT;
 		goto out;
 	}
-- 
1.7.3.4

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
