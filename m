Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755536Ab0H3RW6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Aug 2010 13:22:58 -0400
Date: Mon, 30 Aug 2010 13:22:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100830132245.13a1fa5b@tlielax.poochiereds.net>
In-Reply-To: <20100830170412.GC9316@fieldses.org>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
	<4C7BD394.3030705@RedHat.com>
	<20100830121600.529669bd@tlielax.poochiereds.net>
	<4C7BE1FC.2020400@RedHat.com>
	<20100830170412.GC9316@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 30 Aug 2010 13:04:12 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Aug 30, 2010 at 12:53:16PM -0400, Steve Dickson wrote:
> > On 08/30/2010 12:16 PM, Jeff Layton wrote:
> > > How this as an alternate proposal?
> > > 
> > > We attempt to mount up nfsdfs. If the "threads" file still isn't
> > > present after the attempt, we then log a warning and go with the
> > > nfsctl() interface?
> > Has anybody test this legacy interface lately?? Does anybody anybody
> > depend on the existence of this interface??? I would guess the answer
> > would be no to both questions... So I see this as an opportunity so
> > simplify the code... which is always a good thing... 
> > 

People do still use it because we get bug reports on it when it doesn't
work correctly. That said, mostly my guess is that people don't use it
knowingly -- they end up using it because /proc/fs/nfsd isn't mounted
at the time that they run rpc.nfsd.

> > So I would have no problem saying from the next release of nfs-utils,
> > the legacy interface is no longer supported... especially if there are
> > issues with IPV6.
> 
> In general I'd like backwards-compatibility to be a very high priority,
> in both directions.  (Both continuing to support old nfs-utils in new
> kernels, and supporting old kernels with new nfs-utils.)  Among other
> advantages, it makes it easier to troubleshoot user problems if we don't
> have to ask them to upgrade multiple packages at once to test a fix.
> 
> On the other hand, the nfsctl interface is pretty old (when did the new
> stuff go in, exactly?).
> 
> On the other other hand, Jeff's patch isn't really very complicated.
> (Though the amount of additional code we could delete might be large.)
> 

Not sure when it went in. I know that RHEL4 has it, so it was pre-2.6.9.

I like solutions that don't require extra steps by the user. If we just
log a message and error out then we're going to be requiring them to do
"extra stuff" to get a working NFS server. That seems less optimal to
me and will probably piss at least a few people off.

I also suspect that a lot of distros are going to break if we do that.
Most don't explicitly plug in nfsd.ko before they start calling
nfs-utils programs.

-- 
Jeff Layton <jlayton@redhat.com>
