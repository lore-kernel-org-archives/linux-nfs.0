Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:52308 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032Ab0A0SKO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2010 13:10:14 -0500
Message-ID: <4B60816E.5070108@oracle.com>
Date: Wed, 27 Jan 2010 13:09:50 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: Don't fail mounts when /etc/netconfig is nonexistent
References: <4B606CA5.2090607@RedHat.com>
In-Reply-To: <4B606CA5.2090607@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/27/2010 11:41 AM, Steve Dickson wrote:
> During some recent testing, mounts were mysteriously failing to some
> servers but not to others. The mounts that were failure were in a very sparse
> environment. Meaning very little in any supporting utilities, like
> /bin/cat, /bin/ls or system-wide configuration files.
>
> The reason the mounts were failing was /etc/netconfig did not exist.
> Even in the cases when all the information that would have been pulled
> from /etc/netconfig already existed or was easily attainable
>
> So the patch tries to recover from when system files are inaccessible
> and the need information already exists or is well known.
>
> steved.
>
> Author: Steve Dickson<steved@redhat.com>
> Date:   Wed Jan 27 11:19:00 2010 -0500
>
>      In a very sparse environments certain system files (like
>      /etc/netconfig) may not exist. In these environments don't
>      fail mount if all the need information (like network protocols)
>      exist and are well known.
>
>      Signed-off-by: Steve Dickson<steved@redhat.com>

I totally disagree with this.  If HAVE_LIBTIRPC is set, then the runtime 
TI-RPC package should be installed, in its entirety, on the run-time 
systems.  If autoconf and RPM can't trust the given dependency 
information, then all bets are off.

The right fix is to either:

a) install a non-TI-RPC version of mount.nfs, or

b) make sure /etc/netconfig is available when RPM, pkgconfig, and 
autoconf say it should be.

Mount.nfs is not the only program that needs to have this information.

I assume since you are not patching other parts of mount.nfs that look 
for /etc/rpc and /etc/protocols that these files _do_ exist?  Or does 
glibc also do this hack of filling in well-known values?

> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index c930539..e490dd4 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -277,7 +277,7 @@ nfs_get_proto(const char *netid, sa_family_t *family, unsigned long *protocol)
>   #ifdef HAVE_LIBTIRPC
>   char *nfs_get_netid(const sa_family_t family, const unsigned long protocol)
>   {
> -	char *nc_protofmly, *nc_proto, *nc_netid;
> +	char *nc_protofmly, *nc_proto, *nc_netid = NULL;
>   	struct netconfig *nconf;
>   	struct protoent *proto;
>   	void *handle;
> @@ -319,6 +319,19 @@ char *nfs_get_netid(const sa_family_t family, const unsigned long protocol)
>   	endnetconfig(handle);
>
>   out:
> +	/*
> +	 * The system configuration files are inaccessible
> +	 * so see if these are well known protocols
> +	 */
> +	if (protocol == IPPROTO_TCP)
> +		nc_netid = (family == AF_INET6 ?
> +			strdup("tcp6") : strdup("tcp"));
> +	else if (protocol == IPPROTO_UDP)
> +		nc_netid = (family == AF_INET6 ?
> +			strdup("udp6") : strdup("udp"));
> +	if (nc_netid != NULL)
> +		return nc_netid;
> +
>   	rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
>   	return NULL;
>   }
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 06cab6a..fa99bc1 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1270,7 +1270,26 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
>   	*version = 0;
>   	return 1;
>   }
> -
> +/*
> + * Returns TRUE if the option string is a well known protocol
> + */
> +int
> +nfs_set_proto(char *option,  unsigned long *protocol)
> +{
> +	if (strcmp(option, "tcp") == 0 ||
> +			strcmp(option, "tcp6") == 0) {
> +		*protocol = IPPROTO_TCP;
> +		return 1;
> +	}
> +	if (strcmp(option, "udp") == 0 ||
> +			strcmp(option, "udp6") == 0) {
> +		*protocol = IPPROTO_UDP;
> +		return 1;
> +	}
> +	if (verbose)
> +		nfs_error(_("%s: unkown protocol: '%s'"), progname, option);
> +	return 0;
> +}
>   /*
>    * Returns TRUE if @protocol contains a valid value for this option,
>    * or FALSE if the option was specified with an invalid value.
> @@ -1290,8 +1309,13 @@ nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
>   		return 1;
>   	case 2: /* proto */
>   		option = po_get(options, "proto");
> -		if (option != NULL)
> -			return nfs_get_proto(option,&family, protocol);
> +		if (option != NULL) {
> +			if (nfs_get_proto(option,&family, protocol))
> +				return 1;
> +			if (nfs_set_proto(option, protocol))
> +				return 1;
> +			return 0;
> +		}
>   	}
>
>   	/*
> @@ -1438,8 +1462,13 @@ nfs_mount_protocol(struct mount_options *options, unsigned long *protocol)
>   	char *option;
>
>   	option = po_get(options, "mountproto");
> -	if (option != NULL)
> -		return nfs_get_proto(option,&family, protocol);
> +	if (option != NULL) {
> +		if (nfs_get_proto(option,&family, protocol))
> +			return 1;
> +		if (nfs_set_proto(option, protocol))
> +			return 1;
> +		return 0;
> +	}
>
>   	/*
>   	 * MNT transport protocol wasn't specified.  If the NFS

-- 
chuck[dot]lever[at]oracle[dot]com
