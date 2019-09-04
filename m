Return-Path: <SRS0=ZTCn=W7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B0BEC3A5A8
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Sep 2019 16:19:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2372421883
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Sep 2019 16:19:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567613989;
	bh=dQ1rcYng/vG9JREecmlY+aQhD8bv93+NXvLH83n+QRg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=uRFf46puUXmbTCHyw8x3B/HKuO2S5KYzADMtkUn1CptsYOaobhmKfijtOpGwcMJj5
	 ADNhYXZQ0eKnpknsuzQTrPQgnWxUzzNcnBME4SPBNN+ptYF3MChi5kmYYFk4df5psQ
	 wuzYM+2AfOz+4IEqkBQckqDB3W/w9P502MMw0eqs=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732156AbfIDQTo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Sep 2019 12:19:44 -0400
Received: from mail.kernel.org ([198.145.29.99]:60344 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730299AbfIDP6T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Sep 2019 11:58:19 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 369A722CED;
        Wed,  4 Sep 2019 15:58:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1567612698;
        bh=dQ1rcYng/vG9JREecmlY+aQhD8bv93+NXvLH83n+QRg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=QjKURkjedyQtM+2vCz2wQ62EwkRwNXn3zfwdRtpl5mvc/p3UGtCxkooPWkgyf7WRV
         Pzx8p4XHQe5eHUaT2Q739w02R7Qev2SAomyoV3zsxsNBJU3pI83HrwIeZW3CPKeW6j
         3lgIxPYXHXgQs45LDKHhS2wnxhqD4gyYfViq4SSw=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.2 26/94] NFSv4: Fix return value in nfs_finish_open()
Date:   Wed,  4 Sep 2019 11:56:31 -0400
Message-Id: <20190904155739.2816-26-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190904155739.2816-1-sashal@kernel.org>
References: <20190904155739.2816-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit 9821421a291b548ef4369c6998745baa36ddecd5 ]

If the file turns out to be of the wrong type after opening, we want
to revalidate the path and retry, so return EOPENSTALE rather than
ESTALE.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9f44ddc34c7bf..3321cc7a7ead1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1483,7 +1483,7 @@ static int nfs_finish_open(struct nfs_open_context *ctx,
 	if (S_ISREG(file->f_path.dentry->d_inode->i_mode))
 		nfs_file_set_open_context(file, ctx);
 	else
-		err = -ESTALE;
+		err = -EOPENSTALE;
 out:
 	return err;
 }
-- 
2.20.1

