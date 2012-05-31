Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932486Ab2EaPkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 11:40:25 -0400
Date: Thu, 31 May 2012 11:40:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mount.nfs: try the next address after mount fails with
 ETIMEDOUT
Message-ID: <20120531114021.74b9a607@corrin.poochiereds.net>
In-Reply-To: <C16A9517-8334-4B2D-BFB1-D2C02AD66972@oracle.com>
References: <1338469436-5411-1-git-send-email-jlayton@redhat.com>
	<C16A9517-8334-4B2D-BFB1-D2C02AD66972@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 31 May 2012 10:28:49 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 31, 2012, at 9:03 AM, Jeff Layton wrote:
> 
> > If a NFS mount attempt fails with an ETIMEDOUT error, the mount.nfs code
> > doesn't currently attempt the next address in the list. For a NFSv4 mount
> > the initial mount() call almost always ends up going over
> > NFS_DEF_FG_TIMEOUT_MINUTES and the mount is never retried.
> > 
> > For a v3 mount, it ends up continually retrying against the same IPv6
> > address, and never tries the IPv4 address. Eventually it gives up once
> > it hits the NFS_DEF_FG_TIMEOUT_MINUTES timeout.
> > 
> > It's possible that a server is just unreachable via IPv6 (due to a
> > routing misconfiguration for instance), or is dropping IPv6 frames on
> > the floor. In that situation, it might still be reachable via IPv4 and
> > trying the next address could have allowed the mount to succeed.
> > 
> > Fix this by treating ETIMEDOUT in a similar fashion to ECONNREFUSED.
> > Have the client try the next address in the list before giving up and
> > returning an error.
> 
> Bzzzzt.  AF fallback is only legal to do if the admin did not specify a netid.
> 
> Can you demonstrate that your patch works correctly if an IPv6 netid is specified?  "Correctly" here means that no fallback occurs.
> 

If someone specifies an IPv6 netid (via proto= option) then we would
set AF_INET6 in the addrinfo "hints" and there will be no IPv4
addresses in the mi->address list. So, this does still work correctly
when someone specifies an ipv6 netid.

Chuck also pointed out on IRC that the description was a little
unclear, since it was specific to my test rig where the server had a
single IPv6 and IPv4 address in DNS.

The loop that retries against different addresses doesn't care
about whether the addrs are v4 or v6. What this really tells mount.nfs
to do is to keep trying different addresses in the list if there are
any instead of giving up on an ETIMEDOUT error.

-- 
Jeff Layton <jlayton@redhat.com>
