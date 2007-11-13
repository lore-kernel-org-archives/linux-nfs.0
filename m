From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/25] NFS: Change cb_getattrargs to pass "struct
	sockaddr *"	instead of sockaddr_in
Date: Tue, 13 Nov 2007 13:31:48 -0500
Message-ID: <20071113183148.5087.77719.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Y8-0000O0-Rl
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:48 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0YE-0007yr-KH
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:54 -0800
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

Change the addr field in the cb_getattrargs struct to a "struct sockaddr *"
to support non-IPv4 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/callback.h      |    2 +-
 fs/nfs/callback_proc.c |    2 +-
 fs/nfs/callback_xdr.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index c2bb14e..ec0ffd9 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -38,7 +38,7 @@ struct cb_compound_hdr_res {
 };
 
 struct cb_getattrargs {
-	struct sockaddr_in *addr;
+	struct sockaddr *addr;
 	struct nfs_fh fh;
 	uint32_t bitmap[2];
 };
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 019d939..2a1b14f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -25,7 +25,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client(args->addr, 4);
+	clp = nfs_find_client((struct sockaddr_in *)args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 97abd82..3eda1bc 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -176,7 +176,7 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr
 	status = decode_fh(xdr, &args->fh);
 	if (unlikely(status != 0))
 		goto out;
-	args->addr = svc_addr_in(rqstp);
+	args->addr = svc_addr(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
 	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
