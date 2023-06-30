Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06C50EB64DC
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Jun 2023 20:42:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232620AbjF3Ums (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Jun 2023 16:42:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52426 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232586AbjF3Umn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jun 2023 16:42:43 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 05DD5BD
        for <linux-nfs@vger.kernel.org>; Fri, 30 Jun 2023 13:42:42 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 82FBF61808
        for <linux-nfs@vger.kernel.org>; Fri, 30 Jun 2023 20:42:42 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8C26BC433C9;
        Fri, 30 Jun 2023 20:42:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1688157761;
        bh=ROKlCTg/sDjPFnuaSk21oo7Lb8DZrHsc7I1adlH4RpU=;
        h=From:To:Cc:Subject:Date:From;
        b=OML8bqJJywwyGk8xzrUJD6wpHTXCm3S6ZSgN6FAfzEz/tHrlMzeLyEmT1Vl7dNFUB
         ogQxh6UDR//OOxsyrTGDokA0LwrJ0UEFOsPDi3Kc1y7nlPqY7cMuBswThCX7rZMjRO
         MXkB/twNHSTOs5bfU/hrZ91HorkYxZCoF1IbJEZpl7j7ednd5hXjrcXEqxhApvqF+2
         yC0S9XiN6DZEu/tIeMXJ6w0GFyL2JfFnobX6NYch1/beS3ADBTAJ53nocB1zRcTQaG
         LiKeJttm8fYw1470/tglGnDc6C+TiI4NeLy0pB3eZoW/QKmV7GulVuEVGSsaZeICJ2
         hjxjUm/hdAgvg==
From:   Anna Schumaker <anna@kernel.org>
To:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com
Cc:     anna@kernel.org
Subject: [PATCH v4 0/4] NFSv4.2: Various READ_PLUS fixes
Date:   Fri, 30 Jun 2023 16:42:36 -0400
Message-ID: <20230630204240.653492-1-anna@kernel.org>
X-Mailer: git-send-email 2.41.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches are a handul of fixes I've done recently to the READ_PLUS
code. This includes fixing some smatch warnings, fixing the XDR reply
length calculation, improving scratch buffer handling, and having
xdr_inline_decode() kmap pages if we detect that they're HIGHMEM so we
don't oops during READ_PLUS xdr decoding.

Thoughts? Patch #4 probably needs the most review, and I'm open to other
approaches if something else makes more sense!

Thanks,
Anna

Anna Schumaker (4):
  NFSv4.2: Fix READ_PLUS smatch warnings
  NFSv4.2: Fix READ_PLUS size calculations
  NFSv4.2: Rework scratch handling for READ_PLUS (again)
  SUNRPC: kmap() the xdr pages during decode

 fs/nfs/internal.h          |  1 +
 fs/nfs/nfs42.h             |  1 +
 fs/nfs/nfs42xdr.c          | 17 +++++++++++------
 fs/nfs/nfs4proc.c          | 13 +------------
 fs/nfs/read.c              | 10 ++++++++++
 include/linux/sunrpc/xdr.h |  2 ++
 net/sunrpc/clnt.c          |  1 +
 net/sunrpc/xdr.c           | 17 ++++++++++++++++-
 8 files changed, 43 insertions(+), 19 deletions(-)

-- 
2.41.0

