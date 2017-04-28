Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27306 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2999309AbdD1Rpl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Apr 2017 13:45:41 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 0/5] Fun with the multipathing code
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170428172535.7945-1-trond.myklebust@primarydata.com>
Date: Fri, 28 Apr 2017 10:45:32 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <80AD321C-3774-49BF-B419-9D0D1067FA56@oracle.com>
References: <20170428172535.7945-1-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 28, 2017, at 10:25 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> In the spirit of experimentation, I've put together a set of patches
> that implement setting up multiple TCP connections to the server.
> The connections all go to the same server IP address, so do not
> provide support for multiple IP addresses (which I believe is
> something Andy Adamson is working on).
> 
> The feature is only enabled for NFSv4.1 and NFSv4.2 for now; I don't
> feel comfortable subjecting NFSv3/v4 replay caches to this
> treatment yet. It relies on the mount option "nconnect" to specify
> the number of connections to st up. So you can do something like
>  'mount -t nfs -overs=4.1,nconnect=8 foo:/bar /mnt'
> to set up 8 TCP connections to server 'foo'.

IMO this setting should eventually be set dynamically by the
client, or should be global (eg., a module parameter).

Since mount points to the same server share the same transport,
what happens if you specify a different "nconnect" setting on
two mount points to the same server?

What will the client do if there are not enough resources
(eg source ports) to create that many? Or is this an "up to N"
kind of setting? I can imagine a big client having to reduce
the number of connections to each server to help it scale in
number of server connections.

Other storage protocols have a mechanism for determining how
transport connections are provisioned: One connection per
CPU core (or one CPU per NUMA node) on the client. This gives
a clear way to decide which connection to use for each RPC,
and guarantees the reply will arrive at the same compute
domain that sent the call.

And of course: RPC-over-RDMA really loves this kind of feature
(multiple connections between same IP tuples) to spread the
workload over multiple QPs. There isn't anything special needed
for RDMA, I hope, but I'll have a look at the SUNRPC pieces.

Thanks for posting, I'm looking forward to seeing this
capability in the Linux client.


> Anyhow, feel free to test and give me feedback as to whether or not
> this helps performance on your system.
> 
> Trond Myklebust (5):
>  SUNRPC: Allow creation of RPC clients with multiple connections
>  NFS: Add a mount option to specify number of TCP connections to use
>  NFSv4: Allow multiple connections to NFSv4.x (x>0) servers
>  pNFS: Allow multiple connections to the DS
>  NFS: Display the "nconnect" mount option if it is set.
> 
> fs/nfs/client.c             |  2 ++
> fs/nfs/internal.h           |  2 ++
> fs/nfs/nfs3client.c         |  3 +++
> fs/nfs/nfs4client.c         | 13 +++++++++++--
> fs/nfs/super.c              | 12 ++++++++++++
> include/linux/nfs_fs_sb.h   |  1 +
> include/linux/sunrpc/clnt.h |  1 +
> net/sunrpc/clnt.c           | 17 ++++++++++++++++-
> net/sunrpc/xprtmultipath.c  |  3 +--
> 9 files changed, 49 insertions(+), 5 deletions(-)
> 
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



