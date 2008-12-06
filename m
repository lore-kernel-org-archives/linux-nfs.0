From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 26/27] NLM: Rewrite IPv4 privileged requester's check
Date: Fri, 05 Dec 2008 19:05:10 -0500
Message-ID: <20081206000510.24075.81756.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:57623 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513AbYLFAGh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:06:37 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

For consistency, rewrite the IPv4 check to match the same style as the
new IPv6 check.  Note that ipv4_is_loopback() is somewhat broader in
its interpretation of what is a loopback address than simply
"127.0.0.1".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/lockd/lockd.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 80d7e8a..aa6fe70 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -291,8 +291,11 @@ static inline struct inode *nlmsvc_file_inode(struct nlm_file *file)
 static inline int __nlm_privileged_request4(const struct sockaddr *sap)
 {
 	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	return (sin->sin_addr.s_addr == htonl(INADDR_LOOPBACK)) &&
-			(ntohs(sin->sin_port) < 1024);
+
+	if (ntohs(sin->sin_port) > 1023)
+		return 0;
+
+	return ipv4_is_loopback(sin->sin_addr.s_addr);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

