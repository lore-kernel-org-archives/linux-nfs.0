Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f175.google.com ([209.85.160.175]:61778 "EHLO
	mail-gh0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754277Ab3BDNKQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 08:10:16 -0500
Received: by mail-gh0-f175.google.com with SMTP id g18so1503666ghb.20
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 05:10:15 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: [PATCH] sunrpc: copy scope ID in __rpc_copy_addr6
Date: Mon,  4 Feb 2013 08:10:08 -0500
Message-Id: <1359983408-28337-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When copying an address, we should also copy the scopeid in the event
that this is a link-local address and the scope matters.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/clnt.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 47354a2..6a7c261 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -242,6 +242,7 @@ static inline bool __rpc_copy_addr6(struct sockaddr *dst,
 
 	dsin6->sin6_family = ssin6->sin6_family;
 	dsin6->sin6_addr = ssin6->sin6_addr;
+	dsin6->sin6_scope_id = ssin6->sin6_scope_id;
 	return true;
 }
 #else	/* !(IS_ENABLED(CONFIG_IPV6) */
-- 
1.7.11.7

