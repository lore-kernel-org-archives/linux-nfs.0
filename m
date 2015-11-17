Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35783 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526AbbKQLxn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:43 -0500
Received: by qgec40 with SMTP id c40so3394157qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:42 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 24/38] nfsd: allow lockd to be forcibly disabled
Date: Tue, 17 Nov 2015 06:52:46 -0500
Message-Id: <1447761180-4250-25-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In some cases, we may want to use a userland NLM server which will
require that we turn off lockd.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfssvc.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d1034d119afb..e266a41bed9b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -241,8 +241,19 @@ static void nfsd_shutdown_generic(void)
 	nfsd_file_cache_shutdown();
 }
 
+/*
+ * Allow admin to disable lockd. This would typically be used to allow (e.g.)
+ * a userspace NLM server of some sort to be used.
+ */
+static bool nfsd_disable_lockd = false;
+module_param(nfsd_disable_lockd, bool, 0644);
+MODULE_PARM_DESC(nfsd_disable_lockd, "Allow lockd to be manually disabled.");
+
 static bool nfsd_needs_lockd(void)
 {
+	if (nfsd_disable_lockd)
+		return false;
+
 #if defined(CONFIG_NFSD_V3)
 	return (nfsd_versions[2] != NULL) || (nfsd_versions[3] != NULL);
 #else
-- 
2.4.3

