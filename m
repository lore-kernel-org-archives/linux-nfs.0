Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35980 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbbJGOjW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 10:39:22 -0400
Received: by wicgb1 with SMTP id gb1so214580106wic.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 07:39:21 -0700 (PDT)
Subject: Re: [PATCH v2 06/16] xprtrdma: Use workqueue to process RPC/RDMA
 replies
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20151006142430.11788.42604.stgit@manet.1015granger.net>
 <20151006145924.11788.64757.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56152E96.9040400@dev.mellanox.co.il>
Date: Wed, 7 Oct 2015 17:39:18 +0300
MIME-Version: 1.0
In-Reply-To: <20151006145924.11788.64757.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/6/2015 5:59 PM, Chuck Lever wrote:
> The reply tasklet is fast, but it's single threaded. After reply
> traffic saturates a single CPU, there's no more reply processing
> capacity.
>
> Replace the tasklet with a workqueue to spread reply handling across
> all CPUs.  This also moves RPC/RDMA reply handling out of the soft
> IRQ context and into a context that allows sleeps.

Hi Chuck,

I'm probably missing something here, but do you ever schedule in
the workqueue context? Don't you need to explicitly schedule after
a jiffie or so the code works also in a non fully preemptable kernel?
