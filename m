From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/27] NFS: Change sign of some loop indices in
	nfs4xdr.c
Date: Fri, 26 Oct 2007 13:32:08 -0400
Message-ID: <20071026173208.31475.1559.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2f-0007Kn-J3
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:17 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2l-0006LN-0w
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:23 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Nit: Eliminate some mixed sign comparisons in loop indices.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2e1fe17..eae46f0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2515,14 +2515,12 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 
 static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 {
-	int n;
+	u32 n;
 	__be32 *p;
 	int status = 0;
 
 	READ_BUF(4);
 	READ32(n);
-	if (n < 0)
-		goto out_eio;
 	if (n == 0)
 		goto root_path;
 	dprintk("path ");
@@ -2579,13 +2577,11 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		goto out_eio;
 	res->nlocations = 0;
 	while (res->nlocations < n) {
-		int m;
+		u32 m;
 		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
 
 		READ_BUF(4);
 		READ32(m);
-		if (m <= 0)
-			goto out_eio;
 
 		loc->nservers = 0;
 		dprintk("%s: servers ", __FUNCTION__);
@@ -2598,8 +2594,12 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			if (loc->nservers < NFS4_FS_LOCATION_MAXSERVERS)
 				loc->nservers++;
 			else {
-				int i;
-				dprintk("%s: using first %d of %d servers returned for location %d\n", __FUNCTION__, NFS4_FS_LOCATION_MAXSERVERS, m, res->nlocations);
+				unsigned int i;
+				dprintk("%s: using first %u of %u servers "
+					"returned for location %u\n",
+						__FUNCTION__,
+						NFS4_FS_LOCATION_MAXSERVERS,
+						m, res->nlocations);
 				for (i = loc->nservers; i < m; i++) {
 					unsigned int len;
 					char *data;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
