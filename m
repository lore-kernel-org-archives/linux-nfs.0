Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A2E5C7EE24
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Jun 2023 13:12:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232988AbjFENMm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 5 Jun 2023 09:12:42 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60288 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229579AbjFENMl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jun 2023 09:12:41 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 10D31A1
        for <linux-nfs@vger.kernel.org>; Mon,  5 Jun 2023 06:12:41 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id A089360C5E
        for <linux-nfs@vger.kernel.org>; Mon,  5 Jun 2023 13:12:40 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D02CFC433EF;
        Mon,  5 Jun 2023 13:12:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1685970760;
        bh=eHvzyNvUCpVvoxeSBzILPezzT5QTOKeRb8Z86TGKpg4=;
        h=Subject:From:To:Cc:Date:From;
        b=PD0pNKLXdANRnWbpGTiNh65G56BqLZu1/PjCH5Qiz10vcbs3xKsmGbLIrTtH9544m
         f6vrOS9lHBZ74IX+DZd2oX2GdB3LYSNfWzNyFRxeI0lRdXCrTUKuASXKnl3xsNFNbx
         M8Si71ZHh7itlHC9iAC3JsahfR4EifDH8n4+U3Zkov+Aj4mcOdQ1B48AQz6xp5vztj
         DOp4v39a6Jh74U3PLfya32TcLvkD0lXofASmk/oKetftAJwBuFW6he8gZDZKr4md1e
         h/iOa/D1D163DVlmQcKiwsBiq6yazZFV9GLpNuXbwvjGDi1i/C1deWaD1NxsOEyLDv
         p9jSD7+jX8W6Q==
Subject: [PATCH 1/2] mailmap: Add Bruce Fields' latest e-mail addresses
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org
Date:   Mon, 05 Jun 2023 09:12:38 -0400
Message-ID: <168597075880.7827.6268299078653725756.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Ensure that Bruce's old e-mail addresses map to his current one so
he doesn't miss out on all the fun.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 .mailmap |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/.mailmap b/.mailmap
index bf076bbc36b1..0f2458442ea2 100644
--- a/.mailmap
+++ b/.mailmap
@@ -181,6 +181,8 @@ Henrik Rydberg <rydberg@bitmath.org>
 Herbert Xu <herbert@gondor.apana.org.au>
 Huacai Chen <chenhuacai@kernel.org> <chenhc@lemote.com>
 Huacai Chen <chenhuacai@kernel.org> <chenhuacai@loongson.cn>
+J. Bruce Fields <bfields@fieldses.org> <bfields@redhat.com>
+J. Bruce Fields <bfields@fieldses.org> <bfields@citi.umich.edu>
 Jacob Shin <Jacob.Shin@amd.com>
 Jaegeuk Kim <jaegeuk@kernel.org> <jaegeuk@google.com>
 Jaegeuk Kim <jaegeuk@kernel.org> <jaegeuk.kim@samsung.com>


