Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab1KRCDB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Nov 2011 21:03:01 -0500
Date: Thu, 17 Nov 2011 21:03:08 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: John Hughes <john@Calva.COM>, Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
Message-ID: <20111117210308.4c5156fd@corrin.poochiereds.net>
In-Reply-To: <20111118015116.GA1959@umich.edu>
References: <4EC3FD8B.6000705@calvaedi.com>
	<20111116144718.78b2e288@corrin.poochiereds.net>
	<20111116234434.GA12882@umich.edu>
	<20111116203119.1d9c0dd6@corrin.poochiereds.net>
	<20111116203810.4e1b9d28@corrin.poochiereds.net>
	<4EC4EA91.5070607@Calva.COM>
	<4EC50882.2080803@Calva.COM>
	<20111117164630.394027e7@tlielax.poochiereds.net>
	<20111118015116.GA1959@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Nov 2011 20:51:16 -0500
Jim Rees <rees@umich.edu> wrote:

> I would argue that if you don't want your applications to stop working when
> your ticket expires, you shouldn't let the ticket expire.  If you don't want
> to have to renew your ticket, you should use an infinite ticket lifetime.
> 

That's the ideal situation, but shit happens, and losing a long-running
job can often be an expensive proposition.

> It sounds like you've made up your mind, but I would urge you to make this
> a mount option, analogous to the hard/soft mount option.

I've not made up my mind about anything, and in any case it's not my
decision to make. I think you need to convince Trond here... :)

I'm quite open to sane proposals as long as we can accomodate those who
are dependent on the current behavior. As I said before, when I
originally did the patches a couple of years ago, I sort of figured the
current behavior was a first approximation.

A mount option will be harder to implement than a rpc.gssd command-line
option, but it sounds reasonable. Still, it would be better not to have
to make this an either/or decision somehow.

-- 
Jeff Layton <jlayton@redhat.com>
