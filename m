Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54147 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756129Ab2GJQHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:07:50 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/7] nfsd: allow owner_override only for regular files
Date: Tue, 10 Jul 2012 12:07:45 -0400
Message-Id: <1341936466-3821-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1341936466-3821-1-git-send-email-bfields@redhat.com>
References: <1341936466-3821-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We normally allow the owner of a file to override permissions checks on
IO operations, since:
	- the client will take responsibility for doing an access check
	  on open;
	- the permission checks offer no protection against malicious
	  clients--if they can authenticate as the file's owner then
	  they can always just change its permissions;
	- checking permission on each IO operation breaks the usual
	  posix rule that permission is checked only on open.

However, we've never allowed the owner to override permissions on
readdir operations, even though the above logic would also apply to
directories.  I've never heard of this causing a problem, probably
because a) simultaneously opening and creating a directory (with
restricted mode) isn't possible, and b) opening a directory, then
chmod'ing it, is rare.

Our disallowal of owner-override on directories appears to be an
accident, though--the readdir itself succeeds, and then we fail just
because lookup_one_len() calls in our filldir methods fail.

I'm not sure what the easiest fix for that would be.  For now, just make
this behavior obvious by denying the override right at the start.

This also fixes some odd v4 behavior: with the rdattr_error attribute
requested, it would perform the readdir but return an ACCES error with
each entry.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c8bd9c3..3256b5c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -757,8 +757,16 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 	 * If we get here, then the client has already done an "open",
 	 * and (hopefully) checked permission - so allow OWNER_OVERRIDE
 	 * in case a chmod has now revoked permission.
+	 *
+	 * Arguably we should also allow the owner override for
+	 * directories, but we never have and it doesn't seem to have
+	 * caused anyone a problem.  If we were to change this, note
+	 * also that our filldir callbacks would need a variant of
+	 * lookup_one_len that doesn't check permissions.
 	 */
-	err = fh_verify(rqstp, fhp, type, may_flags | NFSD_MAY_OWNER_OVERRIDE);
+	if (type == S_IFREG)
+		may_flags |= NFSD_MAY_OWNER_OVERRIDE;
+	err = fh_verify(rqstp, fhp, type, may_flags);
 	if (err)
 		goto out;
 
-- 
1.7.9.5

