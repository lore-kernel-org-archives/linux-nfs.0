From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 8 - Make sure unused bits of NFSv4 xfr buffered are zero..
Date: Wed, 18 Jun 2003 09:51:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQEj-00083g-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQBP-0002UU-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:48:11 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 09:47:01 +1000
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

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-06-18 09:24:29.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-06-18 09:30:43.000000000 +1000
@@ -1039,6 +1039,7 @@ nfsd4_decode_compound(struct nfsd4_compo
 	*p++ = htonl((u32)(n));					\
 } while (0)
 #define WRITEMEM(ptr,nbytes)     do {				\
+	*(p + XDR_QUADLEN(nbytes) -1) = 0;                      \
 	memcpy(p, ptr, nbytes);					\
 	p += XDR_QUADLEN(nbytes);				\
 } while (0)


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
