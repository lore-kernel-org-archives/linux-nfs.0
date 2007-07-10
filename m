From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 20] knfsd: nfsd: remove superfluous assignment from nfsd_lookup
Date: Tue, 10 Jul 2007 12:24:20 +1000
Message-ID: <1070710022420.13110@suse.de>
References: <20070710121949.12548.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762253AbXGJCYt@vger.kernel.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Cc: J "." Bruce Fields <bfields@citi.umich.edu>
Cc: Neil Brown <neilb@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


From: J. Bruce Fields <bfields@citi.umich.edu>

The "err" variable will only be used in the final return, which always
happens after either the preceding

	err = fh_compose(...);

or after the following

	err = nfserrno(host_err);

So the earlier assignment to err is ignored.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c |    2 --
 1 file changed, 2 deletions(-)

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-07-10 11:20:09.000000000 +1000
+++ ./fs/nfsd/vfs.c	2007-07-10 11:34:00.000000000 +1000
@@ -168,8 +168,6 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 	exp  = fhp->fh_export;
 	exp_get(exp);
 
-	err = nfserr_acces;
-
 	/* Lookup the name, but don't follow links */
 	if (isdotent(name, len)) {
 		if (len==1)
