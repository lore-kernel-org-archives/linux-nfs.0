Return-Path: <SRS0=4pmG=OB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A177C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Nov 2018 20:00:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EB51120892
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Nov 2018 20:00:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="y43ongOJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB51120892
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2438572AbeKWGe7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 23 Nov 2018 01:34:59 -0500
Received: from mail.kernel.org ([198.145.29.99]:33790 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2438569AbeKWGe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Nov 2018 01:34:58 -0500
Received: from sasha-vm.mshome.net (unknown [37.142.5.207])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6F48020645;
        Thu, 22 Nov 2018 19:54:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1542916446;
        bh=XTV9/j21EpeL8uJr8Ft0rDOANnR47N0I4SGgBEiodJE=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=y43ongOJijXvoMRnKtjEhkahBB9qkI7geGpteRdz6/ojxJAMsY6l0ygh02zUcXpxF
         LGDE/avEb8gRztLDeieW5hkNJa/kZcWc9AUDorD7K9gyXiprxOY39j6N9QkCYzLi3P
         kcq2rh3KO5fApA/pXB8441Dfjl0an64SiK8TleBo=
From:   Sasha Levin <sashal@kernel.org>
To:     stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 25/36] SUNRPC: Fix a bogus get/put in generic_key_to_expire()
Date:   Thu, 22 Nov 2018 14:52:29 -0500
Message-Id: <20181122195240.13123-25-sashal@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20181122195240.13123-1-sashal@kernel.org>
References: <20181122195240.13123-1-sashal@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit e3d5e573a54dabdc0f9f3cb039d799323372b251 ]

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/auth_generic.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index f1df9837f1ac..1ac08dcbf85d 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -281,13 +281,7 @@ static bool generic_key_to_expire(struct rpc_cred *cred)
 {
 	struct auth_cred *acred = &container_of(cred, struct generic_cred,
 						gc_base)->acred;
-	bool ret;
-
-	get_rpccred(cred);
-	ret = test_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
-	put_rpccred(cred);
-
-	return ret;
+	return test_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
 }
 
 static const struct rpc_credops generic_credops = {
-- 
2.17.1

