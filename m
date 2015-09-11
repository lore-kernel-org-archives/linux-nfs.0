Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbbIKVXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 17:23:21 -0400
Date: Fri, 11 Sep 2015 17:23:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Sunrpc: Supports hexadecimal number for sysctl files of
 sunrpc debug
Message-ID: <20150911212320.GG11677@fieldses.org>
References: <55F17A7E.50406@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55F17A7E.50406@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2015 at 08:41:34PM +0800, Kinglong Mee wrote:
> The sunrpc debug sysctl files only accept decimal number right now.
> But all the XXXDBUG_XXX macros are defined as hexadecimal.
> It is not easy to set or check an separate flag.
> 
> This patch let those files support accepting hexadecimal number,
> (decimal number is also supported). Also, display it as hexadecimal.

That potentially breaks backwards-compatibility if an program that reads
this file isn't prepared to accept a hexadecimal value.

That said, rpcdebug seems OK (it uses strtoul(.,.,0), which I think
should parse that fine?), and it may well be the only program that
actually parses this, so....  I suppose it's OK with me if it's OK with
Trond.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/sysctl.c | 26 +++++++++++++++-----------
>  1 file changed, 15 insertions(+), 11 deletions(-)
> 
> diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
> index 887f018..8e85e6f 100644
> --- a/net/sunrpc/sysctl.c
> +++ b/net/sunrpc/sysctl.c
> @@ -76,7 +76,7 @@ static int
>  proc_dodebug(struct ctl_table *table, int write,
>  				void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> -	char		tmpbuf[20], c, *s;
> +	char		tmpbuf[20], c, *s = NULL;
>  	char __user *p;
>  	unsigned int	value;
>  	size_t		left, len;
> @@ -103,23 +103,27 @@ proc_dodebug(struct ctl_table *table, int write,
>  			return -EFAULT;
>  		tmpbuf[left] = '\0';
>  
> -		for (s = tmpbuf, value = 0; '0' <= *s && *s <= '9'; s++, left--)
> -			value = 10 * value + (*s - '0');
> -		if (*s && !isspace(*s))
> -			return -EINVAL;
> -		while (left && isspace(*s))
> -			left--, s++;
> +		if (tmpbuf[0] == '0' && tmpbuf[1] == 'x')
> +			value = simple_strtol(tmpbuf, &s, 16);
> +		else
> +			value = simple_strtol(tmpbuf, &s, 0);
> +		if (s) {
> +			if (!isspace(*s))
> +				return -EINVAL;
> +			left -= (s - tmpbuf);
> +			while (left && isspace(*s))
> +				left--, s++;
> +		} else
> +			left = 0;
>  		*(unsigned int *) table->data = value;
>  		/* Display the RPC tasks on writing to rpc_debug */
>  		if (strcmp(table->procname, "rpc_debug") == 0)
>  			rpc_show_tasks(&init_net);
>  	} else {
> -		if (!access_ok(VERIFY_WRITE, buffer, left))
> -			return -EFAULT;
> -		len = sprintf(tmpbuf, "%d", *(unsigned int *) table->data);
> +		len = sprintf(tmpbuf, "0x%04x", *(unsigned int *) table->data);
>  		if (len > left)
>  			len = left;
> -		if (__copy_to_user(buffer, tmpbuf, len))
> +		if (copy_to_user(buffer, tmpbuf, len))
>  			return -EFAULT;
>  		if ((left -= len) > 0) {
>  			if (put_user('\n', (char __user *)buffer + len))
> -- 
> 2.5.0
