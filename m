Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752086Ab2DPSL5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 14:11:57 -0400
Date: Mon, 16 Apr 2012 13:46:42 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: Malahal Naineni <malahal@us.ibm.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        pstaubach@exagrid.com, miklos@szeredi.hu, viro@ZenIV.linux.org.uk,
        hch@infradead.org, michael.brantley@deshaw.com,
        sven.breuner@itwm.fraunhofer.de
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120416134642.1754cd3e@corrin.poochiereds.net>
In-Reply-To: <4F8C3036.2030702@itwm.fraunhofer.de>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 16 Apr 2012 16:44:06 +0200
Bernd Schubert <bernd.schubert@itwm.fraunhofer.de> wrote:

> >> I am definitely voting against an infinite number of retries. I'm
> >> working on FhGFS, which supports distributed meta data servers. So when
> >> a file is moved around between directories, its file handle, which
> >> contains the meta-data target id might become invalid. As NFSv3 is
> >> stateless we cannot inform the client about that and must return ESTALE
> >> then. NFSv4 is better, but I'm not sure how well invalidating a file
> >> handle works. So retrying once on ESTALE might be a good idea, but
> >> retrying forever is not.
> >
> > It's important to note that I'm only proposing to wrap syscalls this
> > way that take a pathname argument. We can't do anything about those
> > that don't since at that point we have no way to retry the lookup.
> >
> > So, I'm not sure this patch would affect the case you're concerned
> > about one way or another. If you move the file to a different
> > directory, then it's pathname would also change, and at that point
> > you'd end up with an ENOENT error or something on the next retry.
> >
> > If the file was open and you were (for instance) reading or writing to
> > it from a client when you moved it, then we can't retry the lookup at
> > that point. The open is long since done and the pathname is now gone.
> > You'll get an ESTALE back in userspace regardless.
> 
> Yes, sorry, I should have read the patch and its description more carefully.
> 
> >
> >> Also, what about asymmetric HA servers? I believe to remember that also
> >> resulted in ESTALE. So for example server1 exports /home and /scratch,
> >> but on failure server2 can only take over /home and denies access to
> >> /scratch.
> >>
> >
> > That sounds like a broken cluster configuration. Still...
> 
> Simply budget and safety. I had to do that in the past, /home was 
> mirrored via drbd, but /scratch was not. And although /scratch was on an 
> external raid system, I simply did not setup a connection to the 
> failover system. HA software is not reliable and extensive testing 
> revealed possible split brain situations with corrupting double mounts. 
> Nowadays there are ext4 + enabled MMP, but in 2004 there was no such 
> additional protection.
> 
> >
> > Presumably at some point in the future, a sysadmin would intervene and
> > fix the situation such that /scratch is available again. Is it better
> > to return an error to the application at that point, or simply allow it
> > to keep retrying until the problem has been fixed?
> >
> > The person with the long running job that's doing operations
> > in /scratch would probably prefer the latter. If not, then they could
> > always send the program a fatal signal to stop it altogether.
> >
> 
> That was not a compute cluster, but the diskless desktop environment. 
> And things get difficult if desktop evironments start to hang. I'm not 
> sure if a soft mount is the solution then, as users do not like to kill 
> their running desktops. And with kde and gnome and their habit to 
> monitor everything it might not be easy to kill their proccesses 
> monitoring /scratch without killing the entire desktop.
> But then I'm not sure if anyone still is doing async HA clusters and how 
> applications react to that nowadays. I just wonder if it is always a 
> good idea to loop forever in ESTALE in such situations.
> 

NFS will generally return a different error if the process catches a
fatal signal, so a soft mount should not be necessary and is not
recommended anyway...

In any case, we loop indefinitely now in the NFS code when (for
instance) there's a loss of communication. Users are not generally
happy if that causes an error, since their applications start dying.

While an ESTALE return is different, there are some parallels.

The question about looping indefinitely really comes down to:

1) is a persistent ESTALE in conjunction with a successful lookup a
situation that we expect to be temporary. i.e. will the admin at some
point be able to do something about it? If not, then there's no point
in continuing to retry. Again, this is a situation that *really* should
not happen if the filesystem is doing the right thing.

2) If the admin can't do anything about it, is it reasonable to expect
that users can send a fatal signal to hung applications if this
situation occurs.

We expect that that's ok in other situations to resolve hung
applications, so I'm not sure I understand why it wouldn't be
acceptable here...

-- 
Jeff Layton <jlayton@redhat.com>
