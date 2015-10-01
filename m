Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:59244 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbbJARNO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Oct 2015 13:13:14 -0400
Date: Thu, 1 Oct 2015 11:13:10 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Devesh Sharma <devesh.sharma@avagotech.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 03/18] xprtrdma: Remove completion polling budgets
Message-ID: <20151001171310.GA8428@obsidianresearch.com>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net>
 <20150917204435.19671.56195.stgit@manet.1015granger.net>
 <CANjDDBgokeHEZ7jWhRKRRU4Usr655zRoYY-qUHc9jeuyjYBzpA@mail.gmail.com>
 <A3B1A836-81AF-40E6-B551-587B7173B72D@oracle.com>
 <55FE8C0F.1050706@dev.mellanox.co.il>
 <CANjDDBjcRXsPFt2Bd+9oL2wTBTxpDsAvN5PZN669dhTC7xSyqw@mail.gmail.com>
 <0804C887-9E32-4257-96D2-6C1FBC9CB271@oracle.com>
 <CANjDDBgB_T9BN7ATTWEJcJScs2JH9bGv5zikUpu_2JJaRYS-Ug@mail.gmail.com>
 <A5EE402A-82CE-49DC-8AB9-63EC340CE8DA@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A5EE402A-82CE-49DC-8AB9-63EC340CE8DA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 01, 2015 at 12:37:36PM -0400, Chuck Lever wrote:

> A missed WC will result in an RPC/RDMA transport deadlock. In
> fact that is the reason for this particular patch (although
> it addresses only one source of missed WCs). So I would like
> to see that there are no windows here.

WCs are never missed.

The issue is a race where re-arming the CQ might not work, meaning you
don't get an event.

You can certainly use arrays with poll_cq. There is no race in the API
here.

But you have to use the IB_CQ_REPORT_MISSED_EVENTS scheme to guarantee
the CQ is actually armed or continue to loop again.

Basically you have to loop until ib_req_notify_cq succeeds.

Any driver that doesn't support this is broken, do we know of any?

while (1) {
  struct ib_wc wcs[100];
  int rc = ib_poll_cq(cw, NELEMS(wcs), wcs);

  .. process rc wcs ..

  if (rc != NELEMS(wcs))
    if (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
        IB_CQ_REPORT_MISSED_EVENTS) == 0)
     break;
}

API wise, we should probably look at forcing
IB_CQ_REPORT_MISSED_EVENTS on and dropping the flag.

Jason
