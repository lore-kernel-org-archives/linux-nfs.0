From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 5] knfsd: nfsd4: fix owner-override on open
Date: Tue, 17 Oct 2006 09:30:09 +1000
Message-ID: <1061016233009.11318@suse.de>
References: <20061017092702.11224.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZbuT-00016O-59
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:17 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZbuT-00071r-54
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:18 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: "J. Bruce Fields" <bfields@fieldses.org>
If a client creates a file using an open which sets the mode to 000, or if
a chmod changes permissions after a file is opened, then situations may
arise where an NFS client knows that some IO is permitted (because a
process holds the file open), but the NFS server does not (because it
doesn't know about the open, and only sees that the IO conflicts with the
current mode of the file).

As a hack to solve this problem, NFS servers normally allow the owner to
override permissions on IO.  The client can still enforce correct
permissions-checking on open by performing an explicit access check.

In NFSv4 the client can rely on the explicit on-the-wire open instead of an
access check.

Therefore we should not be allowing the owner to override permissions on an
over-the-wire open!

However, we should still allow the owner to override permissions in the case
where the client is claiming an open that it already made either before a
reboot, or while it was holding a delegation.

Thanks to Jim Rees for reporting the bug.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-10-17 09:02:22.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2006-10-17 09:02:26.000000000 +1000
@@ -68,20 +68,18 @@ fh_dup2(struct svc_fh *dst, struct svc_f
 }
 
 static int
-do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
+do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open, int accmode)
 {
-	int accmode, status;
+	int status;
 
 	if (open->op_truncate &&
 		!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
 		return nfserr_inval;
 
-	accmode = MAY_NOP;
 	if (open->op_share_access & NFS4_SHARE_ACCESS_READ)
-		accmode = MAY_READ;
+		accmode |= MAY_READ;
 	if (open->op_share_deny & NFS4_SHARE_ACCESS_WRITE)
 		accmode |= (MAY_WRITE | MAY_TRUNC);
-	accmode |= MAY_OWNER_OVERRIDE;
 
 	status = fh_verify(rqstp, current_fh, S_IFREG, accmode);
 
@@ -124,7 +122,7 @@ do_open_lookup(struct svc_rqst *rqstp, s
 				&resfh.fh_handle.fh_base,
 				resfh.fh_handle.fh_size);
 
-		status = do_open_permission(rqstp, current_fh, open);
+		status = do_open_permission(rqstp, current_fh, open, MAY_NOP);
 	}
 
 	fh_put(&resfh);
@@ -155,7 +153,7 @@ do_open_fhandle(struct svc_rqst *rqstp, 
 	open->op_truncate = (open->op_iattr.ia_valid & ATTR_SIZE) &&
 		(open->op_iattr.ia_size == 0);
 
-	status = do_open_permission(rqstp, current_fh, open);
+	status = do_open_permission(rqstp, current_fh, open, MAY_OWNER_OVERRIDE);
 
 	return status;
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
