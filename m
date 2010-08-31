Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756811Ab0HaMkC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 08:40:02 -0400
Date: Tue, 31 Aug 2010 08:43:23 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100831084323.02a1abf5@corrin.poochiereds.net>
In-Reply-To: <4C7CF499.5090003@RedHat.com>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
	<4C7BD394.3030705@RedHat.com>
	<20100830121600.529669bd@tlielax.poochiereds.net>
	<4C7BE1FC.2020400@RedHat.com>
	<20100830134801.1696dffa@tlielax.poochiereds.net>
	<4C7CF499.5090003@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 31 Aug 2010 08:24:57 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 08/30/2010 01:48 PM, Jeff Layton wrote:
> > On Mon, 30 Aug 2010 12:53:16 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> >>>
> >>> Hmmm...if I had known that it was ok to stop supporting old kernels,
> >>> the IPv6 support for rpc.nfsd would have been a heck of a lot easier to
> >>> implement.
> >> I thought you said the legacy interface would not work with IPV6 or
> >> did I misunderstand you? 
> >>
> > 
> > Sorry, forgot to answer this part. IPv6 indeed will not work when using
> > the legacy interface. In order to get the IPv6 code in though, I ended
> > up rewriting a large swath of rpc.nfsd. That task would have been
> > easier had I not needed to deal with the legacy nfsctl() interface.
> > 
> So I'm thinking this the final nail in the coffin of the legacy interface
> at least in rpc.nfsd. So if /proc/fs/nfsd filesystem is not or can not
> be mounted then rpc.nfsd should fail... IMHO...
> 
> Maybe something like:
> 
> if (stat("/proc/fs/nfsd") < 0) {

This needs to check a file within /proc/fs/nfsd. The nfsd "dir" may
already exist even if it's not mounted. I chose "threads" but any file
in there would do...

>     if (system("mount /proc/fs/nfsd") < 0) {
>         xlog(L_ERROR, "Unable to mount /proc/fs/nfsd");
>         exit 0;
>     }
> }
> 
> steved.

That will universally fail, at least on most distros.

When you go to mount /proc/fs/nfsd, the system does a request_module()
for nfsd.ko. On most distros (e.g. Fedora or RHEL), modprobe will then
automatically mount up /proc/fs/nfsd. request_module will then return
and the mount attempt will proceed. The mount will then fail because
it's now already mounted, and the system() call will return non-zero.

That's the main reason I ignored the return code from system() in the
original patch. What you could do is recheck whether the file exists
after the mount attempt, and then fail if it doesn't.

Is that really what we want to do here though? How does ditching the
legacy interface move us forward now? If we had decided to do this a
year ago when I was overhauling rpc.nfsd, it might have made sense. The
code exists now though and it works. Ripping this out seems more
disruptive than just leaving it in.

To keep this on track, I think we need to treat this as 2 separate
discussions:

1) how to we ensure that /proc/fs/nfsd is actually mounted when
rpc.nfsd is run?

2) what do we do about the legacy nfsctl() interface?

These are separate but related questions...
-- 
Jeff Layton <jlayton@redhat.com>
