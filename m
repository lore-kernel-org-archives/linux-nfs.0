Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55850 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752668AbdEWNwN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 09:52:13 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1495472039.2757.19.camel@HansenPartnership.com>
References: <1495472039.2757.19.camel@HansenPartnership.com> <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: dhowells@redhat.com, trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com,
        Linux Containers <containers@lists.linux-foundation.org>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 23 May 2017 14:52:09 +0100
Message-ID: <32556.1495547529@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> This sounds like a step in the wrong direction: the strength of the
> current container interfaces in Linux is that people who set up
> containers don't have to agree what they look like.

It may be a strength, but it is also a problem.

> So I can set up a user namespace without a mount namespace or an
> architecture emulation container with only a mount namespace.

(I presume you mean with only the mount namespace separate)

Yep.  You can do that with this too.

> But ignoring my fun foibles with containers and to give a concrete
> example in terms of a popular orchestration system: in kubernetes,
> where certain namespaces are shared across pods, do you imagine the
> kernel's view of the "container" to be the pod or what kubernetes
> thinks of as the container?

Why not both?  If the net_ns is created in the pod container, then probably
network-related upcalls should be directed there.  Unless instructed
otherwise, upon creation a container object will inherit the caller's
namespaces.

> This is important, because half the examples you give below are network
> related and usually pods share a network namespace.

Yeah - I'm more familiar with upcalls made by NFS, AFS and keyrings.

> >  (1) The DNS resolver.  ...
> 
> All persistent (written to fs data) has to be mount ns associated;
> there are no ifs, ands and buts to that.  I agree this implies that if
> you want to run a separate network namespace, you either take DNS from
> the parent (a lot of containers do)

My intention is to make the DNS cache per-network namespace within the kernel.
Currently, there's only one and it's shared between all namespaces, but that
won't work if you end up with two net namespaces that direct the same
addresses to different things.

> or you set up a daemon to run within the mount namespace.

That's not currently an option: the DNS service upcalls only, and
/sbin/request-key is invoked in the init_ns.  This performs the network
accesses in the wrong network namespace.

> I agree the latter is a slightly fiddly operation you have to get right, but
> that's why we have orchestration systems.

An orchestration system can use this.  This is not a replacement for
Kubernetes or Docker or whatever.

> What is it we could do with the above that we cannot do today?

Upcall into an appropriate set of namespaces and keep the results separate by
network namespace.

> >  (2) NFS ID mapper.  The NFS ID mapping cache should also probably be
> >      per-network namespace.
> 
> I think this is a view but not the only one:  Right at the moment, NFS
> ID mapping is used as the one of the ways we can get the user namespace
> ID mapping writes to file problems fixed ... that makes it a property
> of the mount namespace for a lot of containers.

In some ways it's really a property of the server, and two different servers
may appear in two separate network namespaces with the same apparent name and
address.

It's not a property of the mount namespace because mount namespaces share
superblocks, and this is done at the superblock level.

Possibly it should be done on the vfsmount, as a filter on the interaction
between userspace and kernel.

> There are many other instances where they do exactly as you say, but what
> I'm saying is that we don't want to lose the flexibility we currently have.

You don't really lose any flexibility; if anything, you gain it.

(Note that in case your objection is that I haven't yet implemented the
ability to set namespaces arbitrarily in a namespace, that's on list of things
to do that I included, as is adjusting the control groups.)

> All mount namespaces have an owning user namespace, so the data
> relations are already there in the kernel, is the problem simply
> finding them?

The superblocks used by the vfsmounts in a mount namespace aren't all
necessarily in the same user_ns, so none of:

	sb->s_user_ns == current_user_ns()
	sb->s_user_ns == current->ns->mnt_ns->user_ns
	current->ns->mnt_ns->user_ns == current_user_ns()

need hold true that I can see.

> > These patches are built on top of the mount context patchset so that
> > namespaces can be properly propagated over submounts/automounts.
> 
> I'll stop here ... you get the idea that I think this is imposing a set
> of restrictions that will come back to bite us later.

What restrictions am I imposing?

> If this is just for the sake of figuring out how to get keyring upcalls to
> work, then I'm sure we can come up with something.

No, it's not just for that, though, admittedly, all of the upcall mechanisms I
outlined use request_key() at the core.


Really, a container is an anchor for the resources you need to make an upcall,
but it can also be used to anchor other things.

One thing I've been asked for by a number of people is a per-container keyring
for the provision of authentication keys, fs decryption keys and other things
- but there's no actual container off which this can be hung.

Another thing that could be useful is a list of what device files a container
may access, so that we can allow limited mounting by the container root user
within the container.

Now these could be made into their own namespaces or added to one that already
exists - perhaps the mount namespace being the most logical.

David
