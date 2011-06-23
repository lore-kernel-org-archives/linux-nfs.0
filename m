Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:49274 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264Ab1FWO7c convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 10:59:32 -0400
Subject: Re: [PATCH 00/11] NFS: Support binding to source address
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1308778611-9370-1-git-send-email-greearb@candelatech.com>
Date: Thu, 23 Jun 2011 08:59:23 -0600
Cc: linux-nfs@vger.kernel.org
Message-Id: <F37E8424-9A40-4C4F-A2F6-431FDA831E0D@oracle.com>
References: <1308778611-9370-1-git-send-email-greearb@candelatech.com>
To: greearb@candelatech.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 22, 2011, at 3:36 PM, greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> This lets one specify the source IP address for
> sockets, allowing users to leverage routing rules
> on multi-homed systems.

Do you need changes to send NLM requests from the right source address?

> Patches are also needed to nfs-utils.  These have been
> posted and will be accepted if the kernel support is
> accepted.
> 
> Ben Greear (11):
>  sunrpc:  Don't attempt to bind to AF_UNSPEC address.
>  nfs:  Two AF_UNSPEC addresses should always match each other.
>  nfs:  Add srcaddr member to nfs_client.
>  nfs:  Use request destination addr as callback source addr.
>  nfs:  Pay attention to srcaddr in v4.1 callback logic.
>  nfs:  Use srcaddr in nfs_match_client.
>  nfs:  Add srcaddr to /proc/fs/nfsfs/servers
>  nfs:  Pass srcaddr into mount request.
>  nfs:  Propagate src-addr in client code.
>  nfs: Bind to srcaddr in rpcb_create.
>  nfs: Support srcaddr= to bind to specific IP address.
> 
> fs/nfs/callback.h          |    3 ++
> fs/nfs/callback_proc.c     |    3 +-
> fs/nfs/callback_xdr.c      |    3 ++
> fs/nfs/client.c            |   72 +++++++++++++++++++++++++++++++++++++++++--
> fs/nfs/internal.h          |   10 +++++-
> fs/nfs/mount_clnt.c        |    1 +
> fs/nfs/super.c             |   33 +++++++++++++++++++-
> include/linux/nfs_fs_sb.h  |    4 ++
> include/linux/sunrpc/svc.h |    5 +++
> net/sunrpc/rpcb_clnt.c     |   28 ++++++++++++++++-
> net/sunrpc/sunrpc.h        |   45 +++++++++++++++++++++++++++
> net/sunrpc/xprtsock.c      |   47 +---------------------------
> 12 files changed, 200 insertions(+), 54 deletions(-)
> 
> -- 
> 1.7.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



