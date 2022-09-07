Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F3F0C38145
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Sep 2022 19:53:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229616AbiIGTxD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Sep 2022 15:53:03 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49672 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229484AbiIGTxC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Sep 2022 15:53:02 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1917EA0275
        for <linux-nfs@vger.kernel.org>; Wed,  7 Sep 2022 12:53:02 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id A090A61A47
        for <linux-nfs@vger.kernel.org>; Wed,  7 Sep 2022 19:53:01 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A403EC433C1;
        Wed,  7 Sep 2022 19:53:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1662580381;
        bh=V4yv7dijgNzhXkL1MIX2F7iHRKG9A+VoeBZjdiMkQqk=;
        h=From:To:Cc:Subject:Date:From;
        b=RPAlfFqtXRyBOYh+0JaOQdB6qYywW4C4WVX3uBlCo5tX1awTYSfsBiO71X9jIByR5
         Q38t2pDgLa5dqAWH+uIif1bVerlS2c+GJE9SfFAZlXOdgx3700vHlGTamUDO1WZ2sl
         +ureamk0xkCsp+ZwW7Jk10Zqlj/nQp9DK27k3jZJhxkcT4JKCETq1qiMRKniXQHecC
         Pg/mPhzE49EH919l6BwPJiEqMgrd5Z78uWUuzupWUK6UF+Q013RvqydHJQFg3T3IUR
         nRzy0Mv7t4nN+vcSfMvApBQEjM1J4TAHSda/nHh7/9UB02Xux41hPuYp8+HeysS06/
         NzbdYSeoGBPDQ==
From:   Anna Schumaker <anna@kernel.org>
To:     linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Cc:     anna@kernel.org
Subject: [PATCH v2 0/1] NFSD: Simplify READ_PLUS
Date:   Wed,  7 Sep 2022 15:52:58 -0400
Message-Id: <20220907195259.926736-1-anna@kernel.org>
X-Mailer: git-send-email 2.37.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

When we left off with READ_PLUS, Chuck had suggested reverting the
server to reply with a single NFS4_CONTENT_DATA segment essentially
mimicing how the READ operation behaves. Then, a future sparse read
function can be added and the server modified to support it without
needing to rip out the old READ_PLUS code at the same time.

This patch takes that first step. I was even able to re-use the
nfsd4_encode_readv() and nfsd4_encode_splice_read() functions to
remove some duuplicate code.

- v2:
  - Add splice read support
  - Address Chuck's style comments
  - Reword the commit message

Thanks,
Anna


Anna Schumaker (1):
  NFSD: Simplify READ_PLUS

 fs/nfsd/nfs4xdr.c | 139 +++++++++++-----------------------------------
 1 file changed, 32 insertions(+), 107 deletions(-)

-- 
2.37.2

