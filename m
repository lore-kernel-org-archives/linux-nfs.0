Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16EC2C04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 09:14:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DA9612082B
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 09:14:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA9612082B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727195AbeLEJOG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 04:14:06 -0500
Received: from foss.arm.com ([217.140.101.70]:49088 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726171AbeLEJOG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Dec 2018 04:14:06 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 013D180D;
        Wed,  5 Dec 2018 01:14:06 -0800 (PST)
Received: from [10.1.197.50] (e120937-lin.cambridge.arm.com [10.1.197.50])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 359F23F575;
        Wed,  5 Dec 2018 01:14:05 -0800 (PST)
Subject: Re: [PATCH] SUNRPC: Fix RPC receive hangs
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20181204192439.39259-1-trond.myklebust@hammerspace.com>
 <70cd2493391a24e5f92a36622f588cdc463dfe4c.camel@hammerspace.com>
From:   Cristian Marussi <cristian.marussi@arm.com>
Message-ID: <871ff105-7dce-04ba-4c1f-ac724d348f9b@arm.com>
Date:   Wed, 5 Dec 2018 09:14:03 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <70cd2493391a24e5f92a36622f588cdc463dfe4c.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi

On 04/12/2018 19:31, Trond Myklebust wrote:
> On Tue, 2018-12-04 at 14:24 -0500, Trond Myklebust wrote:
>> The RPC code is occasionally hanging when the receive code fails to
>> empty the socket buffer due to a partial read of the data. When we
>> convert that to an EAGAIN, it appears we occasionally leave data in
>> the
>> socket. The fix is to just keep reading until the socket returns
>> EAGAIN/EWOULDBLOCK.
>>
>> Reported-by: Catalin Marinas <catalin.marinas@arm.com>
>> Reported-by: Cristian Marussi <cristian.marussi@arm.com>
>> Reported-by: Chuck Lever <chuck.lever@oracle.com>
>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>> ---
> 
> Hi guys,
> 
> I think I managed to reproduce the hangs that you were reporting by
> setting the r/wsize to 1024, and then running the xfstests generic/074
> test. This patch (which should apply on top of the linux-next branch
> that I pointed you to previously) appears to fix the hang for that test
> case, so I'm hoping it will also fix the issues you reported.

Thanks !

I'll try it out.

Cheers

Cristian

> 
> This patch can also be retrieved as part of the 'testing' branch ( 
> https://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/testing
> )
> 
> git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
> 
> Cheers
>   Trond
> 

