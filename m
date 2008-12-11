From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/11] NLM: Rewrite IPv4 privileged requester's check
Date: Thu, 11 Dec 2008 17:56:52 -0500
Message-ID: <20081211225651.21468.1413.stgit@ingres.1015granger.net>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:58342 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757757AbYLKW5b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:57:31 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

