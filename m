From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/2] lockd: set svc_serv->sv_maxconn to a more
 reasonable value
Date: Mon, 20 Oct 2008 11:49:33 +1100
Message-ID: <18683.54685.61422.969081@notabene.brown>
References: <1224267970-15769-1-git-send-email-jlayton@redhat.com>
	<1224267970-15769-2-git-send-email-jlayton@redhat.com>
	<20081017211833.GF14960@fieldses.org>
	<20081017181057.2b15b458@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:46882 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751630AbYJTAtU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Oct 2008 20:49:20 -0400
In-Reply-To: message from Jeff Layton on Friday October 17
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday October 17, jlayton@redhat.com wrote:
> 
> I'm OK with that too. I just used this since Neil suggested it. I have
> no idea what a reasonable value should really be. I suppose this should
> probably be set to the maximum number of clients we expect to support
> (assuming 1 connection to lockd from each client).

I suggested it (using the NFILE rlimit) because I was looking for a
natural way to make it configurable, and asked myself "how would this
be handled by a user-space daemon".  I managed to address one of those
questions, but not really the more useful one.

> 
> > What would actually happen if we allowed too many connections?  What
> > would fail first?  Is there some way to detect that situation and use
> > that to drop connections?
> > 
> 
> I'm not clear on this either. Here's my naive take (could be very 
> wrong):

I've got no really idea either.
But when we are building network-facing software, you need to be
cautious and use the "deny unless explicitly permitted" approached.
It may be safe to allow an arbitrarily large number of connections.
But until you can be certain of that you should fail-safe and impose a
limit.

NeilBrown
