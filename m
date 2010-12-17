Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51376 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177Ab0LQLVH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 06:21:07 -0500
Date: Fri, 17 Dec 2010 06:21:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 callback service and UDP
Message-ID: <20101217112104.GC28648@fieldses.org>
References: <AANLkTi=8YmRfJ9w_QL1WBqQZPe9HeTA+fEm2MmAa-5Ja@mail.gmail.com>
 <20101216172447.GA20246@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101216172447.GA20246@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 16, 2010 at 12:24:47PM -0500, J. Bruce Fields wrote:
> On Thu, Dec 16, 2010 at 11:19:50AM -0500, William A. (Andy) Adamson wrote:
> > I note that the current NFSv4.1 back channel supports UDP. Why? Should
> > we continue with UDP support?
> 
> Have you tested it?
> 
> Looks to me like in that case setup_callback_client() will pass
> rpc_create() a UDP svc_xprt while requesting protocol
> XPRT_TRANSPORT_BC_TCP.  Looking down through the code I'm not sure
> what's going to happen.  I doubt it's good....

Uh, I realize I'm talking about the NFS server (callback rpc client)
here and you were talking about the NFS client (callback rpc server)?

In any case, no, I don't think there's any reason to support a UDP
backchannel on client or server side.

It would be interesting to test the current code and see what it
actually does in this case.

--b.

> 
> So, agreed, making sure we error out in the UDP case (if we don't
> already) would be a good idea.
> 
> --b.
