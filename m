From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/6] nfs-utils: add IPv6 support to nfsd
Date: Tue, 26 May 2009 12:49:07 -0400
Message-ID: <20090526124907.4b711eaa@tlielax.poochiereds.net>
References: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
	<1243350951-13462-5-git-send-email-jlayton@redhat.com>
	<43AF9911-DDC3-47C5-956C-1871ABF019D7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56534 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756245AbZEZQtN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 12:49:13 -0400
In-Reply-To: <43AF9911-DDC3-47C5-956C-1871ABF019D7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 26 May 2009 11:24:05 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Jeff-
> 
> On May 26, 2009, at 11:15 AM, Jeff Layton wrote:
> 
> > Add 2 new options to rpc.nfsd -- -4 and -6. -4 makes it an IPv4-only
> > server, and -6 makes it IPv6-only. Restructure the -H option so that
> > if the address appears to be or resolves to an IPv4 address, that
> > IPv6 is disabled. Ditto if it resolves to an IPv6 address.
> 
> The new rpc.statd doesn't have a "-4" or "-6" option.  It looks in / 
> etc/netconfig to start only the visible transports.  I was suggesting  
> that rpc.nfsd use /etc/netconfig _instead_ of having a -4/-6 command- 
> line option.
> 
> Just a thought.
> 

I don't feel strongly about it either way. It seems reasonable that
someone might want to disable ipv4 or ipv6 without changing
/etc/netconfig. This also has some parity with the -T and -U options
too...

It would be good however to have nfsd and statd share options and
behavior here, so I think we should implement the same convention for
both. Do you think it would be better to remove -4/-6 from nfsd, or add
those options to the new statd?

-- 
Jeff Layton <jlayton@redhat.com>
