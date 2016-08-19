Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39247 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754926AbcHSCEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Aug 2016 22:04:10 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 19 Aug 2016 11:45:56 +1000
Subject: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a permanent
 error
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Message-ID: <147157115640.26568.2934329194247787636.stgit@noble>
In-Reply-To: <147157095612.26568.14161646901346011334.stgit@noble>
References: <147157095612.26568.14161646901346011334.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit: bf66c9facb8e ("mounts.nfs: v2 and v3 background mounts should retry when server is down.")

changed the behaviour of "bg" mounts so that RPC_PROGNOTREGISTERED,
which maps to EOPNOTSUPP, is not a permanent error.
This useful because when an NFS server starts up there is a small window between
the moment that rpcbind (or portmap) starts responding to lookup requests,
and the moment when nfsd registers with rpcbind.  During that window
rpcbind will reply with RPC_PROGNOTREGISTERED, but mount should not give up.

This same reasoning applies to foreground mounts.  They don't wait for
as long, but could still hit the window and fail prematurely.

So revert the above patch and instead add EOPNOTSUPP to the list of
temporary errors known to nfs_is_permanent_error.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/stropts.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 9de6794c6177..d5dfb5e4a669 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -948,6 +948,7 @@ static int nfs_is_permanent_error(int error)
 	case ETIMEDOUT:
 	case ECONNREFUSED:
 	case EHOSTUNREACH:
+	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
 	case EAGAIN:
 		return 0;	/* temporary */
 	default:
@@ -1019,8 +1020,7 @@ static int nfsmount_parent(struct nfsmount_info *mi)
 	if (nfs_try_mount(mi))
 		return EX_SUCCESS;
 
-	/* retry background mounts when the server is not up */
-	if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP) {
+	if (nfs_is_permanent_error(errno)) {
 		mount_error(mi->spec, mi->node, errno);
 		return EX_FAIL;
 	}
@@ -1055,8 +1055,7 @@ static int nfsmount_child(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
 
-		/* retry background mounts when the server is not up */
-		if (nfs_is_permanent_error(errno) && errno != EOPNOTSUPP)
+		if (nfs_is_permanent_error(errno))
 			break;
 
 		if (time(NULL) > timeout)


