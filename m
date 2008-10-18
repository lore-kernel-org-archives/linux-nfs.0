From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] lockd: set svc_serv->sv_maxconn to a more
 reasonable value
Date: Sat, 18 Oct 2008 09:06:31 -0400
Message-ID: <20081018090631.14f375d3@tleilax.poochiereds.net>
References: <1224267970-15769-1-git-send-email-jlayton@redhat.com>
	<1224267970-15769-2-git-send-email-jlayton@redhat.com>
	<20081017211833.GF14960@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47477 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbYJRNG5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Oct 2008 09:06:57 -0400
In-Reply-To: <20081017211833.GF14960@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Oct 2008 17:18:33 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Oct 17, 2008 at 02:26:10PM -0400, Jeff Layton wrote:
> > The default method for calculating the number of connections allowed
> > per RPC service arbitrarily limits single-threaded services to 80
> > connections. This is too low for services like lockd and artificially
> > limits the number of TCP clients that it can support.
> > 
> > Have lockd set a default sv_maxconn value to RLIMIT_NOFILE for the
> > lockd thread (usually this will be 1024). Also add a module parameter
> > to allow an admin to set this to an arbitrary value at module load
> > time.
> 
> I guess this is OK.
> 
> As long as we're picking a number out of thin air, I'd rather we make
> that obvious, instead of making it look like we made some kind of
> sophisticated choice that the poor reader will feel obliged to
> understand.
> 
> So I'd be for a default that's just a constant, until someone has a
> better idea.
> 
> What would actually happen if we allowed too many connections?  What
> would fail first?  Is there some way to detect that situation and use
> that to drop connections?
> 

I've gone ahead and respun these patches. The main changes are:

- fixed the printk in svc_check_conn_limits()
- changed the default sv_maxconn to just use a constant value and added
  a comment to clarify that it's basically arbitrary
- made it so that sv_maxconn is updated in lockd's main loop so this
  value can be changed on the fly

Look OK?
-- 
Jeff Layton <jlayton@redhat.com>
