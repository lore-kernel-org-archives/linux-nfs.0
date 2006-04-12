From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fs/nfsd/nfs4acl.c: remove the unused EXPORT_SYMBOL's
Date: Wed, 12 Apr 2006 22:56:33 +0200
Message-ID: <20060412205633.GF6517@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FTmP1-00021o-ME
	for nfs@lists.sourceforge.net; Wed, 12 Apr 2006 13:57:27 -0700
Received: from emailhub.stusta.mhn.de ([141.84.69.5] helo=mailout.stusta.mhn.de)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FTmOz-0002uT-Sr
	for nfs@lists.sourceforge.net; Wed, 12 Apr 2006 13:57:27 -0700
To: neilb@cse.unsw.edu.au
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
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
