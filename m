From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/4] nfs-utils: make private cookie to hex conversion a library routine
Date: Wed, 6 Jan 2010 10:37:58 -0500
Message-ID: <49FB97E4-8C40-4FFC-AFA1-9D933041A189@oracle.com>
References: <1262791209-8045-1-git-send-email-jlayton@redhat.com> <1262791209-8045-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:27647 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407Ab0AFPif (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 10:38:35 -0500
In-Reply-To: <1262791209-8045-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 6, 2010, at 10:20 AM, Jeff Layton wrote:

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> support/include/nsm.h |    2 ++
> support/nsm/file.c    |   44 +++++++++++++++++++++++++++++++++ 
> +----------
> 2 files changed, 36 insertions(+), 10 deletions(-)
>
> diff --git a/support/include/nsm.h b/support/include/nsm.h
> index b9af8ac..a1d7e39 100644
> --- a/support/include/nsm.h
> +++ b/support/include/nsm.h
> @@ -69,6 +69,8 @@ extern _Bool	nsm_insert_monitored_host(const char  
> *hostname,
> 			const struct sockaddr *sap, const struct mon *m);
> extern void	nsm_delete_monitored_host(const char *hostname);
> extern void	nsm_delete_notified_host(const char *hostname);
> +extern size_t	nsm_priv_to_hex(const char *priv, char *buf,
> +				const size_t buflen);
>
> /* rpc.c */
>
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index 2d47946..10af59e 100644
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

If you're going to respin anyway, this comment should mention that the  
output string is terminated with '\0'.

> + * @buflen: size of output buffer
> + *
> + * Returns the length of the resulting string or 0 on error.
> + */
> +size_t
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
> +		remaining -= (size_t)len;
> +	}
> +
> +	return buflen - remaining;
> +}
> +
> +/*
>  * Returns the length in bytes of the created record.
>  */
> __attribute_noinline__
> @@ -686,8 +713,8 @@ nsm_create_monitor_record(char *buf, const  
> size_t buflen,
> 		const struct sockaddr *sap, const struct mon *m)
> {
> 	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
> -	size_t remaining = buflen;
> -	int i, len;
> +	size_t hexlen, remaining = buflen;
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
> +	hexlen = nsm_priv_to_hex(m->priv, buf, remaining);
> +	if (hexlen == 0)
> +		return 0;
> +	buf += hexlen;
> +	remaining -= hexlen;
>
> 	len = snprintf(buf, remaining, " %s %s\n",
> 			m->mon_id.mon_name, m->mon_id.my_id.my_name);
> -- 
> 1.6.5.2
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



