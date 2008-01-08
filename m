From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/6] NLM: Have lockd call try_to_freeze
Date: Tue,  8 Jan 2008 14:33:16 -0500
Message-ID: <1199820798-5289-5-git-send-email-jlayton@redhat.com>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com>
 <1199820798-5289-2-git-send-email-jlayton@redhat.com>
 <1199820798-5289-3-git-send-email-jlayton@redhat.com>
 <1199820798-5289-4-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757849AbYAHTd7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 14:33:59 -0500
In-Reply-To: <1199820798-5289-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockd makes itself freezable, but never calls try_to_freeze(). Have it
call try_to_freeze() within the main loop.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0f4148a..03a83a0 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -155,6 +155,9 @@ lockd(struct svc_rqst *rqstp)
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		char buf[RPC_MAX_ADDRBUFLEN];
 
+		if (try_to_freeze())
+			continue;
+
 		if (signalled()) {
 			flush_signals(current);
 			if (nlmsvc_ops) {
-- 
1.5.3.3

