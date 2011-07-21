Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33776 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab1GUQqI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 12:46:08 -0400
Message-ID: <4E2857CA.7000905@candelatech.com>
Date: Thu, 21 Jul 2011 09:46:02 -0700
From: Ben Greear <greearb@candelatech.com>
To: greearb@candelatech.com
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH (RESEND) 00/12] Support binding nfs/rpc to local IP address.
References: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
In-Reply-To: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/15/2011 10:55 AM, greearb@candelatech.com wrote:
> From: Ben Greear<greearb@candelatech.com>
>
>
> This patch series allows binding the nfs and rpc logic to a specific local
> IP address.

Any comments on this?  I'd love to get these merged in time for 3.1!

With recent 3.0 RCU fixes, my stress test runs clean over-night, so
it has been pretty well tested....

Thanks,
Ben

>
> Features/Benefits:
>
> *  Allow multiple unique mounts to the same server using unique
>     source IP addresses on client system.
>
>     Routing rules can then be created based on the source IP address for
>     advanced routing of the NFS traffic.
>
>     This could allow someone to use two 1G interfaces to access a
>     server with 10G connectivity and allow aggregate 2Gbps transfer,
>     for instance.
>
>     This is also useful for load testing NFS servers as well as the
>     client-side NFS logic (note the bugs&  fixed found while testing
>     this code!)
>
> *  Allow using a specific IP address on multi-homed system.  This could
>     increase security in some cases and in general gives the user more
>     control over how the services are configured.
>
> This code has been tested under load on 3.0 and a similar version has
> been tested under load on 2.6.38 and previous kernels.
>
> Full implementation of this feature requires patches to mount.nfs,
> which have been agreed to be accepted if the kernel patches are accepted.
>
> Ben Greear (12):
>    sunrpc:  Don't attempt to bind to AF_UNSPEC address.
>    nfs:  Two AF_UNSPEC addresses should always match each other.
>    nfs:  Add srcaddr member to nfs_client.
>    nfs:  Use request destination addr as callback source addr.
>    nfs:  Pay attention to srcaddr in v4.1 callback logic.
>    nfs:  Use srcaddr in nfs_match_client.
>    nfs:  Add srcaddr to /proc/fs/nfsfs/servers
>    nfs:  Pass srcaddr into mount request.
>    nfs:  Propagate src-addr in client code.
>    nfs: Bind to srcaddr in rpcb_create.
>    nfs: Support srcaddr= to bind to specific IP address.
>    lockd: Support binding nlm client to specific address.
>
>   fs/lockd/clntlock.c         |    3 +-
>   fs/lockd/host.c             |   17 +++++++++-
>   fs/nfs/callback.h           |    3 ++
>   fs/nfs/callback_proc.c      |    3 +-
>   fs/nfs/callback_xdr.c       |    3 ++
>   fs/nfs/client.c             |   73 ++++++++++++++++++++++++++++++++++++++++--
>   fs/nfs/internal.h           |   10 +++++-
>   fs/nfs/mount_clnt.c         |    1 +
>   fs/nfs/super.c              |   33 +++++++++++++++++++-
>   include/linux/lockd/bind.h  |    1 +
>   include/linux/lockd/lockd.h |    1 +
>   include/linux/nfs_fs_sb.h   |    4 ++
>   include/linux/sunrpc/clnt.h |    2 +
>   include/linux/sunrpc/svc.h  |    5 +++
>   net/sunrpc/rpcb_clnt.c      |   28 +++++++++++++++-
>   net/sunrpc/sunrpc.h         |   45 ++++++++++++++++++++++++++
>   net/sunrpc/xprtsock.c       |   47 +--------------------------
>   17 files changed, 223 insertions(+), 56 deletions(-)
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

