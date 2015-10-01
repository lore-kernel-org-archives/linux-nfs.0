Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37940 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbbJARgh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Oct 2015 13:36:37 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 03/18] xprtrdma: Remove completion polling budgets
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151001171310.GA8428@obsidianresearch.com>
Date: Thu, 1 Oct 2015 13:36:26 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Devesh Sharma <devesh.sharma@avagotech.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CDDBC387-9135-405E-B535-EE89F952386E@oracle.com>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net> <20150917204435.19671.56195.stgit@manet.1015granger.net> <CANjDDBgokeHEZ7jWhRKRRU4Usr655zRoYY-qUHc9jeuyjYBzpA@mail.gmail.com> <A3B1A836-81AF-40E6-B551-587B7173B72D@oracle.com> <55FE8C0F.1050706@dev.mellanox.co.il> <CANjDDBjcRXsPFt2Bd+9oL2wTBTxpDsAvN5PZN669dhTC7xSyqw@mail.gmail.com> <0804C887-9E32-4257-96D2-6C1FBC9CB271@oracle.com> <CANjDDBgB_T9BN7ATTWEJcJScs2JH9bGv5zikUpu_2JJaRYS-Ug@mail.gmail.com> <A5EE402A-82CE-49DC-8AB9-63EC340CE8DA@oracle.com> <20151001171310.GA8428@obsidianresearch.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 1, 2015, at 1:13 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> 
> On Thu, Oct 01, 2015 at 12:37:36PM -0400, Chuck Lever wrote:
> 
>> A missed WC will result in an RPC/RDMA transport deadlock. In
>> fact that is the reason for this particular patch (although
>> it addresses only one source of missed WCs). So I would like
>> to see that there are no windows here.
> 
> WCs are never missed.

The review comment earlier in this thread suggested there is
a race condition where a WC can be “delayed” resulting in,
well, I’m still not certain what the consequences are.

There was some interest in going back to a single WC array
argument when calling ib_poll_cq. I’d like to avoid that.

If there is an issue using a WC array, I’d like to
understand what it is.


> The issue is a race where re-arming the CQ might not work, meaning you
> don't get an event.
> 
> You can certainly use arrays with poll_cq. There is no race in the API
> here.
> 
> But you have to use the IB_CQ_REPORT_MISSED_EVENTS scheme to guarantee
> the CQ is actually armed or continue to loop again.
> 
> Basically you have to loop until ib_req_notify_cq succeeds.
> 
> Any driver that doesn't support this is broken, do we know of any?
> 
> while (1) {
>  struct ib_wc wcs[100];
>  int rc = ib_poll_cq(cw, NELEMS(wcs), wcs);
> 
>  .. process rc wcs ..
> 
>  if (rc != NELEMS(wcs))
>    if (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
>        IB_CQ_REPORT_MISSED_EVENTS) == 0)
>     break;
> }
> 
> API wise, we should probably look at forcing
> IB_CQ_REPORT_MISSED_EVENTS on and dropping the flag.

It’s been suggested that it’s not clear what a positive
return value from ib_req_notify_cq() means when the
REPORT_MISSED_EVENTS flags is set: does it mean that
the CQ has been re-armed? I had assumed that a positive
RC meant both missed events and a successful re-arm,
but the pseudo-code above suggests that is not the
case.


—
Chuck Lever



