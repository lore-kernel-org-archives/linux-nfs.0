From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/4] nfs-utils: make private cookie to hex conversion a library routine
Date: Wed, 6 Jan 2010 08:08:41 -0500
Message-ID: <B0506F92-BD8E-4B25-BADB-0719DDC58C1E@oracle.com>
References: <1262782412-7050-1-git-send-email-jlayton@redhat.com> <1262782412-7050-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:39799 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204Ab0AFNJa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 08:09:30 -0500
In-Reply-To: <1262782412-7050-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 6, 2010, at 7:53 AM, Jeff Layton wrote:

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> support/include/nsm.h |    2 ++
> support/nsm/file.c    |   42 ++++++++++++++++++++++++++++++++ 
> +---------
> 2 files changed, 35 insertions(+), 9 deletions(-)
>
> diff --git a/support/include/nsm.h b/support/include/nsm.h
> index b9af8ac..fe56ecc 100644
> --- a/support/include/nsm.h
> +++ b/support/include/nsm.h
> @@ -69,6 +69,8 @@ extern _Bool	nsm_insert_monitored_host(const char  
> *hostname,
> 			const struct sockaddr *sap, const struct mon *m);
> extern void	nsm_delete_monitored_host(const char *hostname);
> extern void	nsm_delete_notified_host(const char *hostname);
> +extern int	nsm_priv_to_hex(const char *priv, char *buf,
> +				const size_t buflen);
>
> /* rpc.c */
>
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index 2d47946..9c47e04 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -678,6 +678,33 @@ nsm_retire_monitored_hosts(void)
> }
>
> /*
> + * nsm_priv_to_hex - convert a NSM private cookie to a hex string.
> + *
> + * @priv: buffer holding the binary NSM private cookie
> + * @buf: output buffer for hex string
> + * @buflen: size of output buffer
> + *
> + * Returns the length of the resulting string or 0 on error.
> + */
> +int

String length is usually size_t.  Since this never returns a negative  
value, the return value should at least be unsigned.  Returning size_t  
would avoid the extra type cast below.

> +nsm_priv_to_hex(const char *priv, char *buf, const size_t buflen)
> +{
> +	int i, len;
> +	size_t remaining = buflen;
> +
> +	for (i = 0; i < SM_PRIV_SIZE; i++) {
> +		len = snprintf(buf, remaining, "%02x",
> +				(unsigned int)(0xff & priv[i]));
> +		if (error_check(len, remaining))
> +			return 0;
> +		buf += len;
> +		remaining -= (size_t) len;

Nit:  Whitespace convention in this source file follows the kernel,  
which is to leave out the blank between a type cast and the variable  
it's casting.

> +	}
> +
> +	return buflen - remaining;
> +}
> +
> +/*
>  * Returns the length in bytes of the created record.
>  */
> __attribute_noinline__
> @@ -687,7 +714,7 @@ nsm_create_monitor_record(char *buf, const  
> size_t buflen,
> {
> 	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
> 	size_t remaining = buflen;
> -	int i, len;
> +	int len;
>
> 	len = snprintf(buf, remaining, "%08x %08x %08x %08x ",
> 			(unsigned int)sin->sin_addr.s_addr,
> @@ -699,14 +726,11 @@ nsm_create_monitor_record(char *buf, const  
> size_t buflen,
> 	buf += len;
> 	remaining -= (size_t)len;
>
> -	for (i = 0; i < SM_PRIV_SIZE; i++) {
> -		len = snprintf(buf, remaining, "%02x",
> -				(unsigned int)(0xff & m->priv[i]));
> -		if (error_check(len, remaining))
> -			return 0;
> -		buf += len;
> -		remaining -= (size_t)len;
> -	}
> +	len = nsm_priv_to_hex(m->priv, buf, remaining);
> +	if (!len)

Nit:  I prefer "len == 0" since "!" operates specifically on  
booleans.  While "!" does what we want here, it's slightly more  
correct (and more future proof) to compare explicitly to zero in such  
cases.

> +		return 0;
> +	buf += len;
> +	remaining -= (size_t) len;
>
> 	len = snprintf(buf, remaining, " %s %s\n",
> 			m->mon_id.mon_name, m->mon_id.my_id.my_name);
> -- 
> 1.6.5.2
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



