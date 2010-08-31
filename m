Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932343Ab0HaPGk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 11:06:40 -0400
Date: Tue, 31 Aug 2010 11:10:08 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100831111008.157618f4@corrin.poochiereds.net>
In-Reply-To: <4C7D1694.6000708@RedHat.com>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
	<4C7BD394.3030705@RedHat.com>
	<20100830121600.529669bd@tlielax.poochiereds.net>
	<4C7BE1FC.2020400@RedHat.com>
	<20100830134801.1696dffa@tlielax.poochiereds.net>
	<4C7CF499.5090003@RedHat.com>
	<20100831084323.02a1abf5@corrin.poochiereds.net>
	<4C7D1694.6000708@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 31 Aug 2010 10:49:56 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> > 
> > To keep this on track, I think we need to treat this as 2 separate
> > discussions:
> > 
> > 1) how to we ensure that /proc/fs/nfsd is actually mounted when
> > rpc.nfsd is run?
> > 
> > 2) what do we do about the legacy nfsctl() interface?
> > 
> > These are separate but related questions...

I was just pointing out that checking the return code from the system()
call isn't sufficient. Because of the way most people have modprobe set
up, it can return an error even though nfsdfs ended up being mounted
anyway. Checking for the presence of the file after attempting the
mount would be a more reliable test.

Assuming we're in agreement there, we have another question to
settle...If the mount attempt fails, what should we do about it?

With my original patch, we fall back to using nfsctl(). You're
suggesting that we should error out there. I'm not opposed to that, but
it does mean dropping support for some really old kernels. It also
means that we can remove some dead code in rpc.nfsd.

OTOH, the fallback might allow nfsd to keep working for some people.
Maybe it would be better to just log a scary warning and fall back to
using nfsctl() for now.

In a couple of releases, we could start returning an error there and
rip out the legacy interface code, or compile it out by default and
allow people to compile it in via a configure option?

-- 
Jeff Layton <jlayton@redhat.com>
