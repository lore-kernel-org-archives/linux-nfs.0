Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29585 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab1CJQA5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 11:00:57 -0500
Subject: Re: [PATCH] NFS: Fix handling of commmand line options for NFSROOT
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1299771798-29285-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Date: Thu, 10 Mar 2011 10:59:24 -0500
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        patches@opensource.wolfsonmicro.com
Message-Id: <382578FF-22A9-4840-B3A7-EFEFA5453C35@oracle.com>
References: <1299771798-29285-1-git-send-email-broonie@opensource.wolfsonmicro.com>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 10, 2011, at 10:43 AM, Mark Brown wrote:

> Commmit 972903 (NFS: NFSROOT should default to "proto=udp") added a
> default NFS mount option using the existing in-kernel code to parse
> mount options out of the command line. This exposed a bug in the
> existing code - it would not add a , separating the existing options
> from the new options resulting in strings such as "udprsize=1024"
> rather than "udp,rsize=1024"
> 
> Fix this by adding a , before the new options if the options are not
> empty when we append.

Looks like a real bug.

We might be better off teaching root_nfs_cat() to deal with the extra comma as necessary right when we concatenate the options strings.  That would simplify it's callers.

> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
> ---
> fs/nfs/nfsroot.c |    7 ++++++-
> 1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> index 0bc654f..309df59 100644
> --- a/fs/nfs/nfsroot.c
> +++ b/fs/nfs/nfsroot.c
> @@ -193,10 +193,15 @@ static int __init root_nfs_parse_options(char *incoming, char *exppath,
> 	 * @incoming now points to the rest of the string; if it
> 	 * contains something, append it to our root options buffer
> 	 */
> -	if (incoming != NULL && *incoming != '\0')
> +	if (incoming != NULL && *incoming != '\0') {
> +		if (nfs_root_options[0] != '\0' &&
> +		    root_nfs_cat(nfs_root_options, ",",
> +						sizeof(nfs_root_options)))
> +			return -1;
> 		if (root_nfs_cat(nfs_root_options, incoming,
> 						sizeof(nfs_root_options)))
> 			return -1;
> +	}
> 
> 	/*
> 	 * Possibly prepare for more options to be appended
> -- 
> 1.7.2.3
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




