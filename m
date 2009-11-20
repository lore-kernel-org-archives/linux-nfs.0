From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 07/11] SUNRPC: Use a cached RPC client and transport
 for rpcbind upcalls
Date: Fri, 20 Nov 2009 18:47:55 -0500
Message-ID: <1258760875.2982.1.camel@localhost>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
	 <20091105182319.2796.62305.stgit@matisse.1015granger.net>
	 <1258748285.2494.84.camel@localhost>
	 <560F5576-A0D0-4126-983D-F1DECA61CE02@oracle.com>
	 <20091120220506.GB13109@fieldses.org>
	 <8EA5EB4E-A6EF-4501-AE13-856105142F9A@oracle.com>
	 <20091120223644.GB13840@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752264AbZKTXsm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Nov 2009 18:48:42 -0500
In-Reply-To: <20091120223644.GB13840@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-11-20 at 17:36 -0500, J. Bruce Fields wrote: 
> On Fri, Nov 20, 2009 at 05:24:43PM -0500, Chuck Lever wrote:
> > On Nov 20, 2009, at 5:05 PM, J. Bruce Fields wrote:
> >> On Fri, Nov 20, 2009 at 04:50:34PM -0500, Chuck Lever wrote:
> >>> I can't reproduce any problems with the rpcbind upcall here.  Do you
> >>> have anything more specific?
> >>
> >> Isn't there an rpc ping in rpc_bind_new_program?
> >
> > Hrm, I suppose there is.  That's weird, clearly I didn't see the  
> > rpc_ping() call, even though I was looking for it when I wrote this.  A 
> > GFP_KERNEL memory allocation can sleep too, can't it?
> 
> Yes.  I'd be really curious to know how that got through--if
> CONFIG_DEBUG_SPINLOCK_SLEEP can't catch a case that cut-and-dried, then
> it's totally broken....
> 
> --b.

Furthermore, there are memory allocations galore in the call to
rpc_create(). Any attempt to run that while holding a spinlock should
cause CONFIG_DEBUG_SPINLOCK_SLEEP to throw a series of fits...

Trond
