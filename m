From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 6 - Fix exit-without-free bug in nfsd
Date: Wed, 12 Mar 2003 16:35:28 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18sytk-0005Qr-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18syts-0000Dc-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 21:35:36 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 12 Mar 2003 16:35:28 +1100
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Here are 6 patches for kNFSd in 2.5.latest.

A few bug fixes, and a new CROSSMNT export flag so that (once you have new
user-space tools) you can export a filesystem with "crossmnt" and all
filesystems below it are automatically exported.

### Comments for ChangeSet



 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-03-12 15:00:41.000000000 +1100
+++ ./fs/nfsd/export.c	2003-03-12 15:01:07.000000000 +1100
@@ -294,7 +294,9 @@ int svc_export_parse(struct cache_detail
 
 	/* client */
 	len = qword_get(&mesg, buf, PAGE_SIZE);
-	if (len <= 0) return -EINVAL;
+	err = -EINVAL;
+	if (len <= 0) goto out;
+
 	err = -ENOENT;
 	dom = auth_domain_find(buf);
 	if (!dom)


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
