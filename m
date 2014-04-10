Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:49655 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030331AbaDJSey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 14:34:54 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>
Cc: "'Devesh Sharma'" <Devesh.Sharma@Emulex.Com>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com> <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com> <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEAA43@CMEXMB1.ad.emulex.com> <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com> <5346B22D.3060706@opengridcomputing.com> <D7836AB3-FCB6-40EF-9954-B58A05A87791@oracle.com>
In-Reply-To: <D7836AB3-FCB6-40EF-9954-B58A05A87791@oracle.com>
Subject: RE: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
Date: Thu, 10 Apr 2014 13:34:56 -0500
Message-ID: <006601cf54eb$92488e30$b6d9aa90$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Thursday, April 10, 2014 12:44 PM
> To: Steve Wise
> Cc: Devesh Sharma; Linux NFS Mailing List; linux-rdma@vger.kernel.org; Trond Myklebust
> Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
> 
> 
> On Apr 10, 2014, at 11:01 AM, Steve Wise <swise@opengridcomputing.com> wrote:
> 
> > On 4/9/2014 7:26 PM, Chuck Lever wrote:
> >> On Apr 9, 2014, at 7:56 PM, Devesh Sharma <Devesh.Sharma@Emulex.Com> wrote:
> >>
> >>> Hi Chuk and Trond
> >>>
> >>> I will resend a v2 for this.
> >>> What if ib_post_send() fails with immidate error, I that case also DECR_CQCOUNT()
will
> be called but no completion will be reported. Will that not cause any problems?
> >> We should investigate whether an error return from ib_post_{send,recv} means there
will
> be no completion. But I've never seen these verbs fail in practice, so I'm not in a
hurry to make
> work for anyone! ;-)
> >
> > A synchronous failure from ib_post_* means the WR (or at least one of them if there
were >
> 1) failed and did not get submitted to HW.  So there will be no completion for those
that failed.
> 
> OK.
> 
> Our post operations are largely single WRs. Before we address CQCOUNT in error cases,
we'd
> have to deal with chained WRs.
> 
> Chained WRs are used only when rpcrdma_register_frmr_external() finds an MR that hasn't
> been invalidated. That's actually working around a FRMR re-use bug (commit 5c635e09). If
the
> underlying re-use problem was fixed, we could get rid of the chained WR in
> register_frmr_external() (and we wouldn't need completions at all for FAST_REG_MR).
> 
> But at 100,000 feet, if a post operation fails, that seems like a very serious issue. I
wonder
> whether we would be better off disconnecting and starting over in those cases.
> 

I agree. The application is responsible to flow-control its posting of WRs to the SQs/RQs.
So we should never see sync failures with ib_post_* due to over-running the queues.
However, if the QP moves out of RTS for whatever reason, then a multi-threaded application
could encounter sync failures because the QP exited RTS.  Anyway, I agree: if there are
any failures with ib_post_*, the application should kill the connection, (LOG SOMETHING!),
and setup a new connection.

My 2 centimes.  :)


Steve


