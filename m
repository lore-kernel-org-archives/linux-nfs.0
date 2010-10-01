From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
Date: Fri, 1 Oct 2010 18:05:46 -0400
Message-ID: <20101001220546.GG1472@fieldses.org>
References: <4CA32AB4.2090808@parallels.com>
 <20100929214527.GC26180@fieldses.org>
 <0678928F-3DE0-4AB9-8CD9-7BDA3A362A20@oracle.com>
 <4CA42437.3090102@parallels.com>
 <F11D1388-D48E-48F5-9711-79960B397FBF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56712 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886Ab0JAWGF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 18:06:05 -0400
In-Reply-To: <F11D1388-D48E-48F5-9711-79960B397FBF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 30, 2010 at 11:16:03AM -0400, Chuck Lever wrote:
> 
> On Sep 30, 2010, at 1:46 AM, Pavel Emelyanov wrote:
> 
> >>> Shall I commit this to my for-2.6.37 tree?  Objections?
> >> 
> >> I think it looks OK.
> >> 
> >> But I was wondering if there were any other changes needed for the RDMA 
> >> transport capability, or had we decided that would happen at a latter point, 
> >> or that changes are entirely unneeded
> > 
> > We definitely need more changes in the RDMA transport, but I would like to
> > have it done later (unless someone other than me starts doing it earlier ;) ).
> 
> OK, thanks for clearing that up.  It makes sense to keep the scope of this socket patch set narrow, but I don't want the RDMA pieces to get lost.  The more we let the RDMA and socket transport capabilities differ, the harder it will be to support RDMA in the long run.
> 
> Anyway, Bruce, I have no objection to the latest version of this socket patch set, fwiw.

Applied and pushed out, thanks Pavel and Chuck....

--b.
