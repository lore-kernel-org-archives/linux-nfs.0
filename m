From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 16 of 23] Helper functions for deciding to grant a delegation.
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002eO-SC@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAb2-00058K-An
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:08 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAb0-000650-Uz
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:08 -0800
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
 ./fs/nfsd/nfs4state.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:36.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:50.000000000 +1100
@@ -1504,6 +1504,43 @@ out:
 }
 
 static int
+nfs4_deleg_conflict(u32 share, u32 dtype)
+{
+	return (((share & NFS4_SHARE_ACCESS_WRITE) &&
+		dtype == NFS4_OPEN_DELEGATE_READ) ||
+		((share & NFS4_SHARE_ACCESS_READ) &&
+		dtype == NFS4_OPEN_DELEGATE_WRITE));
+}
+
+#define DONT_DELEGATE  8
+
+/*
+ * nfs4_check_deleg_recall()
+ *
+ * Test any delegation that is currently within an incompleted recalled
+ * state, and return NFSERR_DELAY for conflicting open share.
+ * flag is set to DONT_DELEGATE for shares that match the deleg type.
+ */
+static int
+nfs4_check_deleg_recall(struct nfs4_file *fp, struct nfsd4_open *op, int *flag)
+{
+	struct nfs4_delegation *dp;
+	int status = 0;
+
+	list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
+		dprintk("NFSD: found delegation %p with dl_state %d\n",
+		 	                 dp, atomic_read(&dp->dl_state));
+		if (atomic_read(&dp->dl_state) == NFS4_RECALL_IN_PROGRESS) {
+			if(nfs4_deleg_conflict(op->op_share_access, dp->dl_type))
+				status = nfserr_jukebox;
+			else
+				*flag = DONT_DELEGATE;
+		}
+	}
+	return status;
+}
+
+static int
 nfs4_check_open(struct nfs4_file *fp, struct nfs4_stateowner *sop, struct nfsd4_open *open, struct nfs4_stateid **stpp)
 {
 	struct nfs4_stateid *local;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
