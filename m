Return-Path: <SRS0=HBvY=OW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0210CC65BAE
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 04:50:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BCAAA20811
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 04:50:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1544676624;
	bh=g0t6f1QjG/vLEXiwz3AkgARWIEdsdO8eFX6F9Hsk9bY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=lB2oU1oPYleJer4ww9ZSapO/Su0TkQwSjO4kE5VmdCUaUiJfrevPXTTjyQ+kXwMyJ
	 CgCaujDDejYr5NaQ7K/803Bo07O/D9em5Y+nyPljpXEn1/Eqvz2Rt3tgfH9e2PyF7y
	 TufDrZZ1YWUzWTOL6J+xw8TywHgKUBuu3CHsHhcU=
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCAAA20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727599AbeLME3X (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 23:29:23 -0500
Received: from mail.kernel.org ([198.145.29.99]:42400 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726630AbeLME3V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 23:29:21 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 457E720879;
        Thu, 13 Dec 2018 04:29:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1544675361;
        bh=g0t6f1QjG/vLEXiwz3AkgARWIEdsdO8eFX6F9Hsk9bY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=nRBDQnKTFagt9cuOj4O5vbYE95llr9MGUnN45E/WeezeRxwL60CdbMy7ukmlJDQXO
         /p/7mmAUDNF+xwHiIGhQrORcknYbvQGnfWPg231kWgQ2Jr1ukE8eudsmWZ2kdyHyL1
         C8XHeb1EMI6jdbLFzmBeAMTKnd5YkOtlGnL/Vbkg=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>, stable@kernel.org,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 26/73] SUNRPC: Fix leak of krb5p encode pages
Date:   Wed, 12 Dec 2018 23:27:51 -0500
Message-Id: <20181213042838.75160-26-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20181213042838.75160-1-sashal@kernel.org>
References: <20181213042838.75160-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

[ Upstream commit 8dae5398ab1ac107b1517e8195ed043d5f422bd0 ]

call_encode can be invoked more than once per RPC call. Ensure that
each call to gss_wrap_req_priv does not overwrite pointers to
previously allocated memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/auth_gss/auth_gss.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 21c0aa0a0d1d..8cb7d812ccb8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1768,6 +1768,7 @@ priv_release_snd_buf(struct rpc_rqst *rqstp)
 	for (i=0; i < rqstp->rq_enc_pages_num; i++)
 		__free_page(rqstp->rq_enc_pages[i]);
 	kfree(rqstp->rq_enc_pages);
+	rqstp->rq_release_snd_buf = NULL;
 }
 
 static int
@@ -1776,6 +1777,9 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
 	struct xdr_buf *snd_buf = &rqstp->rq_snd_buf;
 	int first, last, i;
 
+	if (rqstp->rq_release_snd_buf)
+		rqstp->rq_release_snd_buf(rqstp);
+
 	if (snd_buf->page_len == 0) {
 		rqstp->rq_enc_pages_num = 0;
 		return 0;
-- 
2.19.1

