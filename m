From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 18] knfsd: nfsd4: remove a dprink from
	nfsd4_lock
Date: Fri, 8 Dec 2006 12:13:25 +1100
Message-ID: <1061208011325.30567@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUIe-00036M-17
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:16 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUId-0004pF-Vp
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:17 -0800
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

This dprintk is printing the wrong error now, but it's probably an
unnecessary dprintk anyway; just remove it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    1 -
 1 file changed, 1 deletion(-)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2006-12-08 12:07:29.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-12-08 12:07:57.000000000 +1100
@@ -2760,7 +2760,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	conflock.fl_ops = NULL;
 	conflock.fl_lmops = NULL;
 	err = posix_lock_file_conf(filp, &file_lock, &conflock);
-	dprintk("NFSD: nfsd4_lock: posix_lock_file_conf status %d\n",status);
 	switch (-err) {
 	case 0: /* success! */
 		update_stateid(&lock_stp->st_stateid);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
