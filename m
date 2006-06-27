From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 14] knfsd: nfsd4: remove superfluous grace
	period checks
Date: Tue, 27 Jun 2006 17:20:12 +1000
Message-ID: <1060627072012.26673@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7rv-0006MC-0u
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:19 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7ru-0006xU-Mc
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:19 -0700
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


We're checking nfs_in_grace here a few times when there isn't really any
reason to--bad_stateid is probably the more sensible return value anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    4 ----
 1 file changed, 4 deletions(-)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2006-06-27 14:36:03.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2006-06-27 14:44:03.000000000 +1000
@@ -2070,16 +2070,12 @@ nfs4_preprocess_stateid_op(struct svc_fh
 	if (!stateid->si_fileid) { /* delegation stateid */
 		if(!(dp = find_delegation_stateid(ino, stateid))) {
 			dprintk("NFSD: delegation stateid not found\n");
-			if (nfs4_in_grace())
-				status = nfserr_grace;
 			goto out;
 		}
 		stidp = &dp->dl_stateid;
 	} else { /* open or lock stateid */
 		if (!(stp = find_stateid(stateid, flags))) {
 			dprintk("NFSD: open or lock stateid not found\n");
-			if (nfs4_in_grace())
-				status = nfserr_grace;
 			goto out;
 		}
 		if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp))

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
