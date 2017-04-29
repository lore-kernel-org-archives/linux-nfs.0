Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29663 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031531AbdD2Rxv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Apr 2017 13:53:51 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 0/5] Fun with the multipathing code
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1493402914.8238.2.camel@primarydata.com>
Date: Sat, 29 Apr 2017 13:53:43 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <24A9CAEC-DBF1-4BED-BAB4-A71F2014A385@oracle.com>
References: <20170428172535.7945-1-trond.myklebust@primarydata.com> <80AD321C-3774-49BF-B419-9D0D1067FA56@oracle.com> <1493402914.8238.2.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 28, 2017, at 2:08 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Fri, 2017-04-28 at 10:45 -0700, Chuck Lever wrote:
>>> On Apr 28, 2017, at 10:25 AM, Trond Myklebust <trond.myklebust@prim
>>> arydata.com> wrote:
>>> 
>>> In the spirit of experimentation, I've put together a set of
>>> patches
>>> that implement setting up multiple TCP connections to the server.
>>> The connections all go to the same server IP address, so do not
>>> provide support for multiple IP addresses (which I believe is
>>> something Andy Adamson is working on).
>>> 
>>> The feature is only enabled for NFSv4.1 and NFSv4.2 for now; I
>>> don't
>>> feel comfortable subjecting NFSv3/v4 replay caches to this
>>> treatment yet. It relies on the mount option "nconnect" to specify
>>> the number of connections to st up. So you can do something like
>>> 聽'mount -t nfs -overs=4.1,nconnect=8 foo:/bar /mnt'
>>> to set up 8 TCP connections to server 'foo'.
>> 
>> IMO this setting should eventually be set dynamically by the
>> client, or should be global (eg., a module parameter).
> 
> There is an argument for making it a per-server value (which is what
> this patchset does). It allows the admin a certain control to limit the
> number of connections to specific servers that are need to serve larger
> numbers of clients. However I'm open to counter arguments. I've no
> strong opinions yet.

Like direct I/O, this kind of setting could allow a single
client to DoS a server.

One additional concern might be how to deal with servers who
have no more ability to accept connections during certain
periods, but are able to support a lot of connections at
other times.


>> Since mount points to the same server share the same transport,
>> what happens if you specify a different "nconnect" setting on
>> two mount points to the same server?
> 
> Currently, the first one wins.
> 
>> What will the client do if there are not enough resources
>> (eg source ports) to create that many? Or is this an "up to N"
>> kind of setting? I can imagine a big client having to reduce
>> the number of connections to each server to help it scale in
>> number of server connections.
> 
> There is an arbitrary (compile time) limit of 16. The use of the
> SO_REUSEPORT socket option ensures that we should almost always be able
> to satisfy that number of source ports, since they can be shared with
> connections to other servers.

FWIW, Solaris limits this setting to 8. I think past that
value, there is only incremental and diminishing gain.
That could be apples to pears, though.

I'm not aware of a mount option, but there might be a
system tunable that controls this setting on each client.


>> Other storage protocols have a mechanism for determining how
>> transport connections are provisioned: One connection per
>> CPU core (or one CPU per NUMA node) on the client. This gives
>> a clear way to decide which connection to use for each RPC,
>> and guarantees the reply will arrive at the same compute
>> domain that sent the call.
> 
> Can we perhaps lay out a case for which mechanisms are useful as far as
> hardware is concerned? I understand the socket code is already
> affinitised to CPU caches, so that one's easy. I'm less familiar with
> the various features of the underlying offloaded NICs and how they tend
> to react when you add/subtract TCP connections.

Well, the optimal number of connections varies depending on
the NIC hardware design. I don't think there's a hard-and-fast
rule, but typically the server-class NICs have multiple DMA
engines and multiple cores. Thus they benefit from having
multiple sockets, up to a point.

Smaller clients would have a handful of cores, a single
memory hierarchy, and one NIC. I would guess optimizing for
the NIC (or server) would be best in that case. I'd bet
two connections would be a very good default.

For large clients, a connection per NUMA node makes sense.
This keeps the amount of cross-node memory traffic to a
minimum, which improves system scalability.

The issues with "socket per CPU core" are: there can be a lot
of cores, and it might be wasteful to open that many sockets
to each NFS server; and what do you do with a socket when
a CPU core is taken offline?


>> And of course: RPC-over-RDMA really loves this kind of feature
>> (multiple connections between same IP tuples) to spread the
>> workload over multiple QPs. There isn't anything special needed
>> for RDMA, I hope, but I'll have a look at the SUNRPC pieces.
> 
> I haven't yet enabled it for RPC/RDMA, but I imagine you can help out
> if you find it useful (as you appear to do).

I can give the patch set a try this week. I haven't seen any
thing that would exclude proto=rdma from playing in this
sandbox.


>> Thanks for posting, I'm looking forward to seeing this
>> capability in the Linux client.
>> 
>> 
>>> Anyhow, feel free to test and give me feedback as to whether or not
>>> this helps performance on your system.
>>> 
>>> Trond Myklebust (5):
>>> 聽SUNRPC: Allow creation of RPC clients with multiple connections
>>> 聽NFS: Add a mount option to specify number of TCP connections to
>>> use
>>> 聽NFSv4: Allow multiple connections to NFSv4.x (x>0) servers
>>> 聽pNFS: Allow multiple connections to the DS
>>> 聽NFS: Display the "nconnect" mount option if it is set.
>>> 
>>> fs/nfs/client.c聽聽聽聽聽聽聽聽聽聽聽聽聽|聽聽2 ++
>>> fs/nfs/internal.h聽聽聽聽聽聽聽聽聽聽聽|聽聽2 ++
>>> fs/nfs/nfs3client.c聽聽聽聽聽聽聽聽聽|聽聽3 +++
>>> fs/nfs/nfs4client.c聽聽聽聽聽聽聽聽聽| 13 +++++++++++--
>>> fs/nfs/super.c聽聽聽聽聽聽聽聽聽聽聽聽聽聽| 12 ++++++++++++
>>> include/linux/nfs_fs_sb.h聽聽聽|聽聽1 +
>>> include/linux/sunrpc/clnt.h |聽聽1 +
>>> net/sunrpc/clnt.c聽聽聽聽聽聽聽聽聽聽聽| 17 ++++++++++++++++-
>>> net/sunrpc/xprtmultipath.c聽聽|聽聽3 +--
>>> 9 files changed, 49 insertions(+), 5 deletions(-)
>>> 
>>> --聽
>>> 2.9.3
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at聽聽http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> Chuck Lever
>> 
>> 
>> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> �N嫥叉靣笡y氊b瞂千v豝�)藓{.n�+壏{睗�"炟^n噐■��侂h櫒璀�&Ⅷ�瓽珴閔��(殠娸"濟���m��飦赇z罐枈帼f＂穐殘坢

--
Chuck Lever



