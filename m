Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:41416 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1762701AbdEWPCg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 11:02:36 -0400
Message-ID: <1495551751.10876.17.camel@HansenPartnership.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        trondmy@primarydata.com, ebiederm@xmission.com
Date: Tue, 23 May 2017 08:02:31 -0700
In-Reply-To: <32556.1495547529@warthog.procyon.org.uk>
References: <1495472039.2757.19.camel@HansenPartnership.com>
         <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <32556.1495547529@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-05-23 at 14:52 +0100, David Howells wrote:
> James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> 
> > This sounds like a step in the wrong direction: the strength of the
> > current container interfaces in Linux is that people who set up
> > containers don't have to agree what they look like.
> 
> It may be a strength, but it is also a problem.
> 
> > So I can set up a user namespace without a mount namespace or an
> > architecture emulation container with only a mount namespace.
> 
> (I presume you mean with only the mount namespace separate)
> 
> Yep.  You can do that with this too.
> 
> > But ignoring my fun foibles with containers and to give a concrete
> > example in terms of a popular orchestration system: in kubernetes,
> > where certain namespaces are shared across pods, do you imagine the
> > kernel's view of the "container" to be the pod or what kubernetes
> > thinks of as the container?
> 
> Why not both?  If the net_ns is created in the pod container, then
> probably
> network-related upcalls should be directed there.  Unless instructed
> otherwise, upon creation a container object will inherit the caller's
> namespaces.

The pod isn't a container, it's a collection of containers.  Lets say
each container has a separate mount namespace but shares a network
namespace (this is a gross simplification, there are many other ways
you can set up a pod, but this one illustrates the point).  For your
upcall you'd have to pick a kubernetes container and you don't have the
information to do that, even with your current patches, because what
kubernetes has done.  This is where your view of "container" doesn't
match the kubernetes view.

> > This is important, because half the examples you give below are 
> > network related and usually pods share a network namespace.
> 
> Yeah - I'm more familiar with upcalls made by NFS, AFS and keyrings.

OK, so rather than getting into the technical back and forth below can
we agree that the kernel can't have a unitary view of "container"
because the current use cases (the orchestration systems) don't have
one?  Then the next step becomes how can we add an abstraction that
gives you what you want (as far as I can tell basically identifying a
set of namespaces for an upcall) in a way that doesn't bind the kernel
to have a unitary view of a container? And then we can tack the ideas
on to the Jeff/Eric subthread.

James

