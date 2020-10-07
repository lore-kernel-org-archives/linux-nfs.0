Return-Path: <SRS0=1cAr=DO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53B59C4363D
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Oct 2020 22:26:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1C338212CC
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Oct 2020 22:26:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1602109588;
	bh=64u+c42ysjs1XvzyG7e1nHL4Nq4BaJxvqC7RArgejy4=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=Ye16vnE0iTqPa5D0syX605k+P+zvLQdH55CGp2NlGu1Rf+lxSDOhjOycC27l1WeYf
	 lNxIHcRlejnQvDD5nkATQl7//7XoW+i5Vwk08m7TIZw4V4g+J7dknu52zy03CYRmMx
	 Kl3i0MlO1Pvo+zQgqoHuDZ3iKeQG7JaJqtQ8ZZOU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728772AbgJGW01 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Oct 2020 18:26:27 -0400
Received: from mail.kernel.org ([198.145.29.99]:43366 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728761AbgJGW01 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Oct 2020 18:26:27 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A5CAD2083B;
        Wed,  7 Oct 2020 22:26:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1602109587;
        bh=64u+c42ysjs1XvzyG7e1nHL4Nq4BaJxvqC7RArgejy4=;
        h=From:To:Cc:Subject:Date:From;
        b=U8aZEmtmV5CUQlfgfWRytg6ub06MWvA9Rfp0eEfVIzS+AVMUN7QFK0XoCWc4FS40K
         bTin5vLSqQbuOFnSksMGQLF8DSImWEfXGIiuk/tJEW0wv79SoYO0cG8OfGh9tqw2ts
         FnQ+hkzGt66jEXA8+tJCqTkvWxva7hpi4YpcnUik=
From:   trondmy@kernel.org
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/2] Give containers a unique client id
Date:   Wed,  7 Oct 2020 18:24:16 -0400
Message-Id: <20201007222418.604115-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

This series adds the missing patches to allow a container to set a
unique client id using /sys/fs/nfs/net/nfs_client/identifier, and
have NFS use that for any new NFS mounts that are initiated by that
container.

--
v2: Fix a variable initialisation in nfs4_get_uniquifier
    Switch to using preferred strscpy()

Trond Myklebust (2):
  NFSv4: Clean up initialisation of uniquified client id strings
  NFSv4: Use the net namespace uniquifier if it is set

 fs/nfs/nfs4proc.c | 88 +++++++++++++++++++++++++----------------------
 1 file changed, 47 insertions(+), 41 deletions(-)

-- 
2.26.2

