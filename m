Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757286Ab0BEUJT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 15:09:19 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: release reference to nsm_handle in nlm_host_rebooted
Date: Fri,  5 Feb 2010 15:09:12 -0500
Message-Id: <1265400552-8375-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

nsm_reboot_lookup takes a reference to the nsm_handle that it returns,
but nlm_host_rebooted never releases that reference.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/host.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 4600c20..bb464d1 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -479,8 +479,8 @@ again:	mutex_lock(&nlm_host_mutex);
 			}
 		}
 	}
-
 	mutex_unlock(&nlm_host_mutex);
+	nsm_release(nsm);
 }
 
 /*
-- 
1.6.6

