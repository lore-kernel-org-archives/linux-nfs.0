Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:36578 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758182AbaJaM2g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Oct 2014 08:28:36 -0400
Received: by mail-qc0-f173.google.com with SMTP id x3so5771266qcv.18
        for <linux-nfs@vger.kernel.org>; Fri, 31 Oct 2014 05:28:35 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: imc@cs.ox.ac.uk, linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: ratelimit "lockd: cannot monitor" messages
Date: Fri, 31 Oct 2014 08:28:29 -0400
Message-Id: <1414758509-30397-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When lockd can't talk to a remote statd, it'll spew a warning message
to the ring buffer. If the application is really hammering on locks
however, it's possible for that message to spam the logs. Ratelimit it
to minimize the potential for harm.

Reported-by: Ian Collier <imc@cs.ox.ac.uk>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/lockd/mon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 9106f42c472c..1cc6ec51e6b1 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -214,7 +214,7 @@ int nsm_monitor(const struct nlm_host *host)
 	if (unlikely(res.status != 0))
 		status = -EIO;
 	if (unlikely(status < 0)) {
-		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
+		pr_notice_ratelimited("lockd: cannot monitor %s\n", nsm->sm_name);
 		return status;
 	}
 
-- 
1.9.3

