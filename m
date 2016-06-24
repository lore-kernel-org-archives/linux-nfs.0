Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:58081 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398AbcFXNg4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 09:36:56 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>
Cc: "'Raju Rangoju'" <rajur@chelsio.com>, <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
References: <00e101d1cd65$e19bf360$a4d3da20$@opengridcomputing.com> <BDD2D64C-7A05-42EB-83C2-F95825C7579D@oracle.com>
In-Reply-To: <BDD2D64C-7A05-42EB-83C2-F95825C7579D@oracle.com>
Subject: RE: Interrupted IO causing async errors
Date: Fri, 24 Jun 2016 08:36:55 -0500
Message-ID: <001601d1ce1d$7990c800$6cb25800$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Thursday, June 23, 2016 7:15 PM
> To: Steve Wise
> Cc: Raju Rangoju; linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
> Subject: Re: Interrupted IO causing async errors
> 
> Hi Steve-
> 
> > On Jun 23, 2016, at 11:42 AM, Steve Wise <swise@opengridcomputing.com>
> wrote:
> >
> > Hey chuck, we observe with 4.7-rc4 (and older kernels too) that interrupting
a
> > dbench test on a nfsrdma/cxgb4 mount while it is doing heavy I/O can result
in
> > cxgb4 logging an "invalid stag" error on an ingress RDMA WRITE message.   Is
> > this expected?  I'm wondering if this is a normal side effect of
interrupting
> > the IO on the mount.  Maybe due to the mount options or NFS version?    This
> > error could happen if the NFSRDMA client invalidated MRs that were
advertised
> to
> > the server for IO, while IO was still in flight.  Is this expected or should
we
> > dive in further?  Thoughts?  thanks...
> 
> When an application is signaled, outstanding RPCs are terminated.
> When an RPC completes, whether because a reply was received,
> or because the local application has died, any memory that was
> registered on behalf of that RPC is invalidated before it can be
> used for something else. The data in that memory remains at rest
> until invalidation and DMA unmapping is complete.
> 
> It appears that your server is attempting to read an argument or
> write a result for an RPC that is no longer pending. I think both
> sides should report a transport error, and the connection should
> terminate. No other problems, though: other operation should
> continue normally after the client re-establishes a fresh connection.
> 
> If this doesn't match your observations, let me know.
>

This is exactly what we see.  Thanks!

Steve.

