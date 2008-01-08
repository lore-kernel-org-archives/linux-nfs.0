From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/6] NLM: Initialize completion variable in lockd_up
Date: Tue,  8 Jan 2008 14:33:15 -0500
Message-ID: <1199820798-5289-4-git-send-email-jlayton@redhat.com>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com>
 <1199820798-5289-2-git-send-email-jlayton@redhat.com>
 <1199820798-5289-3-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753349AbYAHTeG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 14:34:06 -0500
In-Reply-To: <1199820798-5289-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockd_start_done is a global var that can be reused if lockd is
restarted, but it's never reinitialized. On all but the first use,
wait_for_completion isn't actually waiting on it since it has
already completed once.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 82e2192..0f4148a 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -300,6 +300,7 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	/*
 	 * Create the kernel thread and wait for it to start.
 	 */
+	init_completion(&lockd_start_done);
 	error = svc_create_thread(lockd, serv);
 	if (error) {
 		printk(KERN_WARNING
-- 
1.5.3.3

