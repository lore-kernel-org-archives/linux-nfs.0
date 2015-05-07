Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38491 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbbEGKPk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 06:15:40 -0400
Received: by wiun10 with SMTP id n10so53804517wiu.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 03:15:39 -0700 (PDT)
Message-ID: <554B3B56.1010806@dev.mellanox.co.il>
Date: Thu, 07 May 2015 13:15:50 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 06/14] xprtrdma: Acquire FMRs in rpcrdma_fmr_register_external()
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175739.3483.46010.stgit@manet.1015granger.net>
In-Reply-To: <20150504175739.3483.46010.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 8:57 PM, Chuck Lever wrote:
> Acquiring 64 FMRs in rpcrdma_buffer_get() while holding the buffer
> pool lock is expensive, and unnecessary because FMR mode can
> transfer up to a 1MB payload using just a single ib_fmr.
>
> Instead, acquire ib_fmrs one-at-a-time as chunks are registered, and
> return them to rb_mws immediately during deregistration.
>
> Transport reset is now unneeded for FMR. Each FMR is recovered
> synchronously when its RPC is retransmitted.

Does this worth a separate patch? I don't see why the two
changes are together. Is there a dependency I'm missing?
