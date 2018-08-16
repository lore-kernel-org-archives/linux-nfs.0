Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56131 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726342AbeHPICH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 04:02:07 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: David Howells <dhowells@redhat.com>
Cc: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        sfrench@samba.org, steved@redhat.com, viro@zeniv.linux.org.uk,
        torvalds@linux-foundation.org,
        "Eric W. Biederman" <ebiederm@redhat.com>,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net
References: <153313703562.13253.5766498657900728120.stgit@warthog.procyon.org.uk>
        <17763.1534350685@warthog.procyon.org.uk>
Date: Thu, 16 Aug 2018 00:06:06 -0500
In-Reply-To: <17763.1534350685@warthog.procyon.org.uk> (David Howells's
        message of "Wed, 15 Aug 2018 17:31:25 +0100")
Message-ID: <87pnyiew8x.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: Should we split the network filesystem setup into two phases?
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:

> Having just re-ported NFS on top of the new mount API stuff, I find that I
> don't really like the idea of superblocks being separated by communication
> parameters - especially when it might seem reasonable to be able to adjust
> those parameters.
>
> Does it make sense to abstract out the remote peer and allow (a) that to be
> configured separately from any superblocks using it and (b) that to be used to
> create superblocks?
>
> Note that what a 'remote peer' is would be different for different
> filesystems:
>
>  (*) For NFS, it would probably be a named server, with address(es) attached
>      to the name.  In lieu of actually having a name, the initial IP address
>      could be used.
>
>  (*) For CIFS, it would probably be a named server.  I'm not sure if CIFS
>      allows an abstraction for a share that can move about inside a domain.
>
>  (*) For AFS, it would be a cell, I think, where the actual fileserver(s) used
>      are a matter of direction from the Volume Location server.
>
>  (*) For 9P and Ceph, I don't really know.
>
> What could be configured?  Well, addresses, ports, timeouts.  Maybe protocol
> level negotiation - though not being able to explicitly specify, say, the
> particular version and minorversion on an NFS share would be problematic for
> backward compatibility.
>
> One advantage it could give us is that it might make it easier if someone asks
> for server X to query userspace in some way for the default parameters for X
> are.
>
> What might this look like in terms of userspace?  Well, we could overload the
> new mount API:
>
> 	peer1 = fsopen("nfs", FSOPEN_CREATE_PEER);
> 	fsconfig(peer1, FSCONFIG_SET_NS, "net", NULL, netns_fd);
> 	fsconfig(peer1, FSCONFIG_SET_STRING, "peer_name", "server.home");
> 	fsconfig(peer1, FSCONFIG_SET_STRING, "vers", "4.2");
> 	fsconfig(peer1, FSCONFIG_SET_STRING, "address", "tcp:192.168.1.1");
> 	fsconfig(peer1, FSCONFIG_SET_STRING, "address", "tcp:192.168.1.2");
> 	fsconfig(peer1, FSCONFIG_SET_STRING, "timeo", "122");
> 	fsconfig(peer1, FSCONFIG_CMD_SET_UP_PEER, NULL, NULL, 0);
>
> 	peer2 = fsopen("nfs", FSOPEN_CREATE_PEER);
> 	fsconfig(peer2, FSCONFIG_SET_NS, "net", NULL, netns_fd);
> 	fsconfig(peer2, FSCONFIG_SET_STRING, "peer_name", "server2.home");
> 	fsconfig(peer2, FSCONFIG_SET_STRING, "vers", "3");
> 	fsconfig(peer2, FSCONFIG_SET_STRING, "address", "tcp:192.168.1.3");
> 	fsconfig(peer2, FSCONFIG_SET_STRING, "address", "udp:192.168.1.4+6001");
> 	fsconfig(peer2, FSCONFIG_CMD_SET_UP_PEER, NULL, NULL, 0);
>
> 	fs = fsopen("nfs", 0);
> 	fsconfig(fs, FSCONFIG_SET_PEER, "peer.1", NULL, peer1);
> 	fsconfig(fs, FSCONFIG_SET_PEER, "peer.2", NULL, peer2);
> 	fsconfig(fs, FSCONFIG_SET_STRING, "source", "/home/dhowells", 0);
> 	m = fsmount(fs, 0, 0);
>
> [Note that Eric's oft-repeated point about the 'creation' operation altering
>  established parameters still stands here.]
>
> You could also then reopen it for configuration, maybe by:
>
> 	peer = fspick(AT_FDCWD, "/mnt", FSPICK_PEER);
>
> or:
>
> 	peer = fspick(AT_FDCWD, "nfs:server.home", FSPICK_PEER_BY_NAME);
>
> though it might be better to give it its own syscall:
>
> 	peer = fspeer("nfs", "server.home", O_CLOEXEC);
> 	fsconfig(peer, FSCONFIG_SET_NS, "net", NULL, netns_fd);
> 	...
> 	fsconfig(peer, FSCONFIG_CMD_SET_UP_PEER, NULL, NULL, 0);
>
> In terms of alternative interfaces, I'm not sure how easy it would be to make
> it like cgroups where you go and create a dir in a special filesystem, say,
> "/sys/peers/nfs", because the peers records and names would have to be network
> namespaced.  Also, it might make it more difficult to use to create a root fs.
>
> On the other hand, being able to adjust the peer configuration by:
>
> 	echo 71 >/sys/peers/nfs/server.home/timeo
>
> does have a certain appeal.
>
> Also, netlink might be the right option, but I'm not sure how you'd pin the
> resultant object whilst you make use of it.
>
> A further thought is that is it worth making this idea more general and
> encompassing non-network devices also?  This would run into issues of some
> logical sources being visible across namespaces and but not others.

Even network filesystems are going to have challenges of filesystems
being visible in some network namespaces and not others.  As some
filesystems will be visible on the internet and some filesystems will
only be visible on the appropriate local network.  Network namespaces
are sometimes used to deal with the case of local networks with
overlapping ip addresses.

I think you are proposing a model for network filesystems that is
essentially the same situation where we are with most block devices
filesystems today.  Where some parameters identitify the local
filesystem instance and some parameters identify how the kernel
interacts with that filesystem instance.


For system efficiency there is a strong argument for having the fewest
number of filesystem instances we can.  Otherwise we will be caching the
same data twice and wasting space in RAM etc.


So I like the idea.


At least for devpts we always create a new filesystem instance every
time mount(2) is called.  NFS seems to have the option to create a new
filesystem instance every time mount(2) is called as well, (even if the
filesystem parameters are the same).  And depending on the case I can
see the attraction for other filesystems as well.

So I don't think we can completely abandon the option for filesystems
to always create a new filesystem instance when mount(8) is called.



I most definitely support thinking this through and figuring out how it
best make sense for the new filesystem API to create new filesystem
instances or fail to create new filesystems instances.


Eric
