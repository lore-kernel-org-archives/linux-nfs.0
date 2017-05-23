Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38179 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751656AbdEWKKB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 06:10:01 -0400
Message-ID: <1495534193.2564.3.camel@themaw.net>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: Ian Kent <raven@themaw.net>
To: David Howells <dhowells@redhat.com>, trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com
Date: Tue, 23 May 2017 18:09:53 +0800
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-05-22 at 17:22 +0100, David Howells wrote:
> Here are a set of patches to define a container object for the kernel and
> to provide some methods to create and manipulate them.
> 
> The reason I think this is necessary is that the kernel has no idea how to
> direct upcalls to what userspace considers to be a container - current
> Linux practice appears to make a "container" just an arbitrarily chosen
> junction of namespaces, control groups and files, which may be changed
> individually within the "container".
> 
> The kernel upcall mechanism then needs to decide which set of namespaces,
> etc., it must exec the appropriate upcall program.  Examples of this
> include:
> 
>  (1) The DNS resolver.  The DNS cache in the kernel should probably be
>      per-network namespace, but in userspace the program, its libraries and
>      its config data are associated with a mount tree and a user namespace
>      and it gets run in a particular pid namespace.
> 
>  (2) NFS ID mapper.  The NFS ID mapping cache should also probably be
>      per-network namespace.
> 
>  (3) nfsdcltrack.  A way for NFSD to access stable storage for tracking
>      of persistent state.  Again, network-namespace dependent, but also
>      perhaps mount-namespace dependent.
> 
>  (4) General request-key upcalls.  Not particularly namespace dependent,
>      apart from keyrings being somewhat governed by the user namespace and
>      the upcall being configured by the mount namespace.
> 
> These patches are built on top of the mount context patchset so that
> namespaces can be properly propagated over submounts/automounts.
> 
> These patches implement a container object that holds the following things:
> 
>  (1) Namespaces.
> 
>  (2) A root directory.
> 
>  (3) A set of processes, including a designated 'init' process.
> 
>  (4) The creator's credentials, including ownership.
> 
>  (5) A place to hang security for the container, allowing policies to be
>      set per-container.
> 
> I also want to add:
> 
>  (6) Control groups.
> 
>  (7) A per-container keyring that can be added to from outside of the
>      container, even once the container is live, for the provision of
>      filesystem authentication/encryption keys in advance of the container
>      being started.

It's hard to decide which of these has higher priority, I think both essential
to a container implementation.

Ian
