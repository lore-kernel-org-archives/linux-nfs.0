Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758369Ab2DJSoW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2012 14:44:22 -0400
Date: Tue, 10 Apr 2012 14:45:05 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120410144505.58bca0b9@corrin.poochiereds.net>
In-Reply-To: <4F84493C.1040303@parallels.com>
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
	<4F841D2A.9020504@parallels.com>
	<20120410081612.65dd25fa@tlielax.poochiereds.net>
	<4F842BAE.2010804@parallels.com>
	<20120410093900.20209d00@tlielax.poochiereds.net>
	<4F84493C.1040303@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Apr 2012 18:52:44 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 10.04.2012 17:39, Jeff Layton пишет:
> > On Tue, 10 Apr 2012 16:46:38 +0400
> > Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
> >
> >> 10.04.2012 16:16, Jeff Layton пишет:
> >>> On Tue, 10 Apr 2012 15:44:42 +0400
> >>>
> >>> (sorry about the earlier truncated reply, my MUA has a mind of its own
> >>> this morning)
> >>>
> >>
> >> OK then. Previous letter confused me a bit.
> >>
> >>>
> >>> TBH, I haven't considered that in depth. That is a valid situation, but
> >>> one that's discouraged. It's very difficult (and expensive) to
> >>> sequester off portions of a filesystem for serving.
> >>>
> >>> A filehandle is somewhat analogous to a device/inode combination. When
> >>> the server gets a filehandle, it has to determine "is this within a
> >>> path that's exported to this host"? That process is called subtree
> >>> checking. It's expensive and difficult to handle. It's always better to
> >>> export along filesystem boundaries.
> >>>
> >>> My suggestion would be to simply not deal with those cases in this
> >>> patch. Possibly we could force no_subtree_check when we export an fs
> >>> with a locks_in_grace option defined.
> >>>
> >>
> >> Sorry, but without dealing with those cases your patch looks a bit... Useless.
> >> I.e. it changes nothing, it there will be no support from file systems, going to
> >> be exported.
> >> But how are you going to push developers to implement these calls? Or, even if
> >> you'll try to implement them by yourself, how they will looks like?
> >> Simple check only for superblock looks bad to me, because any other start of
> >> NFSd will lead to grace period for all other containers (which uses the same
> >> filesystem).
> >>
> >
> > Changing nothing was sort of the point. The idea was to allow
> > filesystems to override this if they choose. The main impetus here was
> > to allow clustered filesystems to handle this in a different fashion to
> > allow them to do active/active serving from multiple nodes. I wasn't
> > considering the container use-case when I spun this up last week...
> >
> 
> Sorry, I didn't notice, that this patch was sent a week ago (thought, that you 
> wrote it yesterday).
> 
> > Now that said, we probably can accommodate containers with this too.
> > Perhaps we could consider passing in a sb+namespace tuple eventually?
> >
> 
> We can, of course. But it looks like the problem with different NFSd on the same 
> file system won't be solved.
> 

Probably not. I think the only way to solve that is to coordinate grace
periods for filesystems exported from multiple containers.

What may be a lot easier initially is to only allow a fs to be exported
from one container. You could always lift that restriction later if you
come up with a way to handle it safely.

We will probably need to re-think the current design of mountd and
exportfs in order to enforce that however.

> >>>> Also, don't we need to prevent of exporting the same file system parts but
> >>>> different servers always, but not only for grace period?
> >>>>
> >>>
> >>> I'm not sure I understand what you're asking here. Were you referring
> >>> to my suggestion earlier of not allowing the export of the same
> >>> filesystem from more than one container? If so, then yes that would
> >>> apply before and after the grace period ends.
> >>>
> >>
> >> I was talking about preventing of exporting intersecting directories by
> >> different server.
> >> IOW, exporting of the same file system by different NFS server is allowed, but
> >> only if their exporting directories doesn't intersect.
> >
> > Doesn't that require that the containers are aware of each other to
> > some degree? Or are you considering doing this in the kernel?
> >
> > If the latter, then there's another problem. The export table is kept
> > in userspace (in mountd) and the kernel only upcalls for it as needed.
> >
> > You'll need to change that overall design if you want the kernel to do
> > this enforcement.
> >
> 
> Hmm, I see...
> Yes, I was thinking about doing it in kernel.
> In theory (I'm just thinking and writing simultaneously - this is not a solid 
> idea) this could be a kernel thread (this gives desired fs access). And most 
> probably this thread have to be launched on nfsd module insertion.
> There should be some way to add a job for it on NFSd start and a way to wait for 
> the job to be done. This is the easy part.
> But I forgot about cross mounts...
>
> >> This check is expensive (as you mentioned), but have to be done only once on NFS
> >> server start.
> >
> > Well, no. The subtree check happens every time nfsd processes a
> > filehandle -- see nfsd_acceptable().
> >
> > Basically we have to turn the filehandle into a dentry and then walk
> > back up to the directory that's exported to verify that it is within
> > the correct subtree. If that fails, then we might have to do it more
> > than once if it's a hardlinked file.
> >
> 
> Wait. Looks like I'm missing something.
> This subtree check has nothing with my proposal (if I'm not mistaken).
> This option and it's logic remains the same.
> My proposal was to check directories, desired to be exported, on NFS server 
> start. And if any of passed exports intersects with any of exports, already 
> shared by another NFSd - then shutdown NFSd and print error message.
> Am I missing the point here?
> 

Sorry I got confused with the discussion. You will need to do
something similar to what subtree checking does in order to handle
your proposal however.

> >> With this solution, grace period can simple, and no support from exporting file
> >> system is required.
> >> But the main problem here is that such intersections can be checked only in
> >> initial file system environment (containers with it's own roots, gained via
> >> chroot, can't handle this situation).
> >> So, it means, that there have to be some daemon (kernel or user space), which
> >> will handle such requests from different NFS server instances... Which in turn
> >> means, that some way of communication between this daemon and NFS servers is
> >> required. And unix (any of them) sockets doesn't suits here, which makes this
> >> problem more difficult.
> >>
> >
> > This is a truly ugly problem, and unfortunately parts of the nfsd
> > codebase are very old and crusty. We've got a lot of cleanup work ahead
> > of us no matter what design we settle on.
> >
> > This is really a lot bigger than the grace period. I think we ought to
> > step back a bit and consider this more "holistically" first. Do you
> > have a pointer to an overall design document or something?
> >
> 
> What exactly you are asking about? Overall design of containerization?
> 

I meant containerization of nfsd in particular.

> > One thing that puzzles me at the moment. We have two namespaces to deal
> > with -- the network and the mount namespace. With nfs client code,
> > everything is keyed off of the net namespace. That's not really the
> > case here since we have to deal with a local fs tree as well.
> >
> > When an nfsd running in a container receives an RPC, how does it
> > determine what mount namespace it should do its operations in?
> >
> 
> We don't use mount namespaces, so that's why I wasn't thinking about it...
> But if we have 2 types of namespaces, then we have to tie  mount namesapce to 
> network. I.e we can get desired mount namespace from per-net NFSd data.
> 

One thing that Bruce mentioned to me privately is that we could plan to
use whatever mount namespace mountd is using within a particular net
namespace. That makes some sense since mountd is the final arbiter of
who gets access to what.

> But, please, don't ask me, what will be, if two or more NFS servers shares the 
> same mount namespace... Looks like this case should be forbidden.
> 

I'm not sure we need to forbid sharing the mount namespace. They might
be exporting completely different filesystems after all, in which case
we'd be forbidding it for no good reason.

Note that it is quite easy to get lost in the weeds with this. I've been
struggling to get a working design for a clustered nfsv4 server for the
last several months and have had some time to wrestle with these
issues. It's anything but trivial.

What you may need to do in order to make progress is to start with some
valid use-cases for this stuff, and get those working while disallowing
or ignoring other use cases. We'll never get anywhere if we try to solve
all of these problems at once...

-- 
Jeff Layton <jlayton@redhat.com>
