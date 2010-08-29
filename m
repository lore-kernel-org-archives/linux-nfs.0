Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42840 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007Ab0H2WM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Aug 2010 18:12:57 -0400
Date: Mon, 30 Aug 2010 08:12:47 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com, steved@redhat.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100830081247.6d8eaaa3@notabene>
In-Reply-To: <20100829193717.GB1627@fieldses.org>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
	<20100829083853.4e95d2ee@notabene>
	<20100828222450.7ca62e49@corrin.poochiereds.net>
	<20100829193717.GB1627@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 29 Aug 2010 15:37:17 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Aug 28, 2010 at 10:24:50PM -0400, Jeff Layton wrote:
> > On Sun, 29 Aug 2010 08:38:53 +1000
> > Neil Brown <neilb@suse.de> wrote:
> > > I don't think it is all that bad.  It is a shame you have to use system()
> > > rather than just calling mount() directly but I guess we need that to
> > > update /etc/mtab.
> > > 
> > 
> > Yeah, that's the main reason I went with system(). It's worthwhile to
> > note that I'm using the exact same command that's in modprobe.conf on
> > fedora/RHEL.
> > 
> > > Suggestions:
> > > 
> > >  - just don't do that.  Use /etc/init.d/nfsserver start (or whatever the
> > >    distro uses).
> > 
> > I don't think we should count on that. Most people will use that, but
> > it seems like we shouldn't require that for this to work as expected...
> > 
> > >  - Make /proc/fs/nfsd and auto-mount point.  That sounds like the systemd
> > >    approach.
> > 
> > Yes, I think systemd will take care of this eventually, but I think we
> > need something for existing distros that aren't using it yet.
> 
> I thought Neil was saying that this would be a "systemd-like" approach,
> not that it would actually require systemd.  Am I missing something?

That is what I was saying, but making autofs or am-utils a pre-requisite for
nfsd doesn't sound like a good idea.  I would "like" it to work like this,
but I don't think it is really practical.

> 
> I can't come up with an immediate objection.  I'm also not opposed to
> your patch as it stands.

I agree, the 'no-op NFSD request' is very dependent on specific user-space
setup so we don't want to burn that into rpc.nfsd.

I support that patch as it stands.

NeilBrown
