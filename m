Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42860 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757822Ab1JEPCi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Oct 2011 11:02:38 -0400
Date: Wed, 5 Oct 2011 11:02:17 -0400
To: linux-nfs@vger.kernel.org
Cc: Pavel Emelyanov <xemul@openvz.org>, "Kirill A. Shutemov" <kas@openvz.org>,
        jlayton@redhat.com
Subject: network-namespace-aware nfsd
Message-ID: <20111005150214.GA18449@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a draft outline what we'd need to support containerized nfs
service; please tell me what I've got wrong.

The goal is to give the impression of running multiple virtual nfs
services, each with its own ip address or addresses.

A new nfs service will be started by forking off a new network
namespace, setting up interfaces there, and then starting nfs service
normally (including starting all the appropriate userland daemons, such
as rpc.mountd).

This requires no changes to existing userland code.  Instead, the kernel
side of each userland interface needs to be made aware of the network
namespace of the userland process it is talking to.

The kernel handles requests using a pool of threads, with the number of
threads controlled by writing to the "threads"  file in the "nfsd"
filesystem.  The files are also used to start the server (and to stop
it, by writing zero for the number of threads).

To conserve memory, I would prefer to have all of the virtual servers
share the same threads, rather than dedicating a separate set of threads
to each network namespace.  So:

Minimum functionality
---------------------

To get something minimal working, we need the rpc work that's in
progress.

In addition, we need the nfsd/threads interface to remember the value
set for each network namespace.  Writing to it will adjust the number of
threads, probably to the maximum value across all namespaces.

In addition, when the per-namespace value changes from zero to nonzero
or vice-versa, we need to trigger, respectively, starting or stopping
the per-namespace virtual server.  That means setting up or shutting
down sockets, and initializing or destroying any per-namespace state (as
required depending on NFS version, see below).

Also, nfsd/pool_threads probably needs similar treatment.

The nfsd/ports interface allows setting up listening sockets by hand.  I
suspect it needs at most trivial changes.

NFSv4
-----

To make NFSv4 work, we need per-network-namespace state that is
initialized and destroyed on startup and shutdown of a virtual nfs
server.  Each client therefore needs to be associated with a network
namespace, so it can be shut down at the right time, and so that we
consistently handle, for example, a broken NFSv4.0 client that sends the
same long-form identifier to servers with different IP addresses.

For 4.1 we have the option of sharing state between servers if we'd
like.  Initially simplest is to advertise the servers as entirely
distinct, without the ability to share any state.

The directory used for recovery data needs to be per-network-namespace.
If we replace it by something else, we'll need to make sure it's
namespace-aware.

NFSv2/v3
--------

For v2/v3 locking to work we also need per-network-namespace lockd and
statd state.

Note that there is a separate loopback interface per network namespace,
so the kernel can communicate separately with statd's in different
namespaces.  (statd communicates with the kernel over the loopback
interface).

krb5
----

Different servers likely want different kerberos identities.  To make
this work we need separate auth.rpcsec.context and auth.rpcsec.init
caches for each network namespace.

Independent export trees
------------------------

If we want to allow, for example, different filesystems to be exported
from different virtual servers, then we need per-namespace nfsd.export,
expkey, and auth.unix.ip caches.

Caches in general
-----------------

To containerize the /proc/net/rpc/* interfaces (as needed for the krb5
independent export trees), we need the content, channel, and flush files
to all be network-namespace-aware, so we want entirely separate caches
for each namespace.

I'm not sure whether that's best done by having lookups done in each
namespace get entirely different inodes, or whether the underlying
inodes should be shared and net/sunrpc/cache.c:cache_open() should
switch caches based on the network namespace of the opener.

Maybe some day
--------------

Not urgent, but possibly should be made namespace-aware some day:

	- leasetime, gracetime: per-netns ideal but not
	  required?  Probably more useful for gracetime.

	- unlock_ip: should be per-netns, maybe, low priority

	- unlock_fs: should be per-fsns, maybe, ignore for now.

	- nfs4.idtoname, nfs4.nametoid, could be per-netns, or would
	  they need to be per-uidns?

	- we could allow turning on nfs versions per-netns, but for now
	  that seems unnecessary.

	- maxblksize: ditto.  Keep it global, or take the maximum across
	  values given in each netns.

Should be non-issues:

	- export_features, supported_enctypes: global, nothing
	  to do.

	- filehandle: path->filehandle mapping should already be
	  per-fs, hopefully no changes required.

	- auth.unix.gid
		- keep global for now.
