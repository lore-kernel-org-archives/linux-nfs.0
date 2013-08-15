Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52326 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753173Ab3HORw7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 13:52:59 -0400
Date: Thu, 15 Aug 2013 13:52:58 -0400
From: "J.Bruce Fields" <bfields@citi.umich.edu>
To: Harshula Jayasuriya <harshula@redhat.com>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: prepare NFS for 2038
Message-ID: <20130815175258.GS17781@fieldses.org>
References: <1376588800.17754.14.camel@serendib>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1376588800.17754.14.camel@serendib>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 16, 2013 at 03:46:40AM +1000, Harshula Jayasuriya wrote:
> 1) The kernel sunrpc code needs to handle seconds since epoch
> greater than 2147483647. This means functions that parse time
> as an int need to handle it as time_t.

Anyone expecting not to have to upgrade their nfs server once between
now and 2038 is interesting, but... yes, may as well get it fixed now,
OK.

> 2) The kernel changes must be accompanied by userspace changes
> in nfs-utils.

This all looks backwards-compatible, so I assume that "must" is only if
you want this particular bug fixed.

Applying for 3.12 absent any objections.

--b.

> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
> ---
>  include/linux/sunrpc/cache.h | 22 ++++++++++++++++++++--
>  1 file changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 6ce690d..437ddb6 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -264,12 +264,30 @@ static inline int get_uint(char **bpp, unsigned int *anint)
>  	return 0;
>  }
>  
> +static inline int get_time(char **bpp, time_t *time)
> +{
> +	char buf[50];
> +	long long ll;
> +	int len = qword_get(bpp, buf, sizeof(buf));
> +
> +	if (len < 0)
> +		return -EINVAL;
> +	if (len == 0)
> +		return -ENOENT;
> +
> +	if (kstrtoll(buf, 0, &ll))
> +		return -EINVAL;
> +
> +	*time = (time_t)ll;
> +	return 0;
> +}
> +
>  static inline time_t get_expiry(char **bpp)
>  {
> -	int rv;
> +	time_t rv;
>  	struct timespec boot;
>  
> -	if (get_int(bpp, &rv))
> +	if (get_time(bpp, &rv))
>  		return 0;
>  	if (rv < 0)
>  		return 0;
> -- 
> 1.8.3.1
> 
