Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754412AbcI2Pnx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 11:43:53 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6A64E7EA99
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 15:43:53 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-43.rdu2.redhat.com [10.10.116.43])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8TFhoxE007382
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 11:43:52 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] sunrpc: add auth_unix hash_cred() function
Date: Thu, 29 Sep 2016 10:44:39 -0500
Message-Id: <1475163881-12438-4-git-send-email-sorenson@redhat.com>
In-Reply-To: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
References: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a hash_cred() function for auth_unix, using both the
uid and gid from the auth_cred.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 net/sunrpc/auth_unix.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index a99278c..4c0c572 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -46,6 +46,14 @@ unx_destroy(struct rpc_auth *auth)
 	rpcauth_clear_credcache(auth->au_credcache);
 }
 
+static int
+unx_hash_cred(struct auth_cred *acred, unsigned int hashbits)
+{
+	return hash_64(from_kgid(&init_user_ns, acred->gid) |
+		((u64)from_kuid(&init_user_ns, acred->uid) <<
+			(sizeof(gid_t) * 8)), hashbits);
+}
+
 /*
  * Lookup AUTH_UNIX creds for current process
  */
@@ -220,6 +228,7 @@ const struct rpc_authops authunix_ops = {
 	.au_name	= "UNIX",
 	.create		= unx_create,
 	.destroy	= unx_destroy,
+	.hash_cred	= unx_hash_cred,
 	.lookup_cred	= unx_lookup_cred,
 	.crcreate	= unx_create_cred,
 };
-- 
2.5.5

