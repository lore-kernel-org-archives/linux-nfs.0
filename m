From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 16] knfsd: nfsd4: remove nfsd_setuser from putrootfh
Date: Mon, 3 Apr 2006 15:18:41 +1000
Message-ID: <1060403051841.1809@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751490AbWDCFXi@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>



Since nfsd_setuser() is already called from any operation that uses the
current filehandle (because it's called from fh_verify), there's no reason
to call it from putrootfh.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |    2 --
 1 file changed, 2 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2006-04-03 15:12:10.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2006-04-03 15:12:10.000000000 +1000
@@ -288,8 +288,6 @@ nfsd4_putrootfh(struct svc_rqst *rqstp, 
 	fh_put(current_fh);
 	status = exp_pseudoroot(rqstp->rq_client, current_fh,
 			      &rqstp->rq_chandle);
-	if (!status)
-		status = nfserrno(nfsd_setuser(rqstp, current_fh->fh_export));
 	return status;
 }
 
