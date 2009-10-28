From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH]  Fixed compile errors when the mount config file is not
 enabled
Date: Wed, 28 Oct 2009 08:20:02 -0400
Message-ID: <4AE836F2.7020905@redhat.com>
References: <4AE751CE.1050300@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbZJ1MT6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Oct 2009 08:19:58 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9SCK24T017393
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2009 08:20:03 -0400
In-Reply-To: <4AE751CE.1050300-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:
> Author: Steve Dickson <steved@redhat.com>
> Date:   Tue Oct 27 15:47:27 2009 -0400
> 
>     Added wrappers around the setting of default values
>     from the config file which will be compiled out
>     when the config file is not enabled.
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/support/include/conffile.h b/support/include/conffile.h
> index fe23ec2..ce7aa21 100644
> --- a/support/include/conffile.h
> +++ b/support/include/conffile.h
> @@ -76,10 +76,5 @@ static inline void upper2lower(char *str)
>  		*str++ = c;
>  }
>  
> -/*
> - * Default Mount options
> - */
> -extern unsigned long config_default_vers;
> -extern unsigned long config_default_proto;
>  
>  #endif				/* _CONFFILE_H_ */
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index e651167..d4ecbc9 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -172,6 +172,27 @@ static const unsigned long probe_mnt3_first[] = {
>  	0,
>  };
>  
> +inline const unsigned int *set_default_proto(void);
> +#ifdef MOUNT_CONFIG
> +inline const unsigned int *set_default_proto()
> +{
> +	extern unsigned long config_default_proto;
> +	/*
> +	 * If the default proto has been set and 
> +	 * its not TCP, start with UDP
> +	 */
> +	if (config_default_proto && config_default_proto != IPPROTO_TCP)
> +		return probe_udp_first;
> +

Shouldn't there be something to account for NFSv4 only being
supported over TCP and not UDP by specification?  The Linux
server still supports NFSv4 over UDP, although it is not
supposed to and should not.  Even if the default transport
is set to UDP, NFSv4 should always be mounted over TCP.

	Thanx...

		ps

> +	return probe_tcp_first; 
> +}
> +#else
> +inline const unsigned int *set_default_proto() 
> +{
> +	return probe_tcp_first; 
> +}
> +#endif /* MOUNT_CONFIG */
> +
>  static int nfs_lookup(const char *hostname, const sa_family_t family,
>  		      struct sockaddr *sap, socklen_t *salen)
>  {
> @@ -590,7 +611,6 @@ out_ok:
>  	nfs_clear_rpc_createerr();
>  	return 1;
>  }
> -
>  /*
>   * Probe a server's NFS service to determine which versions and
>   * transport protocols are supported.
> @@ -611,14 +631,9 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
>  		return 1;
>  
>  	if (nfs_mount_data_version >= 4) {
> -		const unsigned int *probe_proto = probe_tcp_first;
> +		const unsigned int *probe_proto;
>  
> -		/*
> -		 * If the default proto has been set and 
> -		 * its not TCP, start with UDP
> -		 */
> -		if (config_default_proto && config_default_proto != IPPROTO_TCP)
> -			probe_proto =  probe_udp_first;
> +		probe_proto = set_default_proto();
>  
>  		return nfs_probe_port(sap, salen, pmap,
>  					probe_nfs3_first, probe_proto);
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index ceefdb0..7b63b45 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -93,6 +93,24 @@ struct nfsmount_info {
>  				child;		/* forked bg child? */
>  };
>  
> +inline void set_default_version(struct nfsmount_info *mi);
> +#ifdef MOUNT_CONFIG
> +inline void set_default_version(struct nfsmount_info *mi)
> +{
> +	extern unsigned long config_default_vers;
> +	/*
> +	 * Use the default value set in the config file when
> +	 * the version has not been explicitly set.
> +	 */
> +	if (mi->version == 0 && config_default_vers) {
> +		if (config_default_vers < 4)
> +			mi->version = config_default_vers;
> +	}
> +}
> +#else
> +inline void set_default_version(struct nfsmount_info *mi) {}
> +#endif /* MOUNT_CONFIG */
> +
>  /*
>   * Obtain a retry timeout value based on the value of the "retry=" option.
>   *
> @@ -258,7 +276,6 @@ static int nfs_append_sloppy_option(struct mount_options *options)
>  		return 0;
>  	return 1;
>  }
> -
>  /*
>   * Set up mandatory non-version specific NFS mount options.
>   *
> @@ -284,14 +301,12 @@ static int nfs_validate_options(struct nfsmount_info *mi)
>  		if (option && strcmp(option, "rdma") == 0)
>  			mi->version = 3;
>  	}
> +
>  	/*
> -	 * Use the default value set in the config file when
> -	 * the version has not been explicitly set.
> +	 * If enabled, see if the default version was
> +	 * set in the config file
>  	 */
> -	if (mi->version == 0 && config_default_vers) {
> -		if (config_default_vers < 4)
> -			mi->version = config_default_vers;
> -	}
> +	set_default_version(mi);
>  
>  	if (!nfs_append_sloppy_option(mi->options))
>  		return 0;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

