From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 17 of 23] Attempt to hand out a delegation
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002eS-U8@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbJ-000596-78
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:25 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbI-0004C7-22
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:24 -0800
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


Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:50.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:50.000000000 +1100
@@ -1642,6 +1642,65 @@ nfs4_set_claim_prev(struct nfsd4_open *o
 }
 
 /*
+ * Attempt to hand out a delegation.
+ */
+static void
+nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_stateid *stp, int *flag)
+{
+	struct nfs4_delegation *dp;
+	struct nfs4_stateowner *sop = stp->st_stateowner;
+	struct nfs4_callback *cb = &sop->so_client->cl_callback;
+	struct file_lock fl, *flp = &fl;
+	int status;
+
+	if (*flag == DONT_DELEGATE) {
+		*flag = NFS4_OPEN_DELEGATE_NONE;
+		return;
+	}
+
+	/* set flag */
+	*flag = NFS4_OPEN_DELEGATE_NONE;
+	if (open->op_claim_type != NFS4_OPEN_CLAIM_NULL
+	     || !atomic_read(&cb->cb_set) || !sop->so_confirmed)
+		return;
+
+	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
+		*flag = NFS4_OPEN_DELEGATE_READ;
+
+	else if (!(open->op_share_access & NFS4_SHARE_ACCESS_READ))
+		*flag = NFS4_OPEN_DELEGATE_WRITE;
+
+	if (!(dp = alloc_init_deleg(sop->so_client, stp->st_file, fh, *flag)))
+		return;
+	locks_init_lock(&fl);
+	fl.fl_lmops = &nfsd_lease_mng_ops;
+	fl.fl_flags = FL_LEASE;
+	fl.fl_end = OFFSET_MAX;
+	fl.fl_owner =  (fl_owner_t)dp;
+	fl.fl_file = stp->st_vfs_file;
+	fl.fl_pid = current->tgid;
+
+	if ((status = setlease(stp->st_vfs_file,
+		*flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK, &flp))) {
+		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
+		list_del(&dp->dl_del_perfile);
+		list_del(&dp->dl_del_perclnt);
+		kfree(dp);
+		free_delegation++;
+		*flag = NFS4_OPEN_DELEGATE_NONE;
+		return;
+	}
+
+	memcpy(&open->op_delegate_stateid, &dp->dl_stateid, sizeof(dp->dl_stateid));
+
+	dprintk("NFSD: delegation stateid=(%08x/%08x/%08x/%08x)\n\n",
+	             dp->dl_stateid.si_boot,
+	             dp->dl_stateid.si_stateownerid,
+	             dp->dl_stateid.si_fileid,
+	             dp->dl_stateid.si_generation);
+}
+
+/*
  * called with nfs4_lock_state() held.
  */
 int


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
