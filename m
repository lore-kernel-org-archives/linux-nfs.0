From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 12] Subject: [PATCH 2.6] SGI 921857: find broken with nohide on NFSv3
Date: Tue, 08 Feb 2005 14:06:53 +1100
Message-ID: <E1CyLiH-0006VC-TO@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLir-0006vD-TT
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:29 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLiq-0004Fm-Bo
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:29 -0800
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


This patch makes "find" work when traversing nohide exports on NFSv3.
The READDIRPLUS reply needs to not return a file handle for the ".."
entry when the directory is a server side mountpoint, which would be
the directory itself, otherwise the client remembers the wrong file
handle and gets confused.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs3xdr.c |    5 +++++
 1 files changed, 5 insertions(+)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2005-02-07 15:03:30.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2005-02-07 15:03:30.000000000 +1100
@@ -843,6 +843,11 @@ compose_entry_fh(struct nfsd3_readdirres
 	if (isdotent(name, namlen)) {
 		if (namlen == 2) {
 			dchild = dget_parent(dparent);
+			if (dchild == dparent) {
+				/* filesystem root - cannot return filehandle for ".." */
+				dput(dchild);
+				return 1;
+			}
 		} else
 			dchild = dget(dparent);
 	} else


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
