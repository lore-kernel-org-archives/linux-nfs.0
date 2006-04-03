From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 16] knfsd: nfsd4: Wrong error handling in nfs4acl
Date: Mon, 3 Apr 2006 15:18:11 +1000
Message-ID: <1060403051811.1739@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964847AbWDCFUj@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>



this fixes coverity id #3. Coverity detected dead code,
since the == -1 comparison only returns 0 or 1 to error.
Therefore the if ( error < 0 ) statement was always false.
Seems that this was an if( error = nfs4... ) statement some time
ago, which got broken during cleanup.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfs4acl.c~current~ ./fs/nfsd/nfs4acl.c
--- ./fs/nfsd/nfs4acl.c~current~	2006-04-03 15:12:05.000000000 +1000
+++ ./fs/nfsd/nfs4acl.c	2006-04-03 15:12:05.000000000 +1000
@@ -790,7 +790,7 @@ nfs4_acl_split(struct nfs4_acl *acl, str
 			continue;
 
 		error = nfs4_acl_add_ace(dacl, ace->type, ace->flag,
-				ace->access_mask, ace->whotype, ace->who) == -1;
+				ace->access_mask, ace->whotype, ace->who);
 		if (error < 0)
 			goto out;
 
