Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750866AbcJGKFB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 06:05:01 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2D01C3D94B
        for <linux-nfs@vger.kernel.org>; Fri,  7 Oct 2016 10:03:32 +0000 (UTC)
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 2/4] mount: present AF_VSOCK addresses
Date: Fri,  7 Oct 2016 11:01:41 +0100
Message-Id: <1475834503-3984-3-git-send-email-stefanha@redhat.com>
In-Reply-To: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Format vsock hosts as "vsock:<cid>" so the addresses can be easily
distinguished from IPv4 and IPv6 addresses.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/network.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 7dceb2d..dcc38ca 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -44,6 +44,8 @@
 #include <rpc/pmap_prot.h>
 #include <rpc/pmap_clnt.h>
 
+#include <linux/vm_sockets.h>
+
 #include "sockaddr.h"
 #include "xcommon.h"
 #include "mount.h"
@@ -324,6 +326,12 @@ int nfs_string_to_sockaddr(const char *address, struct sockaddr *sap,
 int nfs_present_sockaddr(const struct sockaddr *sap, const socklen_t salen,
 			 char *buf, const size_t buflen)
 {
+	if (sap->sa_family == AF_VSOCK) {
+		snprintf(buf, buflen, "vsock:%u",
+			 ((struct sockaddr_vm *)sap)->svm_cid);
+		return 1;
+	}
+
 #ifdef HAVE_GETNAMEINFO
 	int result;
 
-- 
2.7.4

