Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:43342 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933766AbbBIWsd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 17:48:33 -0500
Received: by iecrp18 with SMTP id rp18so16016938iec.10
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 14:48:32 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 15/15] SUNRPC: Fix stupid typo in xs_sock_set_reuseport
Date: Mon,  9 Feb 2015 17:48:11 -0500
Message-Id: <1423522091-35365-16-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423522091-35365-15-git-send-email-trond.myklebust@primarydata.com>
References: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-2-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-4-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-5-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-6-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-7-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-8-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-9-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-10-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-11-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-12-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-13-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-14-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-15-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, kernel_setsockopt() hates you for using a char argument.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8ab02262c761..19f7526f8965 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1629,9 +1629,10 @@ static unsigned short xs_get_random_port(void)
  */
 static void xs_sock_set_reuseport(struct socket *sock)
 {
-	char opt = 1;
+	int opt = 1;
 
-	kernel_setsockopt(sock, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt));
+	kernel_setsockopt(sock, SOL_SOCKET, SO_REUSEPORT,
+			(char *)&opt, sizeof(opt));
 }
 
 static unsigned short xs_sock_getport(struct socket *sock)
-- 
2.1.0

