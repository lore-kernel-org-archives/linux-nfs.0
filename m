From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 27 of 34 - Corrects an error return for OP_OPEN_CONFIRM.
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006Kd-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xP-3S
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPqf-0005hm-NE
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:53 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:50:42 +1100
To: Andrew Morton <akpm@osdl.org>
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


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |    4 ++++
 1 files changed, 4 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:35.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:35.000000000 +1100
@@ -1533,6 +1533,10 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 	dprintk("NFSD: nfsd4_open_confirm on file %.*s\n",
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
+
+	if ((status = fh_verify(rqstp, current_fh, S_IFREG, 0))) 
+		goto out;
+
 	oc->oc_stateowner = NULL;
 	nfs4_lock_state();
 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
