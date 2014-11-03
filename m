Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbaKCRtg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2014 12:49:36 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Subject: [PATCH 1/2] nfsidmap: set the correct DEFAULT_KEYRING string
Date: Mon,  3 Nov 2014 12:49:32 -0500
Message-Id: <ae1775fbb236c98c7e71fa3393f98b0cb445bb0f.1415036893.git.bcodding@redhat.com>
In-Reply-To: <cover.1415036893.git.bcodding@redhat.com>
References: <cover.1415036893.git.bcodding@redhat.com>
In-Reply-To: <cover.1415036893.git.bcodding@redhat.com>
References: <cover.1415036893.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/nfsidmap/nfsidmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 96149cc..4da7f5c 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -25,7 +25,7 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
 
 #define PROCKEYS "/proc/keys"
 #ifndef DEFAULT_KEYRING
-#define DEFAULT_KEYRING "id_resolver"
+#define DEFAULT_KEYRING ".id_resolver"
 #endif
 
 #ifndef PATH_IDMAPDCONF
-- 
1.7.1

