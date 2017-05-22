Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:60700 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932956AbdEVQyB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 12:54:01 -0400
Message-ID: <1495472039.2757.19.camel@HansenPartnership.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: David Howells <dhowells@redhat.com>, trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com,
        Linux Containers <containers@lists.linux-foundation.org>
Date: Mon, 22 May 2017 09:53:59 -0700
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Added missing cc to containers list]
On Mon, 2017-05-22 at 17:22 +0100, David Howells wrote:
> Here are a set of patches to define a container object for the kernel 
> and to provide some methods to create and manipulate them.
> 
> The reason I think this is necessary is that the kernel has no idea 
> how to direct upcalls to what userspace considers to be a container -
> current Linux practice appears to make a "container" just an 
> arbitrarily chosen junction of namespaces, control groups and files, 
> which may be changed individually within the "container".

This sounds like a step in the wrong direction: the strength of the
current container interfaces in Linux is that people who set up
containers don't have to agree what they look like.  So I can set up a
user namespace without a mount namespace or an architecture emulation
container with only a mount namespace.

But ignoring my fun foibles with containers and to give a concrete
example in terms of a popular orchestration system: in kubernetes,
where certain namespaces are shared across pods, do you imagine the
kernel's view of the "container" to be the pod or what kubernetes
thinks of as the container?  This is important, because half the
examples you give below are network related and usually pods share a
network namespace.

> The kernel upcall mechanism then needs to decide which set of 
> namespaces, etc., it must exec the appropriate upcall program. 
>  Examples of this include:
> 
>  (1) The DNS resolver.  The DNS cache in the kernel should probably 
> be per-network namespace, but in userspace the program, its
> libraries and its config data are associated with a mount tree and a 
> user namespace and it gets run in a particular pid namespace.

All persistent (written to fs data) has to be mount ns associated;
there are no ifs, ands and buts to that.  I agree this implies that if
you want to run a separate network namespace, you either take DNS from
the parent (a lot of containers do) or you set up a daemon to run
within the mount namespace.  I agree the latter is a slightly fiddly
operation you have to get right, but that's why we have orchestration
systems.

What is it we could do with the above that we cannot do today?

>  (2) NFS ID mapper.  The NFS ID mapping cache should also probably be
>      per-network namespace.

I think this is a view but not the only one:  Right at the moment, NFS
ID mapping is used as the one of the ways we can get the user namespace
ID mapping writes to file problems fixed ... that makes it a property
of the mount namespace for a lot of containers.  There are many other
instances where they do exactly as you say, but what I'm saying is that
we don't want to lose the flexibility we currently have.

>  (3) nfsdcltrack.  A way for NFSD to access stable storage for 
> tracking of persistent state.  Again, network-namespace dependent, 
> but also perhaps mount-namespace dependent.

So again, given we can set this up to work today, this sounds like more
a restriction that will bite us than an enhancement that gives us extra
features.

>  (4) General request-key upcalls.  Not particularly namespace 
> dependent, apart from keyrings being somewhat governed by the user
> namespace and the upcall being configured by the mount namespace.

All mount namespaces have an owning user namespace, so the data
relations are already there in the kernel, is the problem simply
finding them?

> These patches are built on top of the mount context patchset so that
> namespaces can be properly propagated over submounts/automounts.

I'll stop here ... you get the idea that I think this is imposing a set
of restrictions that will come back to bite us later.  If this is just
for the sake of figuring out how to get keyring upcalls to work, then
I'm sure we can come up with something.

James

