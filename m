From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/7] NLM: Have lockd call try_to_freeze
Date: Tue, 18 Dec 2007 15:19:40 -0500
Message-ID: <1198009182-27895-6-git-send-email-jlayton@redhat.com>
References: <1198009182-27895-1-git-send-email-jlayton@redhat.com>
 <1198009182-27895-2-git-send-email-jlayton@redhat.com>
 <1198009182-27895-3-git-send-email-jlayton@redhat.com>
 <1198009182-27895-4-git-send-email-jlayton@redhat.com>
 <1198009182-27895-5-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbXLRUTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2007 15:19:44 -0500
In-Reply-To: <1198009182-27895-5-git-send-email-jlayton@redhat.com>
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

