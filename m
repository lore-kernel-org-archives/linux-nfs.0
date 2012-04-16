Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14533 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753213Ab2DPLgT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 07:36:19 -0400
Date: Mon, 16 Apr 2012 07:36:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: Malahal Naineni <malahal@us.ibm.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        pstaubach@exagrid.com, miklos@szeredi.hu, viro@ZenIV.linux.org.uk,
        hch@infradead.org, michael.brantley@deshaw.com,
        sven.breuner@itwm.fraunhofer.de
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120416073655.7cdb90cf@corrin.poochiereds.net>
In-Reply-To: <4F8B1B7B.3040304@itwm.fraunhofer.de>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 15 Apr 2012 21:03:23 +0200
Bernd Schubert <bernd.schubert@itwm.fraunhofer.de> wrote:

> On 04/13/2012 05:42 PM, Jeff Layton wrote:
> > (note: please don't trim the CC list!)
> > 
> > Indefinitely does make some sense (as Peter articulated in his original
> > set). It's possible you could race several times in a row, or a server
> > misconfiguration or something has happened and you have a transient
> > error that will eventually recover. His assertion was that any limit on
> > the number of retries is by definition wrong. For NFS, a fatal signal
> > ought to interrupt things as well, so retrying indefinitely has some
> > appeal there.
> > 
> > OTOH, we do have to contend with filesystems that might return ESTALE
> > persistently for other reasons and that might not respond to signals.
> > Miklos pointed out that some FUSE fs' do this in his review of Peter's
> > set.
> > 
> > As a purely defensive coding measure, limiting the number of retries to
> > something finite makes sense. If we're going to do that though, I'd
> > probably recommend that we set the number of retries be something
> > higher just so that this is more resilient in the face of multiple
> > races. Those other fs' might "spin" a bit in that case but it is an
> > error condition and IMO resiliency trumps performance -- at least in
>  this case.
> 
> I am definitely voting against an infinite number of retries. I'm
> working on FhGFS, which supports distributed meta data servers. So when
> a file is moved around between directories, its file handle, which
> contains the meta-data target id might become invalid. As NFSv3 is
> stateless we cannot inform the client about that and must return ESTALE
> then. NFSv4 is better, but I'm not sure how well invalidating a file
> handle works. So retrying once on ESTALE might be a good idea, but
> retrying forever is not.

It's important to note that I'm only proposing to wrap syscalls this
way that take a pathname argument. We can't do anything about those
that don't since at that point we have no way to retry the lookup.

So, I'm not sure this patch would affect the case you're concerned
about one way or another. If you move the file to a different
directory, then it's pathname would also change, and at that point
you'd end up with an ENOENT error or something on the next retry.

If the file was open and you were (for instance) reading or writing to
it from a client when you moved it, then we can't retry the lookup at
that point. The open is long since done and the pathname is now gone.
You'll get an ESTALE back in userspace regardless.

> Also, what about asymmetric HA servers? I believe to remember that also
> resulted in ESTALE. So for example server1 exports /home and /scratch,
> but on failure server2 can only take over /home and denies access to
> /scratch.
> 

That sounds like a broken cluster configuration. Still...

Presumably at some point in the future, a sysadmin would intervene and
fix the situation such that /scratch is available again. Is it better
to return an error to the application at that point, or simply allow it
to keep retrying until the problem has been fixed?

The person with the long running job that's doing operations
in /scratch would probably prefer the latter. If not, then they could
always send the program a fatal signal to stop it altogether.

-- 
Jeff Layton <jlayton@redhat.com>
