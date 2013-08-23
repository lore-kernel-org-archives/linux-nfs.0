Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754983Ab3HWOBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Aug 2013 10:01:52 -0400
Subject: Re: [PATCH Version 5 0/3] Use the MDS nfs_server authflavor for
 pNFS data server connections
From: Simo Sorce <simo@redhat.com>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
In-Reply-To: <1376430469-3773-1-git-send-email-andros@netapp.com>
References: <1376430469-3773-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Aug 2013 10:01:49 -0400
Message-ID: <1377266509.2814.318.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-08-13 at 17:47 -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Differences from Version 4
> - added NFSv4 Remove unused LIPKEY and SPKM enums
> - shared GSS context caches when possible via shared rpc_clnt structs

If you share the gss context don't you risk mixing up sequence numbers
and sending out of sequence packets ?
Is that posible ? Is that going to be a problem with any
implementation ?

I do not see GSS_C_SEQUENCE_FLAG used in nfs-utils, nor do I see any
check for sequence in the unwrap call in the kernel so probably not a
problem (at least for linux-to-linux), but just thought about asking to
make sure anyway.

Simo.

> - DS conections use the shared rpc_clnts
> 
> Andy Adamson (3):
>   NFSv4 Remove unused LIPKEY and SPKM enums
>   NFS Share RPC_AUTH_GSS rpc clients
>   NFSv4.1 Use the shared nfs_client rpc_clnts for pNFS data server
>     connections
> 
>  fs/nfs/client.c                 | 80 ++++++++++++++++++++++++++++++++++++++---
>  fs/nfs/internal.h               |  4 +++
>  fs/nfs/nfs4filelayout.c         | 69 +++++++++++++++++++++++++++++------
>  fs/nfs/nfs4filelayout.h         |  3 ++
>  fs/nfs/nfs4filelayoutdev.c      |  4 ++-
>  fs/nfs/nfs4namespace.c          |  5 +--
>  fs/nfs/nfs4proc.c               |  9 +++--
>  fs/nfs/nfs4state.c              |  4 +--
>  fs/nfs/super.c                  | 34 ------------------
>  include/linux/nfs_fs_sb.h       |  1 +
>  include/linux/sunrpc/msg_prot.h |  9 ++---
>  11 files changed, 158 insertions(+), 64 deletions(-)
> 


-- 
Simo Sorce * Red Hat, Inc * New York

