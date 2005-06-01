From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 002 of 28] nfs4: hold filp while reading or writing
Date: Thu, 02 Jun 2005 08:50:55 +1000
Message-ID: <E1Ddc35-0006hg-Vn@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3J-0005w2-5h
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:09 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0005M8-4S
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:09 -0700
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


We're trying to read and write from a struct file that we may not hold a
reference to any more (since a close could be processed as soon as we drop the
state lock).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-05-31 14:20:58.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2005-05-31 14:20:58.000000000 +1000
@@ -45,6 +45,7 @@
 #include <linux/param.h>
 #include <linux/major.h>
 #include <linux/slab.h>
+#include <linux/file.h>
 
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
@@ -477,26 +478,27 @@ static inline int
 nfsd4_read(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_read *read)
 {
 	int status;
-	struct file *filp = NULL;
 
 	/* no need to check permission - this will be done in nfsd_read() */
 
+	read->rd_filp = NULL;
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
 	nfs4_lock_state();
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(current_fh, &read->rd_stateid,
-					CHECK_FH | RD_STATE, &filp))) {
+				CHECK_FH | RD_STATE, &read->rd_filp))) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
+	if (read->rd_filp)
+		get_file(read->rd_filp);
 	status = nfs_ok;
 out:
 	nfs4_unlock_state();
 	read->rd_rqstp = rqstp;
 	read->rd_fhp = current_fh;
-	read->rd_filp = filp;
 	return status;
 }
 
@@ -633,6 +635,8 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		goto out;
 	}
+	if (filp)
+		get_file(filp);
 	nfs4_unlock_state();
 
 	write->wr_bytes_written = write->wr_buflen;
@@ -644,6 +648,8 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	status =  nfsd_write(rqstp, current_fh, filp, write->wr_offset,
 			write->wr_vec, write->wr_vlen, write->wr_buflen,
 			&write->wr_how_written);
+	if (filp)
+		fput(filp);
 
 	if (status == nfserr_symlink)
 		status = nfserr_inval;
@@ -932,6 +938,9 @@ encode_op:
 			nfs4_put_stateowner(replay_owner);
 			replay_owner = NULL;
 		}
+		/* XXX Ugh, we need to get rid of this kind of special case: */
+		if (op->opnum == OP_READ && op->u.read.rd_filp)
+			fput(op->u.read.rd_filp);
 	}
 
 out:


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
