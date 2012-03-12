Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:35117 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2CLRjk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 13:39:40 -0400
Subject: Re: [PATCH] NFS: Always use the same SETCLIENTID boot verifier
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120309223445.4005.78869.stgit@degas.1015granger.net>
Date: Mon, 12 Mar 2012 13:39:31 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <776DF26C-1223-42ED-B356-234A5C66E034@oracle.com>
References: <20120309223445.4005.78869.stgit@degas.1015granger.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Mar 9, 2012, at 5:35 PM, Chuck Lever wrote:

> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c0d7220..747bf7a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3773,13 +3773,12 @@ wait_on_recovery:
> 	return -EAGAIN;
> }
> 
> -static void nfs4_construct_boot_verifier(struct nfs_client *clp,
> -					 nfs4_verifier *bootverf)
> +static void nfs4_gen_boot_verifier(nfs4_verifier *bootverf)
> {
> 	__be32 verf[2];
> 
> -	verf[0] = htonl((u32)clp->cl_boot_time.tv_sec);
> -	verf[1] = htonl((u32)clp->cl_boot_time.tv_nsec);
> +	verf[0] = cpu_to_be32((u32)nfs_boot_time.tv_sec);
> +	verf[1] = cpu_to_be32((u32)nfs_boot_time.tv_nsec);
> 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
> }
> 


One other question I had about this.  Do we really need to perform byte-swapping when constructing a boot verifier?  It's supposed to be opaque.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




