Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52207 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932359Ab0HaPvx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 11:51:53 -0400
Date: Tue, 31 Aug 2010 11:51:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100831155128.GB3071@fieldses.org>
References: <4C7BD394.3030705@RedHat.com>
 <20100830121600.529669bd@tlielax.poochiereds.net>
 <4C7BE1FC.2020400@RedHat.com>
 <20100830134801.1696dffa@tlielax.poochiereds.net>
 <4C7CF499.5090003@RedHat.com>
 <20100831084323.02a1abf5@corrin.poochiereds.net>
 <4C7D1694.6000708@RedHat.com>
 <20100831111008.157618f4@corrin.poochiereds.net>
 <20100831151342.GA3071@fieldses.org>
 <4C7D1D3B.1030607@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C7D1D3B.1030607@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 31, 2010 at 11:18:19AM -0400, Steve Dickson wrote:
> 
> 
> On 08/31/2010 11:13 AM, J. Bruce Fields wrote:
> > On Tue, Aug 31, 2010 at 11:10:08AM -0400, Jeff Layton wrote:
> >> I was just pointing out that checking the return code from the system()
> >> call isn't sufficient. Because of the way most people have modprobe set
> >> up, it can return an error even though nfsdfs ended up being mounted
> >> anyway. Checking for the presence of the file after attempting the
> >> mount would be a more reliable test.
> >>
> >> Assuming we're in agreement there, we have another question to
> >> settle...If the mount attempt fails, what should we do about it?
> >>
> >> With my original patch, we fall back to using nfsctl(). You're
> >> suggesting that we should error out there. I'm not opposed to that, but
> >> it does mean dropping support for some really old kernels. It also
> >> means that we can remove some dead code in rpc.nfsd.
> >>
> >> OTOH, the fallback might allow nfsd to keep working for some people.
> >> Maybe it would be better to just log a scary warning and fall back to
> >> using nfsctl() for now.
> >>
> >> In a couple of releases, we could start returning an error there and
> >> rip out the legacy interface code, or compile it out by default and
> >> allow people to compile it in via a configure option?
> > 
> > Yes, let's just add the additional mount attempt for now, and figure out
> > what to do about the legacy interface as a next step.
> When the mount fails, I think we should exit... basically eliminating the
> legacy interface code

Maybe.  But as I say, make it two separate steps:

	1. Add code to attempt the mount.
	2. Add code to turn off the legacy interface if the mount
	   doesn't work.

They're two separate issues with separate justifications.

--b.
