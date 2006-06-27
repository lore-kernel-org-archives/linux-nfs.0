From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 14] knfsd: nfsd4: fix open_confirm locking
Date: Tue, 27 Jun 2006 17:20:02 +1000
Message-ID: <1060627072002.26648@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7rl-0006KX-L4
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:09 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7rk-0007Ge-BG
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:09 -0700
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

From: J. Bruce Fields <bfields@citi.umich.edu>

Fix an improper unlock in an error path.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2006-06-27 14:36:03.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2006-06-27 14:36:03.000000000 +1000
@@ -2252,8 +2252,9 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
-	if ((status = fh_verify(rqstp, current_fh, S_IFREG, 0)))
-		goto out;
+	status = fh_verify(rqstp, current_fh, S_IFREG, 0);
+	if (status)
+		return status;
 
 	nfs4_lock_state();
 

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
