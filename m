From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/24] Modernize NFSv2 XDR encoder/decoders
Date: Mon, 17 May 2010 16:57:14 -0400
Message-ID: <4BF1ADAA.8030908@oracle.com>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:48101 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656Ab0EQU6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 16:58:51 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id o4HKwlZO026581
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 17 May 2010 20:58:49 GMT
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by acsinet15.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id o4HKdoho016284
	for <linux-nfs@vger.kernel.org>; Mon, 17 May 2010 20:58:46 GMT
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note: I now have some minor clean ups for this series.  I can post again 
after a few days, after any review comments.

On 05/16/10 10:45 PM, Chuck Lever wrote:
> This series backports patches I did 3 years ago that update the NFS
> client's NFSv2 XDR encoders and decoders to use xdr_stream style
> marshalling, similar to NFSv4.  The immediate advantage is better
> bounds checking during marshalling and unmarshalling.
>
> I've already done the kernel's MNT client, lockd's NSM client, and
> the kernel's rpcbind client.  Eventually, we should convert NFSv3 and
> NLM to use this style of marshalling XDR so that we can streamline
> call_encode() and call_decode().
>
> ---
>
> Chuck Lever (24):
>        NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
>        NFS: Decode NFSv2 statfs reply using an xdr_stream
>        NFS: Decode NFSv2 readdir reply using an xdr_stream
>        NFS: Decode NFSv2 write reply using an xdr_stream
>        NFS: Decode NFSv2 read reply using an xdr_stream
>        NFS: Decode NFSv2 readlink reply using an xdr_stream
>        NFS: Decode NFSv2 dirop reply using an xdr_stream
>        NFS: Decode NFSv2 attrstat reply using an xdr_stream
>        NFS: Decode NFSv2 stat reply using an xdr_stream
>        NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()
>        NFS: Replace old NFSv2 encoder functions with xdr_stream-based ones
>        NFS: Encode NFSv2 readdir argument using an xdr_stream
>        NFS: Encode NFSv2 symlink argument using an xdr_stream
>        NFS: Encode NFSv2 link argument using an xdr_stream
>        NFS: Encode NFSv2 rename argument using an xdr_stream
>        NFS: Encode NFSv2 create argument using an xdr_stream
>        NFS: Encode NFSv2 write argument using an xdr_stream
>        NFS: Encode NFSv2 read argument using an xdr_stream
>        NFS: Encode NFSv2 readlink argument using an xdr_stream
>        NFS: Encode dirop argument using an xdr_stream
>        NFS: Encode v2 setattr argument using an xdr_stream
>        NFS: Encode NFSv2 fhandle argument using an xdr_stream
>        NFS: Introduce XDR helpers for basic NFSv2 data types
>        SUNRPC: Refactor logic to NUL-terminate strings in pages
>
>
>   fs/nfs/internal.h          |    2
>   fs/nfs/nfs2xdr.c           | 1169 +++++++++++++++++++++++++++++---------------
>   fs/nfs/nfs3xdr.c           |    6
>   fs/nfs/nfs4xdr.c           |    5
>   include/linux/sunrpc/xdr.h |    1
>   net/sunrpc/xdr.c           |   17 +
>   6 files changed, 779 insertions(+), 421 deletions(-)
>

