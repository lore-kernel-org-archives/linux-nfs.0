Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36417 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753591Ab0H2Thh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Aug 2010 15:37:37 -0400
Date: Sun, 29 Aug 2010 15:37:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com, steved@redhat.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100829193717.GB1627@fieldses.org>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
 <20100829083853.4e95d2ee@notabene>
 <20100828222450.7ca62e49@corrin.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100828222450.7ca62e49@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 28, 2010 at 10:24:50PM -0400, Jeff Layton wrote:
> On Sun, 29 Aug 2010 08:38:53 +1000
> Neil Brown <neilb@suse.de> wrote:
> > I don't think it is all that bad.  It is a shame you have to use system()
> > rather than just calling mount() directly but I guess we need that to
> > update /etc/mtab.
> > 
> 
> Yeah, that's the main reason I went with system(). It's worthwhile to
> note that I'm using the exact same command that's in modprobe.conf on
> fedora/RHEL.
> 
> > Suggestions:
> > 
> >  - just don't do that.  Use /etc/init.d/nfsserver start (or whatever the
> >    distro uses).
> 
> I don't think we should count on that. Most people will use that, but
> it seems like we shouldn't require that for this to work as expected...
> 
> >  - Make /proc/fs/nfsd and auto-mount point.  That sounds like the systemd
> >    approach.
> 
> Yes, I think systemd will take care of this eventually, but I think we
> need something for existing distros that aren't using it yet.

I thought Neil was saying that this would be a "systemd-like" approach,
not that it would actually require systemd.  Am I missing something?

I can't come up with an immediate objection.  I'm also not opposed to
your patch as it stands.

--b.
