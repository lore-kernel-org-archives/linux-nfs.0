From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 54] Fix error reported by nfsd which it gets ETXTBSY
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-00016r-DV@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrl-00026R-Ax
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrj-0005C1-RC
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
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


ETXTBSY doesn't have a direct anaolog in NFS, so just map it
to nfserr_io.
As this is the default error code this does not change the 
operation of nfsd.  It only reduces logging.

From: "G. Allen Morris III" <gam3@gam3.net>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfsproc.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2005-03-07 11:32:36.000000000 +1100
+++ ./fs/nfsd/nfsproc.c	2005-03-07 11:32:36.000000000 +1100
@@ -590,6 +590,7 @@ nfserrno (int errno)
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
 		{ nfserr_badname, -ESRCH },
+		{ nfserr_io, -ETXTBSY },
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ -1, -EIO }
 	};


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
