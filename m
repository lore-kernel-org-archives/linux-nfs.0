From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/3] sunrpc: have pooled services make NUMA-friendly
	allocations
Date: Fri, 6 Jun 2008 11:41:17 -0400
Message-ID: <20080606154117.GF30863@fieldses.org>
References: <20080603111757.8769.69366.stgit@dantu.usersys.redhat.com> <20080603111802.8769.22921.stgit@dantu.usersys.redhat.com> <20080606112145.6a23afca@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41674 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbYFFPlT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Jun 2008 11:41:19 -0400
In-Reply-To: <20080606112145.6a23afca-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 06, 2008 at 11:21:45AM -0400, Jeff Layton wrote:
> On Tue, 03 Jun 2008 07:18:02 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Currently, svc_prepare_thread allocates memory using plain kmalloc()
> > and alloc_page() calls, even for threads that are destined to run on
> > different CPUs or NUMA nodes than the current one. Add a function to
> > translate a poolid into a NUMA node, and have svc_prepare_thread and
> > svc_init_buffer allocate memory on those nodes instead.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> 
> 
> --------[snip]--------
> >  
> > -	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
> > +	rqstp = kzalloc_node(sizeof(*rqstp), GFP_KERNEL, node);
> 
> Bruce,
>   It looks like AKPM has taken the kzalloc_node patch into -mm. I'd
> like to have you take this set into your tree at some point, but don't
> want you to have to carry that VM patch too. Would you be amenable to me
> changing the above to something like:
> 
> 	/* FIXME: change to kzalloc_node when/if it makes it to mainline */
> 	rqstp = kmalloc_node(sizeof(*rqstp), GFP_KERNEL | __GFP_ZERO, node);
> 
> ...and then we can make the FIXME change when mainline has the new inline?

I'd rather just take a copy of the patch.  Perhaps you see a problem I
don't--but if it's really identical to the patch that'll go into
upstream, then they'll merge trivially and there shouldn't be a problem.

--b.
