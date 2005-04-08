From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 010 of 16] nfsd4: block metadata ops during grace period
Date: Fri, 08 Apr 2005 11:00:17 +1000
Message-ID: <E1DJhr7-0006dy-6u@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Tx-AQ
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikL-0000uM-FX
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



We currently return err_grace if a user attempts a non-reclaim open during the
grace period.  But we also need to prevent renames and removes, at least, to
ensure clients have the chance to recover state on files before they are moved
or deleted.

Of course, local users could also do renames and removes during the lease
period, and there's not much we can do about that.  This at least will help
with remote users.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |    5 +++++
 1 files changed, 5 insertions(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-04-08 10:42:30.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2005-04-08 10:44:51.000000000 +1000
@@ -536,6 +536,8 @@ nfsd4_remove(struct svc_rqst *rqstp, str
 {
 	int status;
 
+	if (nfs4_in_grace())
+		return nfserr_grace;
 	status = nfsd_unlink(rqstp, current_fh, 0, remove->rm_name, remove->rm_namelen);
 	if (status == nfserr_symlink)
 		return nfserr_notdir;
@@ -554,6 +556,9 @@ nfsd4_rename(struct svc_rqst *rqstp, str
 
 	if (!save_fh->fh_dentry)
 		return status;
+	if (nfs4_in_grace() && !(save_fh->fh_export->ex_flags
+					& NFSEXP_NOSUBTREECHECK))
+		return nfserr_grace;
 	status = nfsd_rename(rqstp, save_fh, rename->rn_sname,
 			     rename->rn_snamelen, current_fh,
 			     rename->rn_tname, rename->rn_tnamelen);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
