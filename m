Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42703 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758238Ab1FWCb2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 22:31:28 -0400
Date: Thu, 23 Jun 2011 12:31:17 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix host_reliable_addrinfo (try #2)
Message-ID: <20110623123117.40403d5f@notabene.brown>
In-Reply-To: <20110622133238.019d6157@tlielax.poochiereds.net>
References: <1308756953-10277-1-git-send-email-jlayton@redhat.com>
	<268F789B-6679-4E24-A9F4-7D6E9FB44040@oracle.com>
	<20110622133238.019d6157@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 22 Jun 2011 13:32:38 -0400 Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 22 Jun 2011 10:50:11 -0600
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > Thanks.
> > 
> > This is a security problem, but I don't want to lose sight of the original cause of this bug, which was my lack of understanding of the function of the old code and the API contract (return only _one_ address).
> > 
> > For extra credit, we might check if statd has a similar issue when it matches addresses.
> > 
> 
> I don't think statd is vulnerable, as best I can tell. I don't see any
> places where we do a getnameinfo on an address and then go and use that
> to get a list of addresses with getaddrinfo.
> 
> Please do double check me on this though. I go on vacation next week
> and I think my brain might already have left.
> 

Agggh... my eyes tend to glaze over whenever I try to think about statd :-(

However:
  statd gets MON/UNMON requests from the kernel lockd, and NOTIFY requests
  from other hosts that have rebooted.

  The MON/UNMON requests can only contain a host name or IP that has been
  explicity requested locally so we have to basically trust though - though
  all we do with them it talk to the remote host a bit.

  The NOTIFY request contains a host name and if we are monitoring anything
  that which has that name, we assume that it has rebooted.
  The remote host that sends the NOTIFY could well be lying, but there is no
  a whole lot that we can do about that.  This is a fundamental issue in the
  protocol rather than any mishandling of host name lookup.

So I think statd looks as safe as it ever has been.

NeilBrown

