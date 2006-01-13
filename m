From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 020 of 26] nfsd4: fix open_downgrade
Date: Fri, 13 Jan 2006 12:01:04 +1100
Message-ID: <1060113010104.23168@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJc-0002b5-1o
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:16 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJW-0006pH-Jd
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:16 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:07 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:04 +1100
To: nfs@lists.sourceforge.net
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


Bad bookkeeping of the share reservations when handling open upgrades
was causing open downgrade to fail.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:09.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:09.000000000 +1100
@@ -1609,26 +1609,26 @@ nfs4_upgrade_open(struct svc_rqst *rqstp
 {
 	struct file *filp = stp->st_vfs_file;
 	struct inode *inode = filp->f_dentry->d_inode;
-	unsigned int share_access;
+	unsigned int share_access, new_writer;
 	int status;
 
 	set_access(&share_access, stp->st_access_bmap);
-	share_access = ~share_access;
-	share_access &= open->op_share_access;
-
-	if (!(share_access & NFS4_SHARE_ACCESS_WRITE))
-		return nfsd4_truncate(rqstp, cur_fh, open);
+	new_writer = (~share_access) & open->op_share_access
+			& NFS4_SHARE_ACCESS_WRITE;
 
-	status = get_write_access(inode);
-	if (status)
-		return nfserrno(status);
+	if (new_writer) {
+		status = get_write_access(inode);
+		if (status)
+			return nfserrno(status);
+	}
 	status = nfsd4_truncate(rqstp, cur_fh, open);
 	if (status) {
-		put_write_access(inode);
+		if (new_writer)
+			put_write_access(inode);
 		return status;
 	}
 	/* remember the open */
-	filp->f_mode = (filp->f_mode | FMODE_WRITE) & ~FMODE_READ;
+	filp->f_mode |= open->op_share_access;
 	set_bit(open->op_share_access, &stp->st_access_bmap);
 	set_bit(open->op_share_deny, &stp->st_deny_bmap);
 


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
