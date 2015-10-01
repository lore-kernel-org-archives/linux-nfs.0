Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:40587 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbbJASPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Oct 2015 14:15:55 -0400
Date: Thu, 1 Oct 2015 12:15:48 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Devesh Sharma <devesh.sharma@avagotech.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 03/18] xprtrdma: Remove completion polling budgets
Message-ID: <20151001181548.GA8670@obsidianresearch.com>
References: <20150917204435.19671.56195.stgit@manet.1015granger.net>
 <CANjDDBgokeHEZ7jWhRKRRU4Usr655zRoYY-qUHc9jeuyjYBzpA@mail.gmail.com>
 <A3B1A836-81AF-40E6-B551-587B7173B72D@oracle.com>
 <55FE8C0F.1050706@dev.mellanox.co.il>
 <CANjDDBjcRXsPFt2Bd+9oL2wTBTxpDsAvN5PZN669dhTC7xSyqw@mail.gmail.com>
 <0804C887-9E32-4257-96D2-6C1FBC9CB271@oracle.com>
 <CANjDDBgB_T9BN7ATTWEJcJScs2JH9bGv5zikUpu_2JJaRYS-Ug@mail.gmail.com>
 <A5EE402A-82CE-49DC-8AB9-63EC340CE8DA@oracle.com>
 <20151001171310.GA8428@obsidianresearch.com>
 <CDDBC387-9135-405E-B535-EE89F952386E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CDDBC387-9135-405E-B535-EE89F952386E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 01, 2015 at 01:36:26PM -0400, Chuck Lever wrote:

> >> A missed WC will result in an RPC/RDMA transport deadlock. In
> >> fact that is the reason for this particular patch (although
> >> it addresses only one source of missed WCs). So I would like
> >> to see that there are no windows here.
> > 
> > WCs are never missed.
> 
> The review comment earlier in this thread suggested there is
> a race condition where a WC can be “delayed” resulting in,
> well, I’m still not certain what the consequences are.

Yes. The consequence would typically be lockup of CQ processing.

> > while (1) {
> >  struct ib_wc wcs[100];
> >  int rc = ib_poll_cq(cw, NELEMS(wcs), wcs);
> > 
> >  .. process rc wcs ..
> > 
> >  if (rc != NELEMS(wcs))
> >    if (ib_req_notify_cq(cq, IB_CQ_NEXT_COMP |
> >        IB_CQ_REPORT_MISSED_EVENTS) == 0)
> >     break;
> > }
> > 
> > API wise, we should probably look at forcing
> > IB_CQ_REPORT_MISSED_EVENTS on and dropping the flag.
> 
> It’s been suggested that it’s not clear what a positive
> return value from ib_req_notify_cq() means when the
> REPORT_MISSED_EVENTS flags is set: does it mean that
> the CQ has been re-armed? I had assumed that a positive
> RC meant both missed events and a successful re-arm,
> but the pseudo-code above suggests that is not the
> case.

The ULP must assume the CQ has NOT been armed after a positive return.

What the driver does to the arm state is undefined - for instance the
driver may trigger a callback and still return 1 here.

However, the driver must make this guarentee:

 If ib_req_notify_cq(IB_CQ_REPORT_MISSED_EVENTS) returns 0 then
 the call back will always be called when the CQ is non-empty.

The ULP must loop doing polling until the above happens, otherwise the
event notification may be missed.

ie the above is guarnteed to close the WC delay/lockup race.

Again, if there has been confusion on the driver side, drivers that
don't implement the above are broken.

Review Roland's original commit comments on this feature.

 https://github.com/jgunthorpe/linux/commit/ed23a72778f3dbd465e55b06fe31629e7e1dd2f3

I'm not sure where we are at on the 'significant overhead for some
low-level drivers' issue, but assuming that is still the case, then
the recommendation is this:

bool exiting = false;
while (1) {
   struct ib_wc wcs[100];
   int rc = ib_poll_cq(cq, NELEMS(wcs), wcs);
   if (rc == 0 && exiting)
        break;

   .. process rc wcs ..

   if (rc != NELEMS(wcs)) {
        ib_req_notify_cq(cq, IB_CQ_NEXT_COMP)
	exiting = true;
   } else
	exiting = false;
}

ie a double poll.

AFAIK, this is a common pattern in the ULPs.. Perhaps we should
implement this as a core API:

struct ib_wc wcs[100];
while ((rc = ib_poll_cq_and_arm(cq, NELEMS(wcs), wcs)) != 0) {
   .. process rc wcs  ..

 ib_poll_cq_and_arm reads wcs off the CQ. If it returns 0 then the
 callback is guarenteed to happen when the CQ is non empty.

Jason
