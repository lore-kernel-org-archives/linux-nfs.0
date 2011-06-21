Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail127.messagelabs.com ([216.82.250.115]:39986 "EHLO
	mail127.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079Ab1FUBT1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2011 21:19:27 -0400
From: H Hartley Sweeten <hartleys@visionengravers.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Subject: [PATCH] svcauth_unix.c: quiet sparse noise
Date: Mon, 20 Jun 2011 18:19:12 -0700
CC: <netdev@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@netapp.com>, <bfields@fieldses.org>, <neilb@suse.de>,
        <davem@davemloft.net>
Content-Type: text/plain; charset="utf-8"
Message-ID: <201106201819.12839.hartleys@visionengravers.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Like svcauth_unix, the symbol svcauth_null is used external from this
file. Declare it as extern to quiet the following sparse noise:

warning: symbol 'svcauth_null' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>

---

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index c8e1021..62e49e2 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -36,6 +36,7 @@ struct unix_domain {
 	/* other stuff later */
 };
 
+extern struct auth_ops svcauth_null;
 extern struct auth_ops svcauth_unix;
 
 static void svcauth_unix_domain_release(struct auth_domain *dom)
