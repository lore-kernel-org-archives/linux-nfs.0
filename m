From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/17] NSM: Use modern style for sm_name field in nsm_handle
Date: Thu, 04 Dec 2008 14:20:38 -0500
Message-ID: <20081204192038.8039.19599.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:49897 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbYLDTVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:04 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: I'm about to add another "char *" field to the nsm_handle
structure.  The sm_name field uses an older style of declaring a
"char *" field.  If I match that style for the new field, checkpatch.pl
will complain.

So, fix the sm_name field to use the new style.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/lockd/lockd.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 80a0a2c..54dbb45 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -79,7 +79,7 @@ struct nlm_host {
 struct nsm_handle {
 	struct list_head	sm_link;
 	atomic_t		sm_count;
-	char *			sm_name;
+	char			*sm_name;
 	struct sockaddr_storage	sm_addr;
 	size_t			sm_addrlen;
 	unsigned int		sm_monitored : 1,

