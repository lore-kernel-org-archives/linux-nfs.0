From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 5] knfsd: nfsd4: fix open permission checking
Date: Tue, 17 Oct 2006 09:30:15 +1000
Message-ID: <1061016233015.11330@suse.de>
References: <20061017092702.11224.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZbuY-00016Y-1B
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:22 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZbuX-00072g-9t
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:23 -0700
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
We weren't actually checking for SHARE_ACCESS_WRITE, with the result that
the owner could open a non-writeable file for write!

Continue to allow DENY_WRITE only with write access.

Thanks to Jim Rees for reporting the bug.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-10-17 09:02:26.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2006-10-17 09:04:13.000000000 +1000
@@ -78,8 +78,10 @@ do_open_permission(struct svc_rqst *rqst
 
 	if (open->op_share_access & NFS4_SHARE_ACCESS_READ)
 		accmode |= MAY_READ;
-	if (open->op_share_deny & NFS4_SHARE_ACCESS_WRITE)
+	if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
 		accmode |= (MAY_WRITE | MAY_TRUNC);
+	if (open->op_share_deny & NFS4_SHARE_DENY_WRITE)
+		accmode |= MAY_WRITE;
 
 	status = fh_verify(rqstp, current_fh, S_IFREG, accmode);
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
