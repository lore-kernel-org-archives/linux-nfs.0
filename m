Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78E85C43444
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 13:52:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48DD021874
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 13:52:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1546523548;
	bh=cObPJweCQn8LZr3Q6xGMqnXiYCk/tUVLMqeFt5+6QOg=;
	h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:List-ID:
	 From;
	b=L5ZJwXm3PZq/Ujgxiu/+NBwAmzjlcGmB69OVLEyXRqT/LqYX77i6tDLFIGQ4/WHPA
	 Ebq9en0q5u1gvZSTpGbcU5kQ4fsl2eDTBOwBdfSPZck5K9S3NB4qFU1vQo27AnLuVV
	 8gMsF+7vNOWmovF8ojQKyK4qNpweQ4Ogc61YTZDI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730289AbfACNw1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 08:52:27 -0500
Received: from mail.kernel.org ([198.145.29.99]:49960 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727234AbfACNw1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 08:52:27 -0500
Received: from localhost (unknown [23.100.24.84])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7D5F2217F5;
        Thu,  3 Jan 2019 13:52:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1546523546;
        bh=cObPJweCQn8LZr3Q6xGMqnXiYCk/tUVLMqeFt5+6QOg=;
        h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:From;
        b=vs2Q8+fi6YmFXAfImF/+8V1wsylOKmwS1X+jQjVhZQCJyuiv2KZXzkOtMBi5D9SW2
         vDupKArQUoH9sP1RgHlI7LMJPAEvW6URHgf8G+/XoMvJU3G8jaojIj5RH1A1k5vTtD
         cWm3Bb3rODaD7kvR5Xwaz2uMS2CbeRCGZh+GxagY=
Date:   Thu, 03 Jan 2019 13:52:25 +0000
From:   Sasha Levin <sashal@kernel.org>
To:     Sasha Levin <sashal@kernel.org>
To:     Trond Myklebust <trondmy@gmail.com>
To:     Geert Uytterhoeven <geert@linux-m68k.org>
Cc:     linux-nfs@vger.kernel.org
Cc:     stable@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix TCP receive code on archs with flush_dcache_page()
In-Reply-To: <20190103004211.12404-1-trond.myklebust@hammerspace.com>
References: <20190103004211.12404-1-trond.myklebust@hammerspace.com>
Message-Id: <20190103135226.7D5F2217F5@mail.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 277e4ab7d530 SUNRPC: Simplify TCP receive code by switching to using iterators.

The bot has tested the following trees: v4.20.0, 

v4.20.0: Build failed! Errors:
    net/sunrpc/xprtsock.c:396:24: error: ‘struct bio_vec’ has no member named ‘page’; did you mean ‘bv_page’?


How should we proceed with this patch?

--
Thanks,
Sasha
