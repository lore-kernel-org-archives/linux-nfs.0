From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/15] LOCKD: Convert printk's to dprintk's in lockd
	XDR	routines
Date: Tue, 11 Sep 2007 18:01:15 -0400
Message-ID: <20070911220115.26136.81403.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDny-0006zk-2r
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:58 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDo2-0005fm-Je
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:02:02 -0700
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

Due to recent edict to remove or replace printk's that might flood the
system log.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/xdr.c  |    8 ++++----
 fs/lockd/xdr4.c |    8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 5316e30..633653b 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -62,8 +62,9 @@ static __be32 *nlm_decode_cookie(__be32 *p, struct nlm_cookie *c)
 	}
 	else 
 	{
-		printk(KERN_NOTICE
-			"lockd: bad cookie size %d (only cookies under %d bytes are supported.)\n", len, NLM_MAXCOOKIELEN);
+		dprintk("lockd: bad cookie size %d (only cookies under "
+			"%d bytes are supported.)\n",
+				len, NLM_MAXCOOKIELEN);
 		return NULL;
 	}
 	return p;
@@ -84,8 +85,7 @@ nlm_decode_fh(__be32 *p, struct nfs_fh *f)
 	unsigned int	len;
 
 	if ((len = ntohl(*p++)) != NFS2_FHSIZE) {
-		printk(KERN_NOTICE
-			"lockd: bad fhandle size %d (should be %d)\n",
+		dprintk("lockd: bad fhandle size %d (should be %d)\n",
 			len, NFS2_FHSIZE);
 		return NULL;
 	}
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index 846fc1d..43ff939 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -64,8 +64,9 @@ nlm4_decode_cookie(__be32 *p, struct nlm_cookie *c)
 	}
 	else 
 	{
-		printk(KERN_NOTICE
-			"lockd: bad cookie size %d (only cookies under %d bytes are supported.)\n", len, NLM_MAXCOOKIELEN);
+		dprintk("lockd: bad cookie size %d (only cookies under "
+			"%d bytes are supported.)\n",
+				len, NLM_MAXCOOKIELEN);
 		return NULL;
 	}
 	return p;
@@ -86,8 +87,7 @@ nlm4_decode_fh(__be32 *p, struct nfs_fh *f)
 	memset(f->data, 0, sizeof(f->data));
 	f->size = ntohl(*p++);
 	if (f->size > NFS_MAXFHSIZE) {
-		printk(KERN_NOTICE
-			"lockd: bad fhandle size %d (should be <=%d)\n",
+		dprintk("lockd: bad fhandle size %d (should be <=%d)\n",
 			f->size, NFS_MAXFHSIZE);
 		return NULL;
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
