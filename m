Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:34869 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934590AbdEVSez (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 14:34:55 -0400
Received: by mail-qt0-f176.google.com with SMTP id v27so109062370qtg.2
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 11:34:55 -0700 (PDT)
Message-ID: <1495478092.2816.17.camel@redhat.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: Jeff Layton <jlayton@redhat.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
        David Howells <dhowells@redhat.com>, trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com,
        Linux Containers <containers@lists.linux-foundation.org>
Date: Mon, 22 May 2017 14:34:52 -0400
In-Reply-To: <1495472039.2757.19.camel@HansenPartnership.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <1495472039.2757.19.camel@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-05-22 at 09:53 -0700, James Bottomley wrote:
> [Added missing cc to containers list]
> On Mon, 2017-05-22 at 17:22 +0100, David Howells wrote:
> > Here are a set of patches to define a container object for the kernel 
> > and to provide some methods to create and manipulate them.
> > 
> > The reason I think this is necessary is that the kernel has no idea 
> > how to direct upcalls to what userspace considers to be a container -
> > current Linux practice appears to make a "container" just an 
> > arbitrarily chosen junction of namespaces, control groups and files, 
> > which may be changed individually within the "container".
> 
> This sounds like a step in the wrong direction: the strength of the
> current container interfaces in Linux is that people who set up
> containers don't have to agree what they look like.  So I can set up a
> user namespace without a mount namespace or an architecture emulation
> container with only a mount namespace.
> 

Does this really mandate what they look like though? AFAICT, you can
still spawn disconnected namespaces to your heart's content. What this
does is provide a container for several different namespaces so that the
kernel can actually be aware of the association between them. The way
you populate the different namespaces looks to be pretty flexible.

> But ignoring my fun foibles with containers and to give a concrete
> example in terms of a popular orchestration system: in kubernetes,
> where certain namespaces are shared across pods, do you imagine the
> kernel's view of the "container" to be the pod or what kubernetes
> thinks of as the container?  This is important, because half the
> examples you give below are network related and usually pods share a
> network namespace.
> 
> > The kernel upcall mechanism then needs to decide which set of 
> > namespaces, etc., it must exec the appropriate upcall program. 
> >  Examples of this include:
> > 
> >  (1) The DNS resolver.  The DNS cache in the kernel should probably 
> > be per-network namespace, but in userspace the program, its
> > libraries and its config data are associated with a mount tree and a 
> > user namespace and it gets run in a particular pid namespace.
> 
> All persistent (written to fs data) has to be mount ns associated;
> there are no ifs, ands and buts to that.  I agree this implies that if
> you want to run a separate network namespace, you either take DNS from
> the parent (a lot of containers do) or you set up a daemon to run
> within the mount namespace.  I agree the latter is a slightly fiddly
> operation you have to get right, but that's why we have orchestration
> systems.
> 
> What is it we could do with the above that we cannot do today?
> 

Spawn a task directly from the kernel, already set up in the correct
namespaces, a'la call_usermodehelper. So far there is no way to do that,
and it is something we'd very much desire. Ian Kent has made several
passes at it recently.

> >  (2) NFS ID mapper.  The NFS ID mapping cache should also probably be
> >      per-network namespace.
> 
> I think this is a view but not the only one:  Right at the moment, NFS
> ID mapping is used as the one of the ways we can get the user namespace
> ID mapping writes to file problems fixed ... that makes it a property
> of the mount namespace for a lot of containers.  There are many other
> instances where they do exactly as you say, but what I'm saying is that
> we don't want to lose the flexibility we currently have.
> 
> >  (3) nfsdcltrack.  A way for NFSD to access stable storage for 
> > tracking of persistent state.  Again, network-namespace dependent, 
> > but also perhaps mount-namespace dependent.

Definitely mount-namespace dependent.

> 
> So again, given we can set this up to work today, this sounds like more
> a restriction that will bite us than an enhancement that gives us extra
> features.
> 

How do you set this up to work today?

AFAIK, if you want to run knfsd in a container today, you're out of luck
for any non-trivial configuration. The main reason is that most of knfsd
is namespace-ized in the network namespace, but there is no clear way to
associate that with a mount namespace, which is what we need to do this
properly inside a container. I think David's patches would get us there.

> >  (4) General request-key upcalls.  Not particularly namespace 
> > dependent, apart from keyrings being somewhat governed by the user
> > namespace and the upcall being configured by the mount namespace.
> 
> All mount namespaces have an owning user namespace, so the data
> relations are already there in the kernel, is the problem simply
> finding them?
> 
> > These patches are built on top of the mount context patchset so that
> > namespaces can be properly propagated over submounts/automounts.
> 
> I'll stop here ... you get the idea that I think this is imposing a set
> of restrictions that will come back to bite us later.  If this is just
> for the sake of figuring out how to get keyring upcalls to work, then
> I'm sure we can come up with something.
> 

-- 
Jeff Layton <jlayton@redhat.com>
