From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: server rdma todo's
Date: Tue, 1 Jul 2008 14:04:07 -0400
Message-ID: <20080701180407.GA21807@fieldses.org>
References: <20080630233433.GH15719@fieldses.org> <alpine.LFD.1.10.0807011015190.3428@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60278 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917AbYGASEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2008 14:04:09 -0400
In-Reply-To: <alpine.LFD.1.10.0807011015190.3428-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 01, 2008 at 10:21:40AM -0400, James Lentini wrote:
> 
> On Mon, 30 Jun 2008, J. Bruce Fields wrote:
> 
> > I've got a few very small server-rdma todo's lying around; would you be
> > the right person to help with them?
> > 
> > 	- Documentation on nfsrdma security issues.  (Examples of setup
> > 	  that would be secure, under what asssumptions, etc.)
> 
> What document would this be for?

I'd put in in Documentation/filesystems/ somewhere, maybe with the rdma
howto?

> Is there an example of the format for TCP or UDP? 

No.  I assume (possibly I'm naive) that we all have some idea what the
security model is for tcp and udp.  Rdma seems to be very different,
hence worth some explanation.

A more general "linux nfs security issues" document might be a good
thing to do some day....

> When do you need this by? We should involve Tom Talpey in this, but he 
> is away on vacation this week. I think Tucker is on vacation this week 
> too.

It's not urgent.

> 
> > 	- Fix Kconfig rmda help to mention server too.
> 
> Tucker or I could do that. Which Kconfig did you want to update?

I was just thinking of the SUNRPC_XPRT_RDMA help text.

> I also need to incorporate Chuck's suggestions into the updated 
> NFS/RDMA readme.

OK!  The latest version I have is what's in the for-2.6.27 branch:

	git://linux-nfs.org/~bfields/linux.git for-2.6.27

--b.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
