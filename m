Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41014 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754412AbcI2Pnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 11:43:52 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 29B55C092193
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 15:43:52 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-43.rdu2.redhat.com [10.10.116.43])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8TFhoxC007382
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 11:43:51 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] sunrpc: add hash_cred() function to rpc_authops struct
Date: Thu, 29 Sep 2016 10:44:37 -0500
Message-Id: <1475163881-12438-2-git-send-email-sorenson@redhat.com>
In-Reply-To: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
References: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, a single hash algorithm is used to hash the auth_cred for
the credcache for all rpc_auth types.  Add a hash_cred() function to
the rpc_authops struct to allow a hash function specific to each
auth flavor.


Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 include/linux/sunrpc/auth.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 4ccf184..b1bc62b 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -131,6 +131,7 @@ struct rpc_authops {
 	struct rpc_auth *	(*create)(struct rpc_auth_create_args *, struct rpc_clnt *);
 	void			(*destroy)(struct rpc_auth *);
 
+	int			(*hash_cred)(struct auth_cred *, unsigned int);
 	struct rpc_cred *	(*lookup_cred)(struct rpc_auth *, struct auth_cred *, int);
 	struct rpc_cred *	(*crcreate)(struct rpc_auth*, struct auth_cred *, int, gfp_t);
 	int			(*list_pseudoflavors)(rpc_authflavor_t *, int);
-- 
2.5.5

