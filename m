Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685Ab0H2CVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Aug 2010 22:21:31 -0400
Date: Sat, 28 Aug 2010 22:24:50 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, chuck.lever@oracle.com,
        steved@redhat.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100828222450.7ca62e49@corrin.poochiereds.net>
In-Reply-To: <20100829083853.4e95d2ee@notabene>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
	<20100829083853.4e95d2ee@notabene>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 29 Aug 2010 08:38:53 +1000
Neil Brown <neilb@suse.de> wrote:

> 
> (I might have just sent an empty reply to this - sorry 'bout that).
> 
> On Sat, 28 Aug 2010 07:35:14 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
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
> > 
> > To avoid this situation, have rpc.nfsd check to see if the "threads"
> > file is already present. If it's not, then make an attempt to mount
> > /proc/fs/nfsd.  This is a "best-effort" sort of thing, however so we
> > just ignore the return code from the mount attempt and fall back to
> > using nfsctl() if it fails.
> > 
> > Full disclosure: I'm not 100% thrilled with this patch. It seems ugly
> > and kludgey, but I don't see a better way to handle this problem.
> > Suggestions welcome.
> 
> I don't think it is all that bad.  It is a shame you have to use system()
> rather than just calling mount() directly but I guess we need that to
> update /etc/mtab.
> 

Yeah, that's the main reason I went with system(). It's worthwhile to
note that I'm using the exact same command that's in modprobe.conf on
fedora/RHEL.

> Suggestions:
> 
>  - just don't do that.  Use /etc/init.d/nfsserver start (or whatever the
>    distro uses).

I don't think we should count on that. Most people will use that, but
it seems like we shouldn't require that for this to work as expected...

>  - Make /proc/fs/nfsd and auto-mount point.  That sounds like the systemd
>    approach.

Yes, I think systemd will take care of this eventually, but I think we
need something for existing distros that aren't using it yet.

>  - Print a warning message if the kernel is newer than 2.6 and nfsd-fs isn't
>    mounted - see "don't do that" above.

That's certainly an option, but it's less "automatic" than doing
something to try and get it mounted before we fall back to nfsctl().
For that reason I'm less enthusiastic about it.

>  - If nfsdfs isn't mounted, try a no-op via the nfsd syscall, like
>    NFSCTL_GETFD with invalid parameters.  This will trigger a mod-probe which
>    will trigger the mount.
>    Then check for the mounted filesystem again.  Yes, I think I like that one
>    the best.
> 

I considered that when I did this, but didn't know if we could count on
nfsdfs automatically being mounted up when nfsd.ko is plugged in. I
went with calling system() since I figured we'd be making less
assumptions about modprobe.conf configuration.

FWIW, at least on fedora the /bin/mount here usually returns an
error. /bin/mount calls mount() and that triggers a request_module()
for nfsdfs. That triggers modprobe to mount the fs, and /bin/mount then
returns an error since it's already mounted. The error though is
harmless in this case since the fs gets mounted up anyway.

If the consensus is that using a no-op nfsctl() call is better than
shelling out to /bin/mount here, then I'll go with that. It seems
though like the patch I've already proposed would allow for nfsdfs to
end up mounted even when modprobe.conf isn't set up to do it.

-- 
Jeff Layton <jlayton@redhat.com>
