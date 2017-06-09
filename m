Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49134 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751629AbdFINYg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Jun 2017 09:24:36 -0400
Subject: Re: [PATCH V2] mount.nfs: Use default minor version when -t nfs4 is
 specified
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170608183314.15247-1-steved@redhat.com>
 <87a85hadi6.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <00345580-ccd6-3006-852d-f6762e2cbb06@RedHat.com>
Date: Fri, 9 Jun 2017 09:24:35 -0400
MIME-Version: 1.0
In-Reply-To: <87a85hadi6.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/09/2017 02:20 AM, NeilBrown wrote:
> On Thu, Jun 08 2017, Steve Dickson wrote:
> 
>> When the nfs4 filesystem specified, the default major
>> and minor versions should be used.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> Hi Steve,
>  I think this is definitely heading in the right direction.
>  I particularly like that you've #defined for the default major/minor.
> 
>  However as I reflected on it, I realised that "-o v4" needs to set
>  the same version as "-t nfs4", and even with this patch it doesn't.
Good catch! 
> 
>  I think we need to focus on nfs_default_version() and make sure it does
>  the right thing.
> 
>  If v.mode == V_DEFAULT, we need to copy both 'major' and 'minor'
>  from config_default_vers if they are set.  If
>  config_default_vers.v_mode == V_GENERAL, .minor won't be set so in
>  that case we need to use NFS_DEFAULT_MINOR;
> 
>  If v.mode == V_GENERAL, then only copy the minor if it is set and the
>  major is correct.  So we need to check for V_SPECIFIC, and other wise
>  use the default minor.
That's how it worked out... 
> 
>  If v.mode == V_SPECIFIC, nfs_default_version isn't called, so it
>  doesn't matter.
> 
>  I think this gets it right...
Also nfs_do_mount_v4() needs to check the minor
version as well...

thanks!

steved.

> 
>  Thoughts?
> 
> Thanks,
> NeilBrown
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index c0266e51ad1c..7dfdd9e62115 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -73,6 +73,13 @@
>  #define NFS_DEF_BG_TIMEOUT_MINUTES	(10000u)
>  #endif
>  
> +#ifndef NFS_DEFAULT_MAJOR
> +#define NFS_DEFAULT_MAJOR	4
> +#endif
> +#ifndef NFS_DEFAULT_MINOR
> +#define NFS_DEFAULT_MINOR	2
> +#endif
> +
>  extern int nfs_mount_data_version;
>  extern char *progname;
>  extern int verbose;
> @@ -110,22 +117,27 @@ static void nfs_default_version(struct nfsmount_info *mi)
>  	}
>  
>  	if (mi->version.v_mode == V_DEFAULT &&
> -		config_default_vers.v_mode != V_DEFAULT) {
> +	    config_default_vers.v_mode != V_DEFAULT) {
>  		mi->version.major = config_default_vers.major;
> -		mi->version.minor = config_default_vers.minor;
> +		if (config_default_vers.v_mode == V_SPECIFIC)
> +			mi->version.minor = config_default_vers.minor;
> +		else
> +			mi->version.minor = NFS_DEFAULT_MINOR;
>  		return;
>  	}
>  
>  	if (mi->version.v_mode == V_GENERAL) {
> -		if (config_default_vers.v_mode != V_DEFAULT &&
> +		if (config_default_vers.v_mode == V_SPECIFIC &&
>  		    mi->version.major == config_default_vers.major)
>  			mi->version.minor = config_default_vers.minor;
> +		else
> +			mi->version.minor = NFS_DEFAULT_MINOR;
>  		return;
>  	}
>  
>  #endif /* MOUNT_CONFIG */
> -	mi->version.major = 4;
> -	mi->version.minor = 2;
> +	mi->version.major = NFS_DEFAULT_MAJOR;
> +	mi->version.minor = NFS_DEFAULT_MINOR;
>  }
>  
>  /*
> 
