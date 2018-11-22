Return-Path: <SRS0=4pmG=OB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1B1EC43441
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Nov 2018 19:58:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9D3F220892
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Nov 2018 19:58:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="19YzL01c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D3F220892
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2407327AbeKWGi3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 23 Nov 2018 01:38:29 -0500
Received: from mail.kernel.org ([198.145.29.99]:36970 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732978AbeKWGi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Nov 2018 01:38:28 -0500
Received: from sasha-vm.mshome.net (unknown [37.142.5.207])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id CCF3E20818;
        Thu, 22 Nov 2018 19:57:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1542916655;
        bh=bGMkQJGSTc8DSj3KudXce/lH6be35Xf0rSftWjr+IYY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=19YzL01cY8I4zuMgBeaLBck0y+sGkUxAFmtN43+jWXBMXN4lYEvVGxyLuo9Q/GN3e
         mADGZKeEApDa9UqIxdP7osqAtitkfip4CrH+VGL5TW43+Pk7rQ86WPwycJop4No8mc
         Kokm0RlbQn9HoTOIL3mU8pekQGA5afT9t438mQjo=
From:   Sasha Levin <sashal@kernel.org>
To:     stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.4 5/8] SUNRPC: Fix a bogus get/put in generic_key_to_expire()
Date:   Thu, 22 Nov 2018 14:57:12 -0500
Message-Id: <20181122195716.13961-5-sashal@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20181122195716.13961-1-sashal@kernel.org>
References: <20181122195716.13961-1-sashal@kernel.org>
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
index 41248b1820c7..cc27e38392ea 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -272,13 +272,7 @@ static bool generic_key_to_expire(struct rpc_cred *cred)
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

