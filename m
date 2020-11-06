Return-Path: <SRS0=hdvH=EM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18743C2D0A3
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 23:05:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C8C6D2078B
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 23:05:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1604703951;
	bh=f+V8jNUR1WscBYbI7+FfoNLKLlGMxP+gzr1w5OY1Eso=;
	h=From:To:Subject:Date:List-ID:From;
	b=FIv7F8Kr8DVrzi/F2s+8S5re0ZOwBKscFGANfrvjabL3ozfJM1xQdonNlqrtyRlwi
	 orjZVU9q52ON1ck9/+C9+mol+ESYWSZlIupI6nJweiBA7YEpUExrK9ZF+2liOuSbxI
	 BACo4XKbQ7e62RnuKmAV/Kr6aiGELg5bxSV3r/RE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729052AbgKFXFv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Nov 2020 18:05:51 -0500
Received: from mail.kernel.org ([198.145.29.99]:50796 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728933AbgKFXFs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Nov 2020 18:05:48 -0500
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 150302078B
        for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2020 23:05:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1604703948;
        bh=f+V8jNUR1WscBYbI7+FfoNLKLlGMxP+gzr1w5OY1Eso=;
        h=From:To:Subject:Date:From;
        b=15JF7QMjOyS1qfHSRmQnOSALaScB/ZVqBsd+oL4/nGGw5sX8bfQAHCLPqitPQOoQd
         sbOZtuuYdjmyA1yq9iyxNlqNMkJ3TFNYvigVTyYPMd2V1ZSVgo+9AjZJbDtrII9vz/
         TtUAtTZLOZ1wt9IA+y0DsUCKH3+sxZru1Vv2QhJI=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Add RDMA support to the pNFS file+flexfiles data channels
Date:   Fri,  6 Nov 2020 17:55:24 -0500
Message-Id: <20201106225527.19148-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Add support for connecting to the pNFS files/flexfiles data servers
through RDMA, assuming that the GETDEVICEINFO call advertises that
support.

Trond Myklebust (3):
  SUNRPC: xprt_load_transport() needs to support the netid "rdma6"
  NFSv4/pNFS: Use connections to a DS that are all of the same protocol
    family
  NFSv4/pNFS: Store the transport type in struct nfs4_pnfs_ds_addr

 fs/nfs/pnfs.h                |  1 +
 fs/nfs/pnfs_nfs.c            | 71 +++++++++++++++++++++++++++++-------
 net/sunrpc/xprtrdma/module.c |  2 +
 3 files changed, 60 insertions(+), 14 deletions(-)

-- 
2.28.0

