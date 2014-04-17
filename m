Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f47.google.com ([74.125.82.47]:35444 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaDQHGL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Apr 2014 03:06:11 -0400
Received: by mail-wg0-f47.google.com with SMTP id x12so47220wgg.18
        for <linux-nfs@vger.kernel.org>; Thu, 17 Apr 2014 00:06:09 -0700 (PDT)
Message-ID: <534F7D5F.1090908@dev.mellanox.co.il>
Date: Thu, 17 Apr 2014 10:06:07 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Wise <swise@opengridcomputing.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 7/8] xprtrdma: Split the completion queue
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <20140414222323.20646.66946.stgit@manet.1015granger.net> <534E7C1C.5070407@dev.mellanox.co.il> <534E8608.8030801@opengridcomputing.com> <E9B601B5-1984-40D8-914A-DDD1380E8183@oracle.com> <534EA06A.7090200@dev.mellanox.co.il> <FC61F219-ACA2-4CE8-BF02-1B8EE2464639@oracle.com>
In-Reply-To: <FC61F219-ACA2-4CE8-BF02-1B8EE2464639@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/16/2014 9:21 PM, Chuck Lever wrote:
> Passing a small array to ip_poll_cq() is actually easy to do, and is
> exactly equivalent to a poll budget. The struct ib_wc should be taken
> off the stack anyway, IMO.
>
> The only other example I see in 3.15 right now is IPoIB, which seems
> to do exactly this.
>
> I’m testing a patch now. I’d like to start simple and make it more
> complex only if we need to.

What array size are you using? Note that if you use a small array it may 
be an overkill since
a lot more interrupts are invoked (-> more latency). I found that for a 
high workload a budget
of 256/512/1024 keeps fairness and doesn't increase latency.

Regardless, doing array-polling is a nice optimization reducing CQ 
entrances.

Sagi.
