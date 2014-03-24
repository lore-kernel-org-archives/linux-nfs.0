Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hobo-dev.uvm.edu ([132.198.101.84]:58580 "EHLO hobo-dev.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbaCYBZ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Mar 2014 21:25:26 -0400
Received: from hobo-dev.uvm.edu (localhost [127.0.0.1])
	by hobo-dev.uvm.edu (8.14.4/8.14.4) with ESMTP id s2P1PPMG051483
	for <linux-nfs@vger.kernel.org>; Mon, 24 Mar 2014 21:25:25 -0400
Message-Id: <d9e211037fa1cb4316665bf65a8dd2f40b1f17ca.1395710586.git.root@hobo-dev.uvm.edu>
In-Reply-To: <cover.1395710586.git.root@hobo-dev.uvm.edu>
References: <cover.1395710586.git.root@hobo-dev.uvm.edu>
From: Benjamin Coddington <bcodding@uvm.edu>
To: linux-nfs@vger.kernel.org
Date: Mon, 24 Mar 2014 19:56:45 -0400
Subject: [PATCH 1/2] nfsidmap: Match names with kernel default keyring
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benjamin Coddington <bcodding@uvm.edu>
---
 utils/nfsidmap/nfsidmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 2518ed6..ae84633 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -24,7 +24,7 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
 
 #define PROCKEYS "/proc/keys"
 #ifndef DEFAULT_KEYRING
-#define DEFAULT_KEYRING "id_resolver"
+#define DEFAULT_KEYRING ".id_resolver"
 #endif
 
 #ifndef PATH_IDMAPDCONF
-- 
1.7.1

