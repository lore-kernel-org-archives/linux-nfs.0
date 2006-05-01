From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fs/nfsd/nfs4acl.c: remove the unused EXPORT_SYMBOL's
Date: Mon, 1 May 2006 09:11:22 +0200
Message-ID: <20060501071122.GB3570@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FaSZq-0000cS-8t
	for nfs@lists.sourceforge.net; Mon, 01 May 2006 00:12:14 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FaSZq-0005d9-5E
	for nfs@lists.sourceforge.net; Mon, 01 May 2006 00:12:14 -0700
Received: from emailhub.stusta.mhn.de ([141.84.69.5] helo=mailout.stusta.mhn.de)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FaSZp-0006P1-JT
	for nfs@lists.sourceforge.net; Mon, 01 May 2006 00:12:14 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This patch removes the unused EXPORT_SYMBOL's from fs/nfsd/nfs4acl.c.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 12 Apr 2006

 fs/nfsd/nfs4acl.c |    8 --------
 1 file changed, 8 deletions(-)

--- linux-2.6.17-rc1-mm2-full/fs/nfsd/nfs4acl.c.old	2006-04-12 22:42:17.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/fs/nfsd/nfs4acl.c	2006-04-12 22:42:29.000000000 +0200
@@ -821,9 +821,6 @@
 	return -1;
 }
 
-EXPORT_SYMBOL(nfs4_acl_posix_to_nfsv4);
-EXPORT_SYMBOL(nfs4_acl_nfsv4_to_posix);
-
 struct nfs4_acl *
 nfs4_acl_new(void)
 {
@@ -947,8 +944,3 @@
 	}
 }
 
-EXPORT_SYMBOL(nfs4_acl_new);
-EXPORT_SYMBOL(nfs4_acl_free);
-EXPORT_SYMBOL(nfs4_acl_add_ace);
-EXPORT_SYMBOL(nfs4_acl_get_whotype);
-EXPORT_SYMBOL(nfs4_acl_write_who);




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
