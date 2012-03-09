Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031140Ab2CITty (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 14:49:54 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29JnrU7003306
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:49:54 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 5/7] Kill SPKM3: Remove spkm3 support from exports
Date: Fri,  9 Mar 2012 14:49:44 -0500
Message-Id: <1331322586-4631-6-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 support/include/pseudoflavors.h |    3 ---
 support/nfs/exports.c           |    3 ---
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/support/include/pseudoflavors.h b/support/include/pseudoflavors.h
index c21087b9b52f9d76d12fe798c320c1d193b8a0e9..deb052b130e6ad8d1ac49693d6c71843159fc6c5 100644
--- a/support/include/pseudoflavors.h
+++ b/support/include/pseudoflavors.h
@@ -4,9 +4,6 @@
 #define RPC_AUTH_GSS_LKEY       390006
 #define RPC_AUTH_GSS_LKEYI      390007
 #define RPC_AUTH_GSS_LKEYP      390008
-#define RPC_AUTH_GSS_SPKM       390009
-#define RPC_AUTH_GSS_SPKMI      390010
-#define RPC_AUTH_GSS_SPKMP      390011
 
 struct flav_info {
 	char    *flavour;
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index c96500fdc73a0e09914edf6f4211703d1d84a539..6e7ed699dfda6863e1bb1c0ef7894d473232f834 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -42,9 +42,6 @@ struct flav_info flav_map[] = {
 	{ "lipkey",	RPC_AUTH_GSS_LKEY	},
 	{ "lipkey-i",	RPC_AUTH_GSS_LKEYI	},
 	{ "lipkey-p",	RPC_AUTH_GSS_LKEYP	},
-	{ "spkm3",	RPC_AUTH_GSS_SPKM	},
-	{ "spkm3i",	RPC_AUTH_GSS_SPKMI	},
-	{ "spkm3p",	RPC_AUTH_GSS_SPKMP	},
 	{ "unix",	AUTH_UNIX		},
 	{ "sys",	AUTH_SYS		},
 	{ "null",	AUTH_NULL		},
-- 
1.7.7.6

