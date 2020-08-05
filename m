Return-Path: <SRS0=oxud=BP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD2D4C433DF
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Aug 2020 20:26:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A4E2822B42
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Aug 2020 20:26:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1596659201;
	bh=SNIwSAArg8ZICmFa9PpKHz0Jro0pjiLrIkBnphZaOAk=;
	h=From:To:Subject:Date:List-ID:From;
	b=ChjlhFLajtxCpnJ2HyIKK9mixqmxUYLCY96eZTiv6+dRt51se8CiHV8FVPyOjstiH
	 yMb47GLL6/W5kQqSvaO6uUIUOylRthyO6YxRgf8O/71sfQb+29UEfy7qTuiVhHYDjm
	 XXaw3n7Z+2YrAfRAo9TXb40Vhgk0QFa4du8sX/74=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726346AbgHEU0k (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Aug 2020 16:26:40 -0400
Received: from mail.kernel.org ([198.145.29.99]:57014 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726013AbgHEU0k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Aug 2020 16:26:40 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A0EFB22B42
        for <linux-nfs@vger.kernel.org>; Wed,  5 Aug 2020 20:26:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1596659199;
        bh=SNIwSAArg8ZICmFa9PpKHz0Jro0pjiLrIkBnphZaOAk=;
        h=From:To:Subject:Date:From;
        b=0dZAXpRER01UOnFfO4G8IMPlxYLdy3x6DQS21Gm9PtkB2zCb0d7dmeYUNOX182Ew1
         3Efp3upHiv2Pl1byPHYuTDKijrKJkuTI9Se0gxXBDS0SRBaH4ijUpyDe4Te2Ra7NoX
         aEBBFRGgLwKPH2OBVx3PWX1fmf62IzJM1reybPKA=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Don't do pNFS I/O when not holding a layout
Date:   Wed,  5 Aug 2020 16:24:29 -0400
Message-Id: <20200805202431.627013-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

We recently discovered a couple of issues in the pNFS client that can
cause it to return a layout while some of the layout segments being
returned are still in use for I/O.

The following 2 patches will add appropriate tests to ensure this
cannot happen, and that the layoutreturn call is delayed until
the outstanding I/O is finished.

Trond Myklebust (2):
  NFS: Don't move layouts to plh_return_segs list while in use
  NFS: Don't return layout segments that are in use

 fs/nfs/pnfs.c | 46 ++++++++++++++++------------------------------
 1 file changed, 16 insertions(+), 30 deletions(-)

-- 
2.26.2

