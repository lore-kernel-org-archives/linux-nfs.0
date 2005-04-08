From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 003 of 16] nfsd4: fix struct file leak
Date: Fri, 08 Apr 2005 11:00:15 +1000
Message-ID: <E1DJhr5-0006dW-Vv@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikP-0006UJ-3d
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:25 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikO-0000uV-Ac
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
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



We were failing to close on an error path, resulting in a leak of struct files
which could take a v4 server down fairly quickly....
So call nfs4_close_delegation instead of just open-coding parts of it.

Simplify the cleanup on delegation failure while we're at it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:31:12.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:35:24.000000000 +1000
@@ -190,7 +190,8 @@ nfs4_close_delegation(struct nfs4_delega
 	dp->dl_vfs_file = NULL;
 	/* The following nfsd_close may not actually close the file,
 	 * but we want to remove the lease in any case. */
-	setlease(filp, F_UNLCK, &dp->dl_flock);
+	if (dp->dl_flock)
+		setlease(filp, F_UNLCK, &dp->dl_flock);
 	nfsd_close(filp);
 	vfsclose++;
 }
@@ -1673,10 +1674,7 @@ nfs4_open_delegation(struct svc_fh *fh, 
 	if ((status = setlease(stp->st_vfs_file,
 		flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK, &flp))) {
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
-		list_del(&dp->dl_del_perfile);
-		list_del(&dp->dl_del_perclnt);
-		nfs4_put_delegation(dp);
-		free_delegation++;
+		unhash_delegation(dp);
 		flag = NFS4_OPEN_DELEGATE_NONE;
 		goto out;
 	}


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
