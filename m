Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40916 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754441AbdDDUIQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Apr 2017 16:08:16 -0400
Subject: Re: [PATCH 2/2] nfsd: Change the default to enable all minor versions
 unless told otherwise
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <20170224003344.113724-1-trond.myklebust@primarydata.com>
 <20170224003344.113724-2-trond.myklebust@primarydata.com>
 <20170224003344.113724-3-trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.com
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <77740f32-f283-0572-9660-5d5037dbcafe@RedHat.com>
Date: Tue, 4 Apr 2017 16:08:15 -0400
MIME-Version: 1.0
In-Reply-To: <20170224003344.113724-3-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/23/2017 07:33 PM, Trond Myklebust wrote:
> Instead of letting the kernel decide, default to enabling all versions,
> and let the user be more specifc in /etc/nfs.conf or on the command line.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
This one was NACKed by Bruce... 

steved.

> ---
>  utils/nfsd/nfsd.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 1708521ab286..9735e65466fa 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -107,13 +107,12 @@ main(int argc, char **argv)
>  	}
>  
>  	nfssvc_get_minormask(&minormask);
> -	/* We assume the kernel will default all minor versions to 'on',
> -	 * and allow the config file to disable some.
> +	/* We default all minor versions to 'on', and allow the config
> +	 * file to disable some.
>  	 */
> -	if (NFSCTL_VERISSET(versbits, 4)) {
> -		NFSCTL_MINORSET(minorversset, 0);
> -		NFSCTL_MINORSET(minorvers, 0);
> -	}
> +	if (NFSCTL_VERISSET(versbits, 4))
> +		minorversset = minorvers = minormask;
> +
>  	for (i = 1; i <= NFS4_MAXMINOR; i++) {
>  		char tag[20];
>  		sprintf(tag, "vers4.%d", i);
> 
