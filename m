From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 01/38] svc: Add an svc transport class
Date: Mon, 17 Dec 2007 18:26:24 -0600
Message-ID: <1197937584.13463.44.camel@trinity.ogc.int>
References: <20071213184506.GA29496@fieldses.org>
	 <C38BA039.233C0%tom@opengridcomputing.com>
	 <20071217174535.GA13515@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:59344 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754582AbXLRAVH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2007 19:21:07 -0500
In-Reply-To: <20071217174535.GA13515@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2007-12-17 at 12:45 -0500, J. Bruce Fields wrote:
> On Mon, Dec 17, 2007 at 03:40:41AM -0600, Tom Tucker wrote:
> > 
> > 
> > 
> > On 12/13/07 12:45 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > Sorry for joining in a little late....
> > > 
> > > On Tue, Dec 11, 2007 at 05:31:54PM -0600, Tom Tucker wrote:
> > >> +int svc_reg_xprt_class(struct svc_xprt_class *xcl)
> > > 
> > > None of the callers appear to check the return value, so this should
> > > probably be a void return.
> > >
> > 
> > I don't feel strongly about this, but what I was trying to catch was two
> > different transports accidentally colliding on the same name. I doubt there
> > will be a run on new transports, but it would at least fail the module load
> > with a reasonable error.
> 
> Sounds fine.

Great, done. 

I've coded all of the changes that you suggested and built a new
patchset. Besides the tests I outlined in my "test matrix" are there any
other tests you would like to see performed?

I could not reproduce the BUG_ON from Bull. I'm wondering if it's a PPC
issue :-\ 

After the testing, I'll publish the revised patchset.

> 
> Thanks!--b.

