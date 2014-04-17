Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:58904 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbaDQOeO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Apr 2014 10:34:14 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <20140414222323.20646.66946.stgit@manet.1015granger.net> <534E7C1C.5070407@dev.mellanox.co.il> <534E8608.8030801@opengridcomputing.com> <E9B601B5-1984-40D8-914A-DDD1380E8183@oracle.com> <534EA06A.7090200@dev.mellanox.co.il> <FC61F219-ACA2-4CE8-BF02-1B8EE2464639@oracle.com> <534F7D5F.1090908@dev.mellanox.co.il> <A7E4B101-BAF0-480C-95AE-26BB845EE2C3@oracle.com>
In-Reply-To: <A7E4B101-BAF0-480C-95AE-26BB845EE2C3@oracle.com>
Subject: RE: [PATCH 7/8] xprtrdma: Split the completion queue
Date: Thu, 17 Apr 2014 09:34:19 -0500
Message-ID: <003001cf5a4a$1e3f5320$5abdf960$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On
> Behalf Of Chuck Lever
> Sent: Thursday, April 17, 2014 8:55 AM
> To: Sagi Grimberg
> Cc: Steve Wise; Linux NFS Mailing List; linux-rdma@vger.kernel.org
> Subject: Re: [PATCH 7/8] xprtrdma: Split the completion queue
> 
> 
> On Apr 17, 2014, at 3:06 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
> > On 4/16/2014 9:21 PM, Chuck Lever wrote:
> >> Passing a small array to ip_poll_cq() is actually easy to do, and is
> >> exactly equivalent to a poll budget. The struct ib_wc should be taken
> >> off the stack anyway, IMO.
> >>
> >> The only other example I see in 3.15 right now is IPoIB, which seems
> >> to do exactly this.
> >>
> >> I'm testing a patch now. I'd like to start simple and make it more
> >> complex only if we need to.
> >
> > What array size are you using? Note that if you use a small array it may be an
overkill since
> > a lot more interrupts are invoked (-> more latency). I found that for a high workload
a
> budget
> > of 256/512/1024 keeps fairness and doesn't increase latency.
> 
> My array size is currently 4. It's a macro that can be changed easily.
> 
> By a very large majority, my workloads see only one WC per completion
> upcall. However, I'm using an older card with simple synthetic benchmarks.
> 
> I don't want to make the array large because struct ib_wc is at least
> 64 bytes on my systems - each WC array would be enormous and hardly ever
> used. But we can dial it in over time.

You could use a small array combined with a loop and a budget count.  So the code would
grab, say, 4 at a time, and keep looping polling up to 4 until the CQ is empty or the
desired budget is reached...

Stevo

