Return-Path: <SRS0=9vja=PN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36453C43444
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 20:53:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF476222EB
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Jan 2019 20:53:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1546721635;
	bh=mi25Lhvu4wPofx1LrDEopFD5UMOfTpUBFPWkepwdTXI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=Rh4WROU+BSAAjAN68odXeNvTU4mZAZFaHCLkBDz4LN7HmoF5EeDO4kkzfWpIsmLZn
	 tM+C0NUN7BJJ7J05UXzswOXFzBUFB2VltQR/6OUMbuffGM+V1XSiUbejRg4NrirpNU
	 5WSgFMdP0XmfqIZx8B6njZkwhXbo8DE0hN66AFZY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726289AbfAEUxy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 5 Jan 2019 15:53:54 -0500
Received: from mail.kernel.org ([198.145.29.99]:48708 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726282AbfAEUxy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 5 Jan 2019 15:53:54 -0500
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 2DF3620660;
        Sat,  5 Jan 2019 20:53:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1546721633;
        bh=mi25Lhvu4wPofx1LrDEopFD5UMOfTpUBFPWkepwdTXI=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=NkiFydu+jDtvotoUXLLT+rWoLpslZz/6vNWtBxgTZdfCVH2GKZSuL/R65lvWGa/db
         CISXDR+1XefAcfZsxr8x+dapLN9xABLL18Lj+iuTX/ZQlrqHEj6hdcoJ+XOfevR6Zu
         7H6Y0SVzL0INz98o3noJ02GM6GK4Kuj0SAjJN/N4=
Date:   Sat, 5 Jan 2019 15:53:52 -0500
From:   Sasha Levin <sashal@kernel.org>
To:     Geert Uytterhoeven <geert@linux-m68k.org>
Cc:     Trond Myklebust <trondmy@gmail.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix TCP receive code on archs with
 flush_dcache_page()
Message-ID: <20190105205352.GC166797@sasha-vm>
References: <20190103004211.12404-1-trond.myklebust@hammerspace.com>
 <20190103135226.7D5F2217F5@mail.kernel.org>
 <CAMuHMdXTMod81YP5Vtv4KdWVMG3yLO4dR45CO1W4TfDSfg8LmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMuHMdXTMod81YP5Vtv4KdWVMG3yLO4dR45CO1W4TfDSfg8LmQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jan 03, 2019 at 03:00:10PM +0100, Geert Uytterhoeven wrote:
>Hi Sasha,
>
>On Thu, Jan 3, 2019 at 2:52 PM Sasha Levin <sashal@kernel.org> wrote:
>> [This is an automated email]
>>
>> This commit has been processed because it contains a "Fixes:" tag,
>> fixing commit: 277e4ab7d530 SUNRPC: Simplify TCP receive code by switching to using iterators.
>>
>> The bot has tested the following trees: v4.20.0,
>>
>> v4.20.0: Build failed! Errors:
>>     net/sunrpc/xprtsock.c:396:24: error: ‘struct bio_vec’ has no member named ‘page’; did you mean ‘bv_page’?
>>
>>
>> How should we proceed with this patch?
>
>Please drop it, as it was superseded by v2.

Hi Geert,

These mails don't really mean that the patch got queued anywhere (as
it's obviously not upstream yet). It's more of a heads-up about how this
patch (won't) be backported to various -stable branches.

It's usually easier to get response from people while the patch is still
fresh in their heads rather than a few weeks later :)

--
Thanks,
Sasha
