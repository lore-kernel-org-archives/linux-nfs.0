Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f48.google.com ([209.85.128.48]:36321 "EHLO
	mail-qe0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab3KOOhx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 09:37:53 -0500
Received: by mail-qe0-f48.google.com with SMTP id a11so2264568qen.7
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 06:37:52 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] gssd: don't let spurious signals interrupt the wait after forking
Date: Fri, 15 Nov 2013 09:37:45 -0500
Message-Id: <1384526265-4494-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Because gssd uses dnotify under the hood, it's easily possible that the
parent process can catch a signal while processing an upcall. If that
happens, then we'll currently exit the wait for the child task to exit,
and it'll end up as a zombie.

Fix this by ensuring that we only wait for the child to actually exit.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b48d163..447aec1 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -1040,7 +1040,10 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		return;
 	default:
 		/* Parent: just wait on child to exit and return */
-		wait(&err);
+		do {
+			pid = wait(&err);
+		} while(pid == -1 && errno != -ECHILD);
+
 		if (WIFSIGNALED(err))
 			printerr(0, "WARNING: forked child was killed with signal %d\n",
 					WTERMSIG(err));
-- 
1.8.3.1

