From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd -  In READDIRPLUS reply, don't return a file handle for a mounted directory.
Date: Mon, 20 Oct 2003 11:21:39 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1ABOjr-0002Ss-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ABQq5-00070V-00
	for <nfs@lists.sourceforge.net>; Sun, 19 Oct 2003 20:36:13 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1ABOkA-0003CS-5F
	for nfs@lists.sourceforge.net; Sun, 19 Oct 2003 18:21:58 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Mon, 20 Oct 2003 11:21:39 +1000
To: Linus Torvalds <torvalds@osdl.org>
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

... as if "nohide" is in used, it will be the wrong filehandle, and
returning a filehandle is optional anyway.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2003-10-20 10:47:12.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2003-10-20 10:47:12.000000000 +1000
@@ -825,6 +825,8 @@ encode_entry(struct readdir_cd *ccd, con
 			dchild = lookup_one_len(name, dparent,namlen);
 		if (IS_ERR(dchild))
 			goto noexec;
+		if (d_mountpoint(dchild))
+			goto noexec;
 		if (fh_compose(&fh, exp, dchild, &cd->fh) != 0 || !dchild->d_inode)
 			goto noexec;
 		p = encode_post_op_attr(cd->rqstp, p, &fh);


-------------------------------------------------------
This SF.net email sponsored by: Enterprise Linux Forum Conference & Expo
The Event For Linux Datacenter Solutions & Strategies in The Enterprise 
Linux in the Boardroom; in the Front Office; & in the Server Room 
http://www.enterpriselinuxforum.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
