From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 8 - Fix byte counting for NFSv3 readdir replies
Date: Tue, 24 Jun 2003 16:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19Uhhd-0001qp-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Uhhy-0007S8-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 23:55:14 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 24 Jun 2003 16:55:01 +1000
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

### Comments for ChangeSet

The amount of free space is calculated wrongly so
nfsv3 readdir replies are shorted than they could be.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2003-06-24 14:09:17.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2003-06-24 16:29:05.000000000 +1000
@@ -780,7 +780,7 @@ encode_entry(struct readdir_cd *ccd, con
 {
 	struct nfsd3_readdirres *cd = container_of(ccd, struct nfsd3_readdirres, common);
 	u32		*p = cd->buffer;
-	int		buflen, slen, elen;
+	int		slen, elen;
 
 	if (cd->offset)
 		xdr_encode_hyper(cd->offset, (u64) offset);
@@ -797,7 +797,7 @@ encode_entry(struct readdir_cd *ccd, con
 	slen = XDR_QUADLEN(namlen);
 	elen = slen + NFS3_ENTRY_BAGGAGE
 		+ (plus? NFS3_ENTRYPLUS_BAGGAGE : 0);
-	if ((buflen = cd->buflen - elen) < 0) {
+	if (cd->buflen < elen) {
 		cd->common.err = nfserr_readdir_nospc;
 		return -EINVAL;
 	}
@@ -836,7 +836,7 @@ encode_entry(struct readdir_cd *ccd, con
 	}
 
 out:
-	cd->buflen = buflen;
+	cd->buflen -= p - cd->buffer;
 	cd->buffer = p;
 	cd->common.err = nfs_ok;
 	return 0;


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
