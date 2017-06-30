Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57820 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF3NVe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:21:34 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
Date: Fri, 30 Jun 2017 14:21:11 +0100
Message-Id: <20170630132120.31578-4-stefanha@redhat.com>
In-Reply-To: <20170630132120.31578-1-stefanha@redhat.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Format vsock hosts as "vsock:<cid>" so the addresses can be easily
distinguished from IPv4 and IPv6 addresses.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/network.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 281e935..b5dcaa5 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -45,6 +45,8 @@
 #include <rpc/pmap_prot.h>
 #include <rpc/pmap_clnt.h>
 
+#include <linux/vm_sockets.h>
+
 #include "sockaddr.h"
 #include "xcommon.h"
 #include "mount.h"
@@ -325,6 +327,12 @@ int nfs_string_to_sockaddr(const char *address, struct sockaddr *sap,
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
2.9.4

