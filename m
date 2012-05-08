Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38565 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756443Ab2EHUMC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 May 2012 16:12:02 -0400
Received: by yenm10 with SMTP id m10so5259096yen.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 May 2012 13:12:01 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Subject: [PATCH][RFC] statd: drop all capabilities from the bounding set as well
Date: Tue,  8 May 2012 16:11:55 -0400
Message-Id: <1336507915-2194-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

statd drops all capabilities except for CAP_NET_BIND when it starts. It's
possible though that if it ever had a compromise that an attacker would be
able to invoke a setuid process (or something with file capabilities) in
order to reinstate some caps.

In order to prevent that, have statd also prune the bounding set to nothing
prior to dropping capabilities.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nsm/file.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/support/nsm/file.c b/support/nsm/file.c
index 5dd52c1..2d86f95 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -342,8 +342,20 @@ static _Bool
 nsm_clear_capabilities(void)
 {
 #ifdef HAVE_SYS_CAPABILITY_H
+	int ret;
+	unsigned long i;
 	cap_t caps;
 
+	/* prune the bounding set to nothing */
+	for (i = 0; i <= CAP_LAST_CAP; ++i) {
+		ret = prctl(PR_CAPBSET_DROP, i);
+		if (ret) {
+			xlog(L_ERROR, "Unable to prune capability %lu from "
+				      "bounding set: %m", i);
+			return false;
+		}
+	}
+
 	caps = cap_from_text("cap_net_bind_service=ep");
 	if (caps == NULL) {
 		xlog(L_ERROR, "Failed to allocate capability: %m");
-- 
1.7.7.6

