Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59498 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398AbaABVVv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jan 2014 16:21:51 -0500
Date: Thu, 2 Jan 2014 16:21:50 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, simo@redhat.com, neilb@suse.de
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140102212149.GC28219@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
 <1388579314-15255-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1388579314-15255-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 01, 2014 at 07:28:30AM -0500, Jeff Layton wrote:
> It doesn't make much sense to make reads from this procfile hang. As
> far as I can tell, only gssproxy itself will open this file and it
> never reads from it. Change it to just give the present setting of
> sn->use_gss_proxy without waiting for anything.

I think my *only* reason for doing this was to give a simple way to wait
for gss-proxy to start (just wait for a read to return).

As long as gss-proxy has some way to say "I'm up and running", and as
long as that comes after writing to use-gss-proxy, we're fine.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 008cdad..5e9323e 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1355,16 +1355,12 @@ static ssize_t read_gssp(struct file *file, char __user *buf,
>  			 size_t count, loff_t *ppos)
>  {
>  	struct net *net = PDE_DATA(file_inode(file));
> +	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>  	unsigned long p = *ppos;
>  	char tbuf[10];
>  	size_t len;
> -	int ret;
> -
> -	ret = wait_for_gss_proxy(net, file);
> -	if (ret)
> -		return ret;
>  
> -	snprintf(tbuf, sizeof(tbuf), "%d\n", use_gss_proxy(net));
> +	snprintf(tbuf, sizeof(tbuf), "%d\n", sn->use_gss_proxy);
>  	len = strlen(tbuf);
>  	if (p >= len)
>  		return 0;
> -- 
> 1.8.4.2
> 
