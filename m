From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 17 of 34 - correct symlink related error returns.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006JB-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xi-P1
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPf2-0002QF-AS
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:52 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:42 +1100
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


unlike v2/v3, nfsv4 returns nfserr_inval when attempting to read, write,
commit or test lock a symlink. nfsv4 does return nfserr_symlink
on lookup and open, so a simple fix in fh_verify() will not work.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c  |   14 +++++++++++---
 ./fs/nfsd/nfs4state.c |    2 ++
 ./fs/nfsd/nfs4xdr.c   |    2 ++
 3 files changed, 15 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:33.000000000 +1100
@@ -224,11 +224,16 @@ nfsd4_access(struct svc_rqst *rqstp, str
 static inline int
 nfsd4_commit(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_commit *commit)
 {
+	int status;
+
 	u32 *p = (u32 *)commit->co_verf.data;
 	*p++ = nfssvc_boot.tv_sec;
 	*p++ = nfssvc_boot.tv_usec;
 
-	return nfsd_commit(rqstp, current_fh, commit->co_offset, commit->co_count);
+	status = nfsd_commit(rqstp, current_fh, commit->co_offset, commit->co_count);
+	if (status == nfserr_symlink)
+		status = nfserr_inval;
+	return status;
 }
 
 static inline int
@@ -558,9 +563,12 @@ zero_stateid:
 	*p++ = nfssvc_boot.tv_sec;
 	*p++ = nfssvc_boot.tv_usec;
 
-	return (nfsd_write(rqstp, current_fh, write->wr_offset,
+	status =  nfsd_write(rqstp, current_fh, write->wr_offset,
 			  write->wr_vec, write->wr_vlen, write->wr_buflen,
-			  &write->wr_how_written));
+			  &write->wr_how_written);
+	if (status == nfserr_symlink)
+		status = nfserr_inval;
+	return status;
 out:
 	nfs4_unlock_state();
 	return status;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:32.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:33.000000000 +1100
@@ -1973,6 +1973,8 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 
 	if ((status = fh_verify(rqstp, current_fh, S_IFREG, 0))) {
 		printk("NFSD: nfsd4_lockt: fh_verify() failed!\n");
+		if (status == nfserr_symlink)
+			status = nfserr_inval;
 		goto out;
 	}
 

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:33.000000000 +1100
@@ -2005,6 +2005,8 @@ nfsd4_encode_read(struct nfsd4_compoundr
 			   read->rd_offset,
 			   read->rd_iov, read->rd_vlen,
 			   &maxcount);
+	if (nfserr == nfserr_symlink)
+		nfserr = nfserr_inval;
 	if (nfserr)
 		return nfserr;
 	eof = (read->rd_offset + maxcount >= read->rd_fhp->fh_dentry->d_inode->i_size);


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
