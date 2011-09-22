Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752650Ab1IVObY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 10:31:24 -0400
Date: Thu, 22 Sep 2011 10:34:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: regression when opening directories on NFSv4
Message-ID: <20110922103443.76c372da@barsoom.rdu.redhat.com>
In-Reply-To: <1316633412.21183.59.camel@lade.trondhjem.org>
References: <20110921115854.02605a7f@tlielax.poochiereds.net>
 <1316631192.21183.40.camel@lade.trondhjem.org>
 <20110921151039.4dc77b8c@tlielax.poochiereds.net>
 <1316633412.21183.59.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 21 Sep 2011 15:30:12 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2011-09-21 at 15:10 -0400, Jeff Layton wrote: 
> > On Wed, 21 Sep 2011 14:53:12 -0400
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Wed, 2011-09-21 at 11:58 -0400, Jeff Layton wrote: 
> > > > We had a regression reported against RHEL concerning the opening of
> > > > directories and it looks like that same problem is in current mainline
> > > > code too. If you do the following on a directory that is not yet in the
> > > > dcache you get an EISDIR error:
> > > > 
> > > >      open("/mnt/nfs/dir1", O_RDONLY)         = -1 EISDIR (Is a directory)
> > > > 
> > > > If however, you stat the directory first, the open works. The
> > > > difference seems to be that in the first case we're going through the
> > > > lookup codepath, and in the second we go through d_revalidate.
> > > > 
> > > > In the first case, we send an OPEN call to the server and it responds
> > > > with NFS4ERR_ISDIR. That gets translated to -EISDIR, and returned to
> > > > userspace. It wasn't always this way though, and I think the regression
> > > > was introduced in commit d953126a2.
> > > > 
> > > > That patch was added to fix an oops due to a buggy server, and I'm
> > > > unclear on how best to fix this. It seems like we need to allow the
> > > > server to fall back to doing a normal lookup when we get -EISDIR on the
> > > > OPEN call, but how do we ensure that we don't end up with the same oops
> > > > from that server bug?
> > > 
> > > How about returning an error if we get to the file->f_ops->open on a
> > > regular file in NFSv4?
> > > 
> > 
> > That would probably be reasonable. I'll see if I can come up with a
> > patch. The tricky part of course is ensuring that nothing regresses...
> > 
> > I think this is probably safe for the most part. The d_revalidate
> > codepath has always allowed you to end up with an open context with
> > NULL state. 
> > 
> > Granted the buggy server case here is exceedingly rare, but it seems
> > like the code already assumes that a ctx reached via filp may have a
> > NULL state pointer.
> 
> I agree that the buggy server is rare, but you can potentially reproduce
> the problem using something like the following script
> 
> mkdir b; touch a; while true do mv a c; mv b a; mv c b; done
> 
> It will probably mostly either succeed or fail with ENOENT, but every
> now and then it should be possible to tickle the above issue.
> 

Ok, I sent you a patch that fixes the bug.

I ran the above on the server and a program in a loop that did opens on
the client, but was never able to reproduce the server-side bug. It
seemed to be OK in other testing though.
-- 
Jeff Layton <jlayton@redhat.com>
