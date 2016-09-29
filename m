Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34300 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755058AbcI2Pnx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 11:43:53 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C17DEA0B5B
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 15:43:52 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-43.rdu2.redhat.com [10.10.116.43])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8TFhoxD007382
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 11:43:52 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] sunrpc: add generic_auth hash_cred() function
Date: Thu, 29 Sep 2016 10:44:38 -0500
Message-Id: <1475163881-12438-3-git-send-email-sorenson@redhat.com>
In-Reply-To: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
References: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a hash_cred() function for generic_auth, using both the
uid and gid from the auth_cred.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 net/sunrpc/auth_generic.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 1682195..0494513 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -78,6 +78,14 @@ static struct rpc_cred *generic_bind_cred(struct rpc_task *task,
 	return auth->au_ops->lookup_cred(auth, acred, lookupflags);
 }
 
+static int
+generic_hash_cred(struct auth_cred *acred, unsigned int hashbits)
+{
+	return hash_64(from_kgid(&init_user_ns, acred->gid) |
+		((u64)from_kuid(&init_user_ns, acred->uid) <<
+			(sizeof(gid_t) * 8)), hashbits);
+}
+
 /*
  * Lookup generic creds for current process
  */
@@ -258,6 +266,7 @@ generic_key_timeout(struct rpc_auth *auth, struct rpc_cred *cred)
 static const struct rpc_authops generic_auth_ops = {
 	.owner = THIS_MODULE,
 	.au_name = "Generic",
+	.hash_cred = generic_hash_cred,
 	.lookup_cred = generic_lookup_cred,
 	.crcreate = generic_create_cred,
 	.key_timeout = generic_key_timeout,
-- 
2.5.5

