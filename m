Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:24694 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172AbaDQNzb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Apr 2014 09:55:31 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 7/8] xprtrdma: Split the completion queue
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <534F7D5F.1090908@dev.mellanox.co.il>
Date: Thu, 17 Apr 2014 09:55:04 -0400
Cc: Steve Wise <swise@opengridcomputing.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Message-Id: <A7E4B101-BAF0-480C-95AE-26BB845EE2C3@oracle.com>
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <20140414222323.20646.66946.stgit@manet.1015granger.net> <534E7C1C.5070407@dev.mellanox.co.il> <534E8608.8030801@opengridcomputing.com> <E9B601B5-1984-40D8-914A-DDD1380E8183@oracle.com> <534EA06A.7090200@dev.mellanox.co.il> <FC61F219-ACA2-4CE8-BF02-1B8EE2464639@oracle.com> <534F7D5F.1090908@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 17, 2014, at 3:06 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:

> On 4/16/2014 9:21 PM, Chuck Lever wrote:
>> Passing a small array to ip_poll_cq() is actually easy to do, and is
>> exactly equivalent to a poll budget. The struct ib_wc should be taken
>> off the stack anyway, IMO.
>> 
>> The only other example I see in 3.15 right now is IPoIB, which seems
>> to do exactly this.
>> 
>> I’m testing a patch now. I’d like to start simple and make it more
>> complex only if we need to.
> 
> What array size are you using? Note that if you use a small array it may be an overkill since
> a lot more interrupts are invoked (-> more latency). I found that for a high workload a budget
> of 256/512/1024 keeps fairness and doesn't increase latency.

My array size is currently 4. It’s a macro that can be changed easily.

By a very large majority, my workloads see only one WC per completion 
upcall. However, I’m using an older card with simple synthetic benchmarks.

I don’t want to make the array large because struct ib_wc is at least
64 bytes on my systems — each WC array would be enormous and hardly ever
used. But we can dial it in over time.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



