Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51017 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab3KNQb4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:31:56 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] NFS: correctly report misuse of "migration" mount option.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131114130017.374c0f3d@notabene.brown>
Date: Thu, 14 Nov 2013 11:31:44 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Message-Id: <2AD44909-BC7D-437C-8F9A-F6B2103DDC9E@oracle.com>
References: <20131114130017.374c0f3d@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 13, 2013, at 9:00 PM, NeilBrown <neilb@suse.de> wrote:

> 
> The current test on valid use of the "migration" mount option can never
> report an error as it will only do so if
>    mnt->version !=4 && mnt->minor_version != 0
> (and some other condition), but if that test would succeed, then the previous
> test has already gone-to  out_minorversion_mismatch.
> 
> So change the && to an || to get correct semantics.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>

Acked-by: Chuck Lever <chuck.lever@oracle.com>

> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 317d6fc2160e..910ed906eb82 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1613,9 +1613,9 @@ static int nfs_parse_mount_options(char *raw,
> 	if (mnt->minorversion && mnt->version != 4)
> 		goto out_minorversion_mismatch;
> 
> 	if (mnt->options & NFS_OPTION_MIGRATION &&
> -	    mnt->version != 4 && mnt->minorversion != 0)
> +	    (mnt->version != 4 || mnt->minorversion != 0))
> 		goto out_migration_misuse;
> 
> 	/*
> 	 * verify that any proto=/mountproto= options match the address

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




