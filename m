Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:44286 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964803AbaESTOQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 15:14:16 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Devesh Sharma'" <Devesh.Sharma@Emulex.Com>,
        "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <tom@opengridcomputing.com>
References: <20140506174621.18208.24242.stgit@build.ogc.int> <20140506192730.GK18281@fieldses.org> <53694F72.9010007@opengridcomputing.com> <EE7902D3F51F404C82415C4803930ACD3FDFE42E@CMEXMB1.ad.emulex.com>
In-Reply-To: <EE7902D3F51F404C82415C4803930ACD3FDFE42E@CMEXMB1.ad.emulex.com>
Subject: RE: [PATCH V2 RFC 0/3] svcrdma: refactor marshalling logic
Date: Mon, 19 May 2014 14:14:17 -0500
Message-ID: <00c301cf7396$878f0720$96ad1560$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf
> Of Devesh Sharma
> Sent: Monday, May 19, 2014 2:07 PM
> To: Steve Wise; J. Bruce Fields
> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org; tom@opengridcomputing.com
> Subject: RE: [PATCH V2 RFC 0/3] svcrdma: refactor marshalling logic
> 
> While testing with ocrdma driver I am finding server side SQ full. Following is the log,
yet to
> identify why it's happening. Once this is reported Client side crashes due to some
reason.
> My kdump is not working properly therefore I am not able to analyze the situation
properly.
> 
> May 19 23:47:02 neo01-el64 kernel: svcrdma: RDMA_WRITE rmr=8008b12, to=45a2d790c,
> xdr_off=0, write_len=68, vec->sge=ffff88086cb4a0c8, vec->count=2
> May 19 23:47:02 neo01-el64 kernel: svcrdma: send_reply returns 0
> May 19 23:47:02 neo01-el64 kernel: svc: server ffff88086409a000 waiting for data (to =
> 3600000)
> May 19 23:47:02 neo01-el64 kernel: svc: transport ffff88087dfa2400 served by daemon
> ffff88086409a000
> May 19 23:47:02 neo01-el64 kernel: svc: server ffff88086409a000, pool 0, transport
> ffff88087dfa2400, inuse=18
> May 19 23:47:02 neo01-el64 kernel: svcrdma: rqstp=ffff88086409a000
> May 19 23:47:02 neo01-el64 kernel: svcrdma: processing ctxt=ffff880866754540 on
> xprt=ffff88087dfa2400, rqstp=ffff88086409a000, status=0
> May 19 23:47:02 neo01-el64 kernel: svcrdma: failed to post SQ WR rc=-22, sc_sq_count=0,
> sc_sq_depth=128
> May 19 23:47:02 neo01-el64 kernel: svcrdma: Error -22 posting RDMA_READ

Hey Deevesh,

Looking ocrdma_post_send(),-22 (-EINVAL) is returned when the QP is not in RTS.  If the SQ
is full, -ENOMEM is returned.  So I think the send error is a downstream error because the
connection got knocked down.  You should try and figure out what kicked the QP out of RTS.


Steve.

