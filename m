Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47322 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934524AbdCXO7I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Mar 2017 10:59:08 -0400
Date: Fri, 24 Mar 2017 10:59:07 -0400
To: linux-nfs@vger.kernel.org
Subject: notes on VAULT 2017 NFS BOF
Message-ID: <20170324145907.GC2722@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson lead a quick NFS meeting Wednesday night at Boston during
vault.  I thought it might be worth posting my notes:

Flex file server: it's just there for testing.  If someone wants to
build on it, they can.  It has no practical use, and should be
configured out of distro kernels to avoid confusing users.

NFSv4-only server: some users want to minimize open ports, so we should
support this configuration.  But distros probably shouldn't be
NFSv4-only by default.  (And: a show of hands at Steve & Chuck's talk
the next day confirmed that people still depend on NFSv3.)

What about turning off UDP?  This looks more doable.  Note client still
needs to listen for lockd UDP.  But we can keep that while turning off
nfsd UDP.  (Kernel lockd is currently hard-coded to listen on both UDP
and TCP regardless of server configuration.)

Should the client by default try NFSv4.2 first?  Consensus seems to be
yes.  When 4.2 fails, it tries 4.1, then 4.0, etc.  It works
transparently.  Steved was worried that those retries might become a
problem on clients with lots of NFS mounts.  Trond suggested recording
the result of the version negotiation across mounts, so a client doing a
lot of mounts to the same server would only need the retries on the
first mount.

The retries are driven by userspace which does a mount for a specific
version and uses the return from the mount call to decide to negotiate
down.  So a new TCP connection happens for each mount attempt.

Miklos introduced a proposed new mount api at LSF earlier in the week.
It would allow some communication with the file system driver to set up
parameters before the system call that creates the mountpoint.  If we
moved the mount negotiation to that setup phase, that might make the
negotiation phase more efficient while still leaving userspace in
charge.  (And we prefer leaving userspace in charge to give it maximum
control over negotiation policy.)

Somebody asked about inotify implementation.  Currently inotify only
reports changes made on the same client.  There is unimplemented
protocol in RFC 5661 that would allow the client to get notifications of
other changes from the server.  Trond says it would be difficult and
risks flooding the network with notifications, though the protocol does
have some provision for batching them.

There were questions about NFS's uses of RDMA writes which I didn't
follow, and my notes stopped there.

--b.
