From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 37 of 54] nfsd4: rename release_stateid_lockowner
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00019C-NG@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrs-00028D-Im
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrq-0007tn-PF
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
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



The name makes it sounds like the job of this function is to release a single
lockowner; the plural seems clearer.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:25:47.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:26:15.000000000 +1100
@@ -81,7 +81,7 @@ u32 free_delegation= 0;
 struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static void release_delegation(struct nfs4_delegation *dp);
-static void release_stateid_lockowner(struct nfs4_stateid *open_stp);
+static void release_stateid_lockowners(struct nfs4_stateid *open_stp);
 
 /* Locking:
  *
@@ -207,7 +207,7 @@ release_delegation(struct nfs4_delegatio
 		struct file *filp = dp->dl_stp->st_vfs_file;
 
 		dprintk("NFSD: release_delegation CLOSE\n");
-		release_stateid_lockowner(dp->dl_stp);
+		release_stateid_lockowners(dp->dl_stp);
 		kfree(dp->dl_stp);
 		dp->dl_stp = NULL;
 		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
@@ -1089,7 +1089,7 @@ alloc_init_open_stateowner(unsigned int 
 }
 
 static void
-release_stateid_lockowner(struct nfs4_stateid *open_stp)
+release_stateid_lockowners(struct nfs4_stateid *open_stp)
 {
 	struct nfs4_stateowner *lock_sop;
 
@@ -1177,7 +1177,7 @@ release_stateid(struct nfs4_stateid *stp
 				return;
 			}
 		}
-		release_stateid_lockowner(stp);
+		release_stateid_lockowners(stp);
 		nfsd_close(stp->st_vfs_file);
 		vfsclose++;
 	} else if ((stp->st_vfs_set) && (flags & LOCK_STATE)) {


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
