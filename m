Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:57528 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729348AbeHOTYW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Aug 2018 15:24:22 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <153313703562.13253.5766498657900728120.stgit@warthog.procyon.org.uk>
References: <153313703562.13253.5766498657900728120.stgit@warthog.procyon.org.uk>
To: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        sfrench@samba.org, steved@redhat.com, viro@zeniv.linux.org.uk
Cc: dhowells@redhat.com, torvalds@linux-foundation.org,
        "Eric W. Biederman" <ebiederm@redhat.com>,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net
Subject: Should we split the network filesystem setup into two phases?
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 15 Aug 2018 17:31:25 +0100
Message-ID: <17763.1534350685@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Having just re-ported NFS on top of the new mount API stuff, I find that I
don't really like the idea of superblocks being separated by communication
parameters - especially when it might seem reasonable to be able to adjust
those parameters.

Does it make sense to abstract out the remote peer and allow (a) that to be
configured separately from any superblocks using it and (b) that to be used to
create superblocks?

Note that what a 'remote peer' is would be different for different
filesystems:

 (*) For NFS, it would probably be a named server, with address(es) attached
     to the name.  In lieu of actually having a name, the initial IP address
     could be used.

 (*) For CIFS, it would probably be a named server.  I'm not sure if CIFS
     allows an abstraction for a share that can move about inside a domain.

 (*) For AFS, it would be a cell, I think, where the actual fileserver(s) used
     are a matter of direction from the Volume Location server.

 (*) For 9P and Ceph, I don't really know.

What could be configured?  Well, addresses, ports, timeouts.  Maybe protocol
level negotiation - though not being able to explicitly specify, say, the
particular version and minorversion on an NFS share would be problematic for
backward compatibility.

One advantage it could give us is that it might make it easier if someone asks
for server X to query userspace in some way for the default parameters for X
are.

What might this look like in terms of userspace?  Well, we could overload the
new mount API:

	peer1 = fsopen("nfs", FSOPEN_CREATE_PEER);
	fsconfig(peer1, FSCONFIG_SET_NS, "net", NULL, netns_fd);
	fsconfig(peer1, FSCONFIG_SET_STRING, "peer_name", "server.home");
	fsconfig(peer1, FSCONFIG_SET_STRING, "vers", "4.2");
	fsconfig(peer1, FSCONFIG_SET_STRING, "address", "tcp:192.168.1.1");
	fsconfig(peer1, FSCONFIG_SET_STRING, "address", "tcp:192.168.1.2");
	fsconfig(peer1, FSCONFIG_SET_STRING, "timeo", "122");
	fsconfig(peer1, FSCONFIG_CMD_SET_UP_PEER, NULL, NULL, 0);

	peer2 = fsopen("nfs", FSOPEN_CREATE_PEER);
	fsconfig(peer2, FSCONFIG_SET_NS, "net", NULL, netns_fd);
	fsconfig(peer2, FSCONFIG_SET_STRING, "peer_name", "server2.home");
	fsconfig(peer2, FSCONFIG_SET_STRING, "vers", "3");
	fsconfig(peer2, FSCONFIG_SET_STRING, "address", "tcp:192.168.1.3");
	fsconfig(peer2, FSCONFIG_SET_STRING, "address", "udp:192.168.1.4+6001");
	fsconfig(peer2, FSCONFIG_CMD_SET_UP_PEER, NULL, NULL, 0);

	fs = fsopen("nfs", 0);
	fsconfig(fs, FSCONFIG_SET_PEER, "peer.1", NULL, peer1);
	fsconfig(fs, FSCONFIG_SET_PEER, "peer.2", NULL, peer2);
	fsconfig(fs, FSCONFIG_SET_STRING, "source", "/home/dhowells", 0);
	m = fsmount(fs, 0, 0);

[Note that Eric's oft-repeated point about the 'creation' operation altering
 established parameters still stands here.]

You could also then reopen it for configuration, maybe by:

	peer = fspick(AT_FDCWD, "/mnt", FSPICK_PEER);

or:

	peer = fspick(AT_FDCWD, "nfs:server.home", FSPICK_PEER_BY_NAME);

though it might be better to give it its own syscall:

	peer = fspeer("nfs", "server.home", O_CLOEXEC);
	fsconfig(peer, FSCONFIG_SET_NS, "net", NULL, netns_fd);
	...
	fsconfig(peer, FSCONFIG_CMD_SET_UP_PEER, NULL, NULL, 0);

In terms of alternative interfaces, I'm not sure how easy it would be to make
it like cgroups where you go and create a dir in a special filesystem, say,
"/sys/peers/nfs", because the peers records and names would have to be network
namespaced.  Also, it might make it more difficult to use to create a root fs.

On the other hand, being able to adjust the peer configuration by:

	echo 71 >/sys/peers/nfs/server.home/timeo

does have a certain appeal.

Also, netlink might be the right option, but I'm not sure how you'd pin the
resultant object whilst you make use of it.

A further thought is that is it worth making this idea more general and
encompassing non-network devices also?  This would run into issues of some
logical sources being visible across namespaces and but not others.

David
