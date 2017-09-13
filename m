Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56276 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:14 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 04/14] mount: present AF_VSOCK addresses
Date: Wed, 13 Sep 2017 11:26:40 +0100
Message-Id: <20170913102650.10377-5-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Format vsock hosts as "vsock:<cid>" so the addresses can be easily
distinguished from IPv4 and IPv6 addresses.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/mount/network.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 8ab5be8..0fa9029 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -330,6 +330,12 @@ int nfs_string_to_sockaddr(const char *address, struct sockaddr *sap,
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
2.13.5

