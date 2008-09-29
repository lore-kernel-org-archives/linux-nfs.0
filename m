From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] mountd: change "unknown host" error message to "unmatched host"
Date: Mon, 29 Sep 2008 08:11:38 -0400
Message-ID: <1222690298-20802-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37057 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412AbYI2MLm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 08:11:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've had a few users mention that they find this message confusing:

     mount request from unknown host 10.11.14.99 for /export

The hosts are listed in DNS with proper reverse records, so the reason
why the host is "unknown" isn't clear. This patch just changes the
wording of this error to hopefully make it more clear why the mount
request was rejected. This also makes this error message use a format
more similar to the other error messages in auth_authenticate().

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mountd/auth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 2bb708f..dfe61ea 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -223,7 +223,7 @@ auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
 		break;
 
 	case unknown_host:
-		xlog(L_WARNING, "%s request from unknown host %s for %s (%s)",
+		xlog(L_WARNING, "refused %s request from %s for %s (%s): unmatched host",
 		     what, inet_ntoa(addr), path, epath);
 		break;
 
-- 
1.5.5.1

