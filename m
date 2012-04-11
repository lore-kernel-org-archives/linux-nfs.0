Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39392 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756306Ab2DKLs1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2012 07:48:27 -0400
Date: Wed, 11 Apr 2012 07:48:22 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120411074822.0054eb36@tlielax.poochiereds.net>
In-Reply-To: <4F855864.8050509@parallels.com>
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
	<4F841D2A.9020504@parallels.com>
	<20120410081612.65dd25fa@tlielax.poochiereds.net>
	<4F842BAE.2010804@parallels.com>
	<20120410093900.20209d00@tlielax.poochiereds.net>
	<4F84493C.1040303@parallels.com>
	<20120410144505.58bca0b9@corrin.poochiereds.net>
	<4F855864.8050509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 11 Apr 2012 14:09:40 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 10.04.2012 22:45, Jeff Layton пишет:
> >>>> This check is expensive (as you mentioned), but have to be done only once on NFS
> >>>> server start.
> >>>
> >>> Well, no. The subtree check happens every time nfsd processes a
> >>> filehandle -- see nfsd_acceptable().
> >>>
> >>> Basically we have to turn the filehandle into a dentry and then walk
> >>> back up to the directory that's exported to verify that it is within
> >>> the correct subtree. If that fails, then we might have to do it more
> >>> than once if it's a hardlinked file.
> >>>
> >>
> >> Wait. Looks like I'm missing something.
> >> This subtree check has nothing with my proposal (if I'm not mistaken).
> >> This option and it's logic remains the same.
> >> My proposal was to check directories, desired to be exported, on NFS server
> >> start. And if any of passed exports intersects with any of exports, already
> >> shared by another NFSd - then shutdown NFSd and print error message.
> >> Am I missing the point here?
> >>
> >
> > Sorry I got confused with the discussion. You will need to do
> > something similar to what subtree checking does in order to handle
> > your proposal however.
> >
> 
> Agreed. But this check should be performed only once on NFS server start (not 
> every fh lookup.
> 
> >>>> With this solution, grace period can simple, and no support from exporting file
> >>>> system is required.
> >>>> But the main problem here is that such intersections can be checked only in
> >>>> initial file system environment (containers with it's own roots, gained via
> >>>> chroot, can't handle this situation).
> >>>> So, it means, that there have to be some daemon (kernel or user space), which
> >>>> will handle such requests from different NFS server instances... Which in turn
> >>>> means, that some way of communication between this daemon and NFS servers is
> >>>> required. And unix (any of them) sockets doesn't suits here, which makes this
> >>>> problem more difficult.
> >>>>
> >>>
> >>> This is a truly ugly problem, and unfortunately parts of the nfsd
> >>> codebase are very old and crusty. We've got a lot of cleanup work ahead
> >>> of us no matter what design we settle on.
> >>>
> >>> This is really a lot bigger than the grace period. I think we ought to
> >>> step back a bit and consider this more "holistically" first. Do you
> >>> have a pointer to an overall design document or something?
> >>>
> >>
> >> What exactly you are asking about? Overall design of containerization?
> >>
> >
> > I meant containerization of nfsd in particular.
> >
> 
> If you are asking about some kind of white paper, then I don't have it.
> But here are main visible targets:
> 1) Move all network-related resources to per-net data (caches, grace period, 
> lockd calls, transports, your tracking engine).
> 2) make nfsd filesystem superblock per network namespace.
> 3) service itself will be controlled like Lockd done (one pool for all, per-net 
> resources allocated on service start).
> 
> >>> One thing that puzzles me at the moment. We have two namespaces to deal
> >>> with -- the network and the mount namespace. With nfs client code,
> >>> everything is keyed off of the net namespace. That's not really the
> >>> case here since we have to deal with a local fs tree as well.
> >>>
> >>> When an nfsd running in a container receives an RPC, how does it
> >>> determine what mount namespace it should do its operations in?
> >>>
> >>
> >> We don't use mount namespaces, so that's why I wasn't thinking about it...
> >> But if we have 2 types of namespaces, then we have to tie  mount namesapce to
> >> network. I.e we can get desired mount namespace from per-net NFSd data.
> >>
> >
> > One thing that Bruce mentioned to me privately is that we could plan to
> > use whatever mount namespace mountd is using within a particular net
> > namespace. That makes some sense since mountd is the final arbiter of
> > who gets access to what.
> >
> 
> Could you, please, give some examples? I don't get the idea.
> 

When nfsd gets an RPC call, it needs to decide in what mount namespace
to do the fs operations. How do we decide this?

Bruce's thought was to look at what mount namespace rpc.mountd is using
and use that, but now that I consider it, it's a bit of a chicken and
egg problem really... nfsd talks to mountd via files in /proc/net/rpc/.
In order to talk to the right mountd, might you need to know what mount
namespace it's operating in?

A simpler method might be to take a reference to whatever mount
namespace rpc.nfsd has when it starts knfsd and keep that reference
inside of the nfsd_net struct. When a call comes in to a particular
nfsd "instance" you can just use that mount namespace.

> >> But, please, don't ask me, what will be, if two or more NFS servers shares the
> >> same mount namespace... Looks like this case should be forbidden.
> >>
> >
> > I'm not sure we need to forbid sharing the mount namespace. They might
> > be exporting completely different filesystems after all, in which case
> > we'd be forbidding it for no good reason.
> >
> 
> Actually, if we will make file system responsible for grace period control, then 
> yes, no reason for forbidding of shared mount namespace.
> 
> > Note that it is quite easy to get lost in the weeds with this. I've been
> > struggling to get a working design for a clustered nfsv4 server for the
> > last several months and have had some time to wrestle with these
> > issues. It's anything but trivial.
> >
> > What you may need to do in order to make progress is to start with some
> > valid use-cases for this stuff, and get those working while disallowing
> > or ignoring other use cases. We'll never get anywhere if we try to solve
> > all of these problems at once...
> >
> 
> Agreed.
> So, my current understanding of the situation can be summarized as follows:
> 
> 1) The idea of making grace period (and int internals) per networks namespace 
> stays the same. But it's implementation affect only current "generic grace 
> period" code.
> 

Yes, that's where you should focus your efforts for now. As I said, we
don't have any alternate grace period handling schemes yet, but we will
eventually need one to handle clustered filesystems and possibly the
case of serving the same local fs from multiple namespaces.

> 2) Your idea of making grace period per file system looks reasonable. And maybe 
> this approach (using of filesystem's export operations if available) have to be 
> used by default.
> But I suggest to add new option to exports (say, "no_fs_grace"), which will 
> disable this new functionality. With this option system administrator becomes 
> responsible for any problems with shared file system.
> 

Something like that may be a reasonable hack initially but we need to
ensure that we can deal with this properly later. I think we're going
to end up with "pluggable" grace period handling at some point, so it
may be more future proof to do something like "grace=simple" or
something instead of no_fs_grace. Still...

This is a complex enough problem that I think it behooves us to
consider it very carefully and come up with a clear design before we
code anything. We need to ensure that whatever we do doesn't end up
hamstringing other use cases later...

We have 3 cases that I can see that we're interested in initially.
There is some overlap between them however:

1) simple case of a filesystem being exported from a single namespace.
This covers non-containerized nfsd and containerized nfsd's that are
serving different filesystems.

2) a containerized nfsd that serves the same filesystem from multiple
namespaces.

3) a cluster serving the same filesystem from multiple namespaces. In
this case, the namespaces are also potentially spread across multiple
nodes as well.

There's a lot of overlap between #2 and #3 here.
-- 
Jeff Layton <jlayton@redhat.com>
