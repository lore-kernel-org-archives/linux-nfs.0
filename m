Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:34515 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760606AbdEVR2P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 13:28:15 -0400
Received: by mail-wr0-f178.google.com with SMTP id l9so42788994wre.1
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 10:28:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1495472039.2757.19.camel@HansenPartnership.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
 <1495472039.2757.19.camel@HansenPartnership.com>
From: Jessica Frazelle <me@jessfraz.com>
Date: Mon, 22 May 2017 18:27:53 +0100
Message-ID: <CAEk6tEzou62YU205fnumaO8m5Hpg24Nt3yCKdNU1FD0wavdA1w@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: David Howells <dhowells@redhat.com>, trondmy@primarydata.com,
        mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com,
        Linux Containers <containers@lists.linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I had replied but not to the thread with the containers mailing list.
See https://marc.info/?l=linux-cgroups&m=149547317006676&w=2

On Mon, May 22, 2017 at 5:53 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> [Added missing cc to containers list]
> On Mon, 2017-05-22 at 17:22 +0100, David Howells wrote:
>> Here are a set of patches to define a container object for the kernel
>> and to provide some methods to create and manipulate them.
>>
>> The reason I think this is necessary is that the kernel has no idea
>> how to direct upcalls to what userspace considers to be a container -
>> current Linux practice appears to make a "container" just an
>> arbitrarily chosen junction of namespaces, control groups and files,
>> which may be changed individually within the "container".
>
> This sounds like a step in the wrong direction: the strength of the
> current container interfaces in Linux is that people who set up
> containers don't have to agree what they look like.  So I can set up a
> user namespace without a mount namespace or an architecture emulation
> container with only a mount namespace.
>
> But ignoring my fun foibles with containers and to give a concrete
> example in terms of a popular orchestration system: in kubernetes,
> where certain namespaces are shared across pods, do you imagine the
> kernel's view of the "container" to be the pod or what kubernetes
> thinks of as the container?  This is important, because half the
> examples you give below are network related and usually pods share a
> network namespace.

I am glad you pointed this out because I was trying to make the same
point, various definitions of containers differ and who is to say
whether the various container runtimes (runc, rkt, systemd-nspawn) or
consumers of containers (kubernetes) won't modify their definition in
the future. How will this scale as new LSMs like Landlock or new
namespaces are added in the future will they be included in the
container kernel object as well...

Seems like a lot more maintenance for something that is really just
making the keyring namespace-aware... unless there are other things I
missed.

>
>> The kernel upcall mechanism then needs to decide which set of
>> namespaces, etc., it must exec the appropriate upcall program.
>>  Examples of this include:
>>
>>  (1) The DNS resolver.  The DNS cache in the kernel should probably
>> be per-network namespace, but in userspace the program, its
>> libraries and its config data are associated with a mount tree and a
>> user namespace and it gets run in a particular pid namespace.
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
>>  (2) NFS ID mapper.  The NFS ID mapping cache should also probably be
>>      per-network namespace.
>
> I think this is a view but not the only one:  Right at the moment, NFS
> ID mapping is used as the one of the ways we can get the user namespace
> ID mapping writes to file problems fixed ... that makes it a property
> of the mount namespace for a lot of containers.  There are many other
> instances where they do exactly as you say, but what I'm saying is that
> we don't want to lose the flexibility we currently have.
>
>>  (3) nfsdcltrack.  A way for NFSD to access stable storage for
>> tracking of persistent state.  Again, network-namespace dependent,
>> but also perhaps mount-namespace dependent.
>
> So again, given we can set this up to work today, this sounds like more
> a restriction that will bite us than an enhancement that gives us extra
> features.
>
>>  (4) General request-key upcalls.  Not particularly namespace
>> dependent, apart from keyrings being somewhat governed by the user
>> namespace and the upcall being configured by the mount namespace.
>
> All mount namespaces have an owning user namespace, so the data
> relations are already there in the kernel, is the problem simply
> finding them?
>
>> These patches are built on top of the mount context patchset so that
>> namespaces can be properly propagated over submounts/automounts.
>
> I'll stop here ... you get the idea that I think this is imposing a set
> of restrictions that will come back to bite us later.  If this is just
> for the sake of figuring out how to get keyring upcalls to work, then
> I'm sure we can come up with something.
>
> James
>
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 


Jessie Frazelle
4096R / D4C4 DD60 0D66 F65A 8EFC  511E 18F3 685C 0022 BFF3
pgp.mit.edu
