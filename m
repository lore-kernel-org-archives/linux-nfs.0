Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44711 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010Ab2CUNwY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 09:52:24 -0400
Received: by mail-gy0-f174.google.com with SMTP id r11so921107ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Mar 2012 06:52:24 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v10 8/8] nfsd: don't allow legacy client tracker init for anything but init_net
Date: Wed, 21 Mar 2012 09:52:09 -0400
Message-Id: <1332337929-18580-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This code isn't set up for containers, so don't allow it to be
used for anything but init_net.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 6f13281..21b53d5 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -416,6 +416,13 @@ nfsd4_load_reboot_recovery_data(struct net *net)
 {
 	int status;
 
+	/* XXX: The legacy code won't work in a container */
+	if (net != &init_net) {
+		WARN(1, KERN_ERR "NFSD: attempt to initialize legacy client "
+			"tracking in a container!\n");
+		return -EINVAL;
+	}
+
 	nfs4_lock_state();
 	status = nfsd4_init_recdir();
 	if (!status)
-- 
1.7.7.6

