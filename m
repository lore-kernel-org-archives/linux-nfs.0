Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754361AbaADOLL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Jan 2014 09:11:11 -0500
Date: Sat, 4 Jan 2014 09:11:05 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, ssorce@redhat.com,
        neilb@suse.de
Subject: Re: [PATCH 2/3] sunrpc: fix potential race between setting
 use_gss_proxy and the upcall rpc_clnt
Message-ID: <20140104091105.4dc2a971@tlielax.poochiereds.net>
In-Reply-To: <1388837885-8312-3-git-send-email-jlayton@redhat.com>
References: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
	<1388837885-8312-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat,  4 Jan 2014 07:18:04 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> Currently, the write_gssp code will change the variable and wake up any
> waiters waiting on that change. It then goes and tries to set the
> gssp_clnt. This is racy -- a task waiting on the set_gss_proxy call may
> end up waking up and then subsequently finding that the gss_clnt isn't
> there yet and end up not using it even though it'll soon be ready.
> 
> This patch reverses the order of operations. The gssp_clnt is created
> first, and the variable change is done only if that succeeds.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 1b94a9c..60dc370 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1317,10 +1317,10 @@ static ssize_t write_gssp(struct file *file, const char __user *buf,
>  		return res;
>  	if (i != 1)
>  		return -EINVAL;
> -	res = set_gss_proxy(net, 1);
> +	res = set_gssp_clnt(net);
>  	if (res)
>  		return res;
> -	res = set_gssp_clnt(net);
> +	res = set_gss_proxy(net, 1);
>  	if (res)
>  		return res;
>  	return count;

Sorry, I forgot to update the patch description on this one. There is
still a race here after patch #1, but it goes something like this:

A nfsd thread will call use_gss_proxy and find it set to '1'. It'll
then go and attempt and upcall, but since gssp_clnt is still NULL,
gssp_call will just return -EIO.

The patch is still the same however. Bruce, let me know if you want me
to resend with a fixed commit msg.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
