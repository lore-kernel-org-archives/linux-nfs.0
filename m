From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 48 of 54] nfsd4: allow io to use deleg stateid file
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019v-AP@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrq-00027o-Mt
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0005Cw-77
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
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


Allow io using a delegation stateid to proceed without the need to reopen the
file, as is done already with open stateid's.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:33:39.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:34:30.000000000 +1100
@@ -2068,6 +2068,8 @@ nfs4_preprocess_stateid_op(struct svc_fh
 			atomic_set(&dp->dl_state,NFS4_RECALL_COMPLETE);
 			release_delegation(dp);
 		}
+		if (filpp)
+			*filpp = dp->dl_vfs_file;
 	}
 	status = nfs_ok;
 out:


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
