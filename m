From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 18] knfsd: nfsd4: handling more nfsd_cross_mnt
	errors in nfsd4 readdir
Date: Fri, 8 Dec 2006 12:13:51 +1100
Message-ID: <1061208011351.30627@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUJ1-00037p-OT
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:39 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUJ2-0004tT-Fc
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:41 -0800
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


From: J.Bruce Fields <bfields@fieldses.org>

This patch on its own causes no change in behavior, since nfsd_cross_mnt()
only returns -EAGAIN; but in the future I'd like it to also be able to
return -ETIMEDOUT, so we may as well handle any possible error here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff .prev/fs/nfsd/nfs4xdr.c ./fs/nfsd/nfs4xdr.c
--- .prev/fs/nfsd/nfs4xdr.c	2006-12-08 12:07:28.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2006-12-08 12:08:31.000000000 +1100
@@ -1845,15 +1845,11 @@ nfsd4_encode_dirent_fattr(struct nfsd4_r
 
 	exp_get(exp);
 	if (d_mountpoint(dentry)) {
-		if (nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp)) {
-		/*
-		 * -EAGAIN is the only error returned from
-		 * nfsd_cross_mnt() and it indicates that an
-		 * up-call has  been initiated to fill in the export
-		 * options on exp.  When the answer comes back,
-		 * this call will be retried.
-		 */
-			nfserr = nfserr_dropit;
+		int err;
+
+		err = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
+		if (err) {
+			nfserr = nfserrno(err);
 			goto out_put;
 		}
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
