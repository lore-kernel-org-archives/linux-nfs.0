Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51855 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766Ab0H1WjD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Aug 2010 18:39:03 -0400
Date: Sun, 29 Aug 2010 08:38:53 +1000
From: Neil Brown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, chuck.lever@oracle.com,
        steved@redhat.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100829083853.4e95d2ee@notabene>
In-Reply-To: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


(I might have just sent an empty reply to this - sorry 'bout that).

On Sat, 28 Aug 2010 07:35:14 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> There's a bit of a chicken and egg problem when nfsd is run the first
> time. On Fedora/RHEL at least, /proc/fs/nfsd is mounted up whenever nfsd
> is plugged in via a modprobe.conf "install" directive.
> 
> If someone runs rpc.nfsd without plugging in nfsd.ko first,
> /proc/fs/nfsd won't be mounted and rpc.nfsd will end up using the legacy
> nfsctl interface. After that, nfsd will be plugged in and subsequent
> rpc.nfsd invocations will use that instead.
> 
> This is a problem as some nfsd command-line options are ignored when the
> legacy interface is used. It'll also be a problem for people who want
> IPv6 enabled servers. The upshot is that we really don't want to use the
> legacy interface unless there is no other option.
> 
> To avoid this situation, have rpc.nfsd check to see if the "threads"
> file is already present. If it's not, then make an attempt to mount
> /proc/fs/nfsd.  This is a "best-effort" sort of thing, however so we
> just ignore the return code from the mount attempt and fall back to
> using nfsctl() if it fails.
> 
> Full disclosure: I'm not 100% thrilled with this patch. It seems ugly
> and kludgey, but I don't see a better way to handle this problem.
> Suggestions welcome.

I don't think it is all that bad.  It is a shame you have to use system()
rather than just calling mount() directly but I guess we need that to
update /etc/mtab.

Suggestions:

 - just don't do that.  Use /etc/init.d/nfsserver start (or whatever the
   distro uses).
 - Make /proc/fs/nfsd and auto-mount point.  That sounds like the systemd
   approach.
 - Print a warning message if the kernel is newer than 2.6 and nfsd-fs isn't
   mounted - see "don't do that" above.
 - If nfsdfs isn't mounted, try a no-op via the nfsd syscall, like
   NFSCTL_GETFD with invalid parameters.  This will trigger a mod-probe which
   will trigger the mount.
   Then check for the mounted filesystem again.  Yes, I think I like that one
   the best.

NeilBrown

