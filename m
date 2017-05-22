Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:34132 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752152AbdEVTVE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 15:21:04 -0400
Message-ID: <1495480860.9050.18.camel@HansenPartnership.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com,
        Linux Containers <containers@lists.linux-foundation.org>
Date: Mon, 22 May 2017 12:21:00 -0700
In-Reply-To: <1495478092.2816.17.camel@redhat.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <1495472039.2757.19.camel@HansenPartnership.com>
         <1495478092.2816.17.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-05-22 at 14:34 -0400, Jeff Layton wrote:
> On Mon, 2017-05-22 at 09:53 -0700, James Bottomley wrote:
> > [Added missing cc to containers list]
> > On Mon, 2017-05-22 at 17:22 +0100, David Howells wrote:
> > > Here are a set of patches to define a container object for the 
> > > kernel and to provide some methods to create and manipulate them.
> > > 
> > > The reason I think this is necessary is that the kernel has no 
> > > idea how to direct upcalls to what userspace considers to be a
> > > container - current Linux practice appears to make a "container" 
> > > just an arbitrarily chosen junction of namespaces, control groups 
> > > and files, which may be changed individually within the
> > > "container".
> > 
> > This sounds like a step in the wrong direction: the strength of the
> > current container interfaces in Linux is that people who set up
> > containers don't have to agree what they look like.  So I can set 
> > up a user namespace without a mount namespace or an architecture
> > emulation container with only a mount namespace.
> > 
> 
> Does this really mandate what they look like though? AFAICT, you can
> still spawn disconnected namespaces to your heart's content. What 
> this does is provide a container for several different namespaces so 
> that the kernel can actually be aware of the association between 
> them.

Yes, because it imposes a view of what is in a container.  As the
several replies have pointed out (and indeed as I pointed out below for
kubernetes), this isn't something the orchestration systems would find
usable.

>  The way you populate the different namespaces looks to be pretty
> flexible.

OK, but look at it another way: If we provides a container API no
actual consumer of container technologies wants to use just because we
think it makes certain tasks easy, is it really a good API?

Containers are multi-layered and complex.  If you're not ready for this
as a user, then you should use an orchestration system that prevents
you from screwing up.

> > But ignoring my fun foibles with containers and to give a concrete
> > example in terms of a popular orchestration system: in kubernetes,
> > where certain namespaces are shared across pods, do you imagine the
> > kernel's view of the "container" to be the pod or what kubernetes
> > thinks of as the container?  This is important, because half the
> > examples you give below are network related and usually pods share 
> > a network namespace.
> > 
> > > The kernel upcall mechanism then needs to decide which set of 
> > > namespaces, etc., it must exec the appropriate upcall program. 
> > >  Examples of this include:
> > > 
> > >  (1) The DNS resolver.  The DNS cache in the kernel should 
> > > probably be per-network namespace, but in userspace the program, 
> > > its libraries and its config data are associated with a mount 
> > > tree and a user namespace and it gets run in a particular pid
> > > namespace.
> > 
> > All persistent (written to fs data) has to be mount ns associated;
> > there are no ifs, ands and buts to that.  I agree this implies that 
> > if you want to run a separate network namespace, you either take 
> > DNS from the parent (a lot of containers do) or you set up a daemon 
> > to run within the mount namespace.  I agree the latter is a 
> > slightly fiddly operation you have to get right, but that's why we 
> > have orchestration systems.
> > 
> > What is it we could do with the above that we cannot do today?
> > 
> 
> Spawn a task directly from the kernel, already set up in the correct
> namespaces, a'la call_usermodehelper. So far there is no way to do
> that,

Today the usermode helper has to be namespace aware.  We spawn it into
the root namespace and it jumps into the correct namespace/cgroup
combination and re-executes itself or simply performs the requisite
task on behalf of the container.  Is this simple, no; does it work,
yes, provided the host OS is aware of what the container orchestration
system wants it to do.

> and it is something we'd very much desire. Ian Kent has made several
> passes at it recently.

Well, every time we try to remove some of the complexity from
userspace, we end up wrapping around the axle of what exactly we're
trying to achieve, yes.

> > >  (2) NFS ID mapper.  The NFS ID mapping cache should also 
> > > probably be per-network namespace.
> > 
> > I think this is a view but not the only one:  Right at the moment, 
> > NFS ID mapping is used as the one of the ways we can get the user
> > namespace ID mapping writes to file problems fixed ... that makes 
> > it a property of the mount namespace for a lot of containers. 
> >  There are many other instances where they do exactly as you say, 
> > but what I'm saying is that we don't want to lose the flexibility
> > we currently have.
> > 
> > >  (3) nfsdcltrack.  A way for NFSD to access stable storage for 
> > > tracking of persistent state.  Again, network-namespace 
> > > dependent, but also perhaps mount-namespace dependent.
> 
> Definitely mount-namespace dependent.
> 
> > 
> > So again, given we can set this up to work today, this sounds like 
> > more a restriction that will bite us than an enhancement that gives 
> > us extra features.
> > 
> 
> How do you set this up to work today?

Well, as above, it spawns into the root, you jump it to where it should
be and re-execute or simply handle in the host. 

> AFAIK, if you want to run knfsd in a container today, you're out of 
> luck for any non-trivial configuration.

Well "running knfsd in a container" is actually different from having a
containerised nfs export.  My understanding was that thanks to the work
of Stas Kinsbursky, the latter has mostly worked since the 3.9 kernel
for v3 and below.  I assume the current issue is that there's a problem
with v4?

James

>  The main reason is that most of knfsd is namespace-ized in the
> network namespace, but there is no clear way to associate that with a
> mount namespace, which is what we need to do this properly inside a
> container. I think David's patches would get us there.
>
> > >  (4) General request-key upcalls.  Not particularly namespace 
> > > dependent, apart from keyrings being somewhat governed by the 
> > > user namespace and the upcall being configured by the mount
> > > namespace.
> > 
> > All mount namespaces have an owning user namespace, so the data
> > relations are already there in the kernel, is the problem simply
> > finding them?
> > 
> > > These patches are built on top of the mount context patchset so 
> > > that namespaces can be properly propagated over
> > > submounts/automounts.
> > 
> > I'll stop here ... you get the idea that I think this is imposing a 
> > set of restrictions that will come back to bite us later.  If this 
> > is just for the sake of figuring out how to get keyring upcalls to 
> > work, then I'm sure we can come up with something.
> > 
> 

