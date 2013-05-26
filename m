Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418Ab3EZPIB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 May 2013 11:08:01 -0400
Subject: Re: [PATCH] svcrpc: implement O_NONBLOCK behavior for use-gss-proxy
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Jan Stancek <jstancek@redhat.com>
In-Reply-To: <20130524221228.GB28309@fieldses.org>
References: <20130524221228.GB28309@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 26 May 2013 11:07:58 -0400
Message-ID: <1369580878.2769.74.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-05-24 at 18:12 -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Somebody noticed LTP was complaining about O_NONBLOCK opens of
> /proc/net/rpc/use-gss-proxy succeeding and then a following read
> hanging.
> 
> I'm not convinced LTP really has any business opening random proc files
> and expecting them to behave a certain way.  And I don't really know if
> this is really a bug.
> 
> But in any case perhaps the O_NONBLOCK behavior could be useful for
> someone that wants to test whether gss-proxy is up without waiting.
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Ack by me.

Simo.


> ---
>  net/sunrpc/auth_gss/svcauth_gss.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> Considering for 3.10.
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 9f0f017..618ccf5 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1313,10 +1313,12 @@ static inline bool gssp_ready(struct sunrpc_net *sn)
>  	return false;
>  }
>  
> -static int wait_for_gss_proxy(struct net *net)
> +static int wait_for_gss_proxy(struct net *net, struct file *file)
>  {
>  	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>  
> +	if (file->f_flags & O_NONBLOCK && !gssp_ready(sn))
> +		return -EAGAIN;
>  	return wait_event_interruptible(sn->gssp_wq, gssp_ready(sn));
>  }
>  
> @@ -1358,7 +1360,7 @@ static ssize_t read_gssp(struct file *file, char __user *buf,
>  	size_t len;
>  	int ret;
>  
> -	ret = wait_for_gss_proxy(net);
> +	ret = wait_for_gss_proxy(net, file);
>  	if (ret)
>  		return ret;
>  


-- 
Simo Sorce * Red Hat, Inc * New York

