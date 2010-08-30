Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755623Ab0H3QQK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Aug 2010 12:16:10 -0400
Date: Mon, 30 Aug 2010 12:16:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100830121600.529669bd@tlielax.poochiereds.net>
In-Reply-To: <4C7BD394.3030705@RedHat.com>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
	<4C7BD394.3030705@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 30 Aug 2010 11:51:48 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 08/28/2010 07:35 AM, Jeff Layton wrote:
> > There's a bit of a chicken and egg problem when nfsd is run the first
> > time. On Fedora/RHEL at least, /proc/fs/nfsd is mounted up whenever nfsd
> > is plugged in via a modprobe.conf "install" directive.
> > 
> > If someone runs rpc.nfsd without plugging in nfsd.ko first,
> > /proc/fs/nfsd won't be mounted and rpc.nfsd will end up using the legacy
> > nfsctl interface. After that, nfsd will be plugged in and subsequent
> > rpc.nfsd invocations will use that instead.
> > 
> > This is a problem as some nfsd command-line options are ignored when the
> > legacy interface is used. It'll also be a problem for people who want
> > IPv6 enabled servers. The upshot is that we really don't want to use the
> > legacy interface unless there is no other option.
> Well maybe its time we stop supporting the legacy interface... I
> would rather stop supporting something nobody uses then added
> some questionable code... Lets just error out when /proc/fs/nfsd
> is not mounted and log what needs to happen...
> 
> steved.
> 

Hmmm...if I had known that it was ok to stop supporting old kernels,
the IPv6 support for rpc.nfsd would have been a heck of a lot easier to
implement.

I'm not sure I like throwing up our hands and bailing out with a log
message. We'll be going from an at least somewhat carefully considered
fallback mechanism to an outright failure to start in this situation.
That doesn't really seem like an improvement to me...

How this as an alternate proposal?

We attempt to mount up nfsdfs. If the "threads" file still isn't
present after the attempt, we then log a warning and go with the
nfsctl() interface?

-- 
Jeff Layton <jlayton@redhat.com>
