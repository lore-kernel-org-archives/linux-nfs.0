Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7237 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751463AbeBWQYG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Feb 2018 11:24:06 -0500
Subject: Re: [PATCH 1/1] NFS guard against incorrect vers inputs from
 nfs-utils
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
References: <20180222192806.67911-1-kolga@netapp.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <034fb5f1-eba5-030b-aad2-6ac5e87f2066@RedHat.com>
Date: Fri, 23 Feb 2018 11:24:04 -0500
MIME-Version: 1.0
In-Reply-To: <20180222192806.67911-1-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Olga,

On 02/22/2018 02:28 PM, Olga Kornievskaia wrote:
> It is possible that userland can pass to the kernel mismatching
> inputs for the minorversion. like vers=4.1,minorversion=0. Instead
> of making the kernel responposible for 'choosing' the minorversion,
> make the userland always responsible for not sending a mismatch.
I'm thinking this is probably more of mount problem...

mount -t nfs4 -o minorversion=0 server:/export /mnt

shouldn't this be a  v4.0 mount instead of a 4.2 mount?

steved. 

> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/super.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 29bacdc..90c0584 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1207,7 +1207,7 @@ static int nfs_parse_mount_options(char *raw,
>  				   struct nfs_parsed_mount_data *mnt)
>  {
>  	char *p, *string, *secdata;
> -	int rc, sloppy = 0, invalid_option = 0;
> +	int rc, sloppy = 0, invalid_option = 0, minorversion = -1;
>  	unsigned short protofamily = AF_UNSPEC;
>  	unsigned short mountfamily = AF_UNSPEC;
>  
> @@ -1419,6 +1419,7 @@ static int nfs_parse_mount_options(char *raw,
>  			if (option > NFS4_MAX_MINOR_VERSION)
>  				goto out_invalid_value;
>  			mnt->minorversion = option;
> +			minorversion = option;
>  			break;
>  
>  		/*
> @@ -1655,6 +1656,9 @@ static int nfs_parse_mount_options(char *raw,
>  		}
>  	}
>  
> +	if (minorversion >= 0 && minorversion != mnt->minorversion)
> +		goto out_mountvers_mismatch;
> +
>  	return 1;
>  
>  out_mountproto_mismatch:
> @@ -1685,6 +1689,10 @@ static int nfs_parse_mount_options(char *raw,
>  	free_secdata(secdata);
>  	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
>  	return 0;
> +out_mountvers_mismatch:
> +	printk(KERN_INFO "NFS: mismatch versions supplied vers=4.%d and "
> +			 "minorversion=%d\n", mnt->minorversion, minorversion);
> +	return 0;
>  }
>  
>  /*
> 
