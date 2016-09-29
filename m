Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50208 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754998AbcI2Pny (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 11:43:54 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EB89E19B773
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 15:43:53 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-43.rdu2.redhat.com [10.10.116.43])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8TFhoxF007382
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 11:43:53 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] sunrpc: add RPCSEC_GSS hash_cred() function
Date: Thu, 29 Sep 2016 10:44:40 -0500
Message-Id: <1475163881-12438-5-git-send-email-sorenson@redhat.com>
In-Reply-To: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
References: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a hash_cred() function for RPCSEC_GSS, using only the
uid from the auth_cred.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 976c781..d8bd97a 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1298,6 +1298,12 @@ gss_destroy_cred(struct rpc_cred *cred)
 	gss_destroy_nullcred(cred);
 }
 
+static int
+gss_hash_cred(struct auth_cred *acred, unsigned int hashbits)
+{
+	return hash_64(from_kuid(&init_user_ns, acred->uid), hashbits);
+}
+
 /*
  * Lookup RPCSEC_GSS cred for the current process
  */
@@ -1982,6 +1988,7 @@ static const struct rpc_authops authgss_ops = {
 	.au_name	= "RPCSEC_GSS",
 	.create		= gss_create,
 	.destroy	= gss_destroy,
+	.hash_cred	= gss_hash_cred,
 	.lookup_cred	= gss_lookup_cred,
 	.crcreate	= gss_create_cred,
 	.list_pseudoflavors = gss_mech_list_pseudoflavors,
-- 
2.5.5

