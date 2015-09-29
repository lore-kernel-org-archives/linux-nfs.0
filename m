Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60934 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934914AbbI2Pg1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2015 11:36:27 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 95F97A85
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2015 15:36:26 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] close the syslog fd in daemon_init()
Date: Tue, 29 Sep 2015 11:36:25 -0400
Message-Id: <1443540985-27992-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 7addf9d (cleanup daemonization code) added the following line to
mydaemon_init():

        dup2(pipefds[1], 3);

If we've already called vsyslog() before the fork(), then chances are fd
3 was being used for the syslog socket.  In that case the next vsyslog()
call will cause the data to appear on the read end of the pipe, causing
the parent to exit with a nonzero status.  If systemd is running, it
will see the parent's nonzero exit status and will terminate the child
as well.

So just call closelog() to close the fd.  The next call to vsyslog()
will open a new one if need be.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/nfs/mydaemon.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/nfs/mydaemon.c b/support/nfs/mydaemon.c
index 3391eff..701cfd9 100644
--- a/support/nfs/mydaemon.c
+++ b/support/nfs/mydaemon.c
@@ -122,6 +122,7 @@ daemon_init(bool fg)
 	dup2(tempfd, 0);
 	dup2(tempfd, 1);
 	dup2(tempfd, 2);
+	closelog();
 	dup2(pipefds[1], 3);
 	pipefds[1] = 3;
 	closeall(4);
-- 
1.9.3

