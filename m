Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44905 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293AbcFBOvD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2016 10:51:03 -0400
Subject: Re: [Libtirpc-devel] [PATCH 2/3] Record errno value before calling
 syslog
To: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>,
        libtirpc-devel@lists.sourceforge.net
References: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-3-git-send-email-pcpa@gnu.org>
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <c8fb0518-74fe-bcdb-75c7-d8cee29fb9bb@RedHat.com>
Date: Thu, 2 Jun 2016 10:51:01 -0400
MIME-Version: 1.0
In-Reply-To: <1463672110-10026-3-git-send-email-pcpa@gnu.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/19/2016 11:35 AM, Paulo Andrade wrote:
>   Unlikely to change, but stay in the safe side.
> 
> Signed-off-by: Paulo Andrade <pcpa@gnu.org>
Committed.. 

steved.

> ---
>  src/clnt_vc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/src/clnt_vc.c b/src/clnt_vc.c
> index 8af7ddd..0da18ca 100644
> --- a/src/clnt_vc.c
> +++ b/src/clnt_vc.c
> @@ -191,10 +191,10 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
>  	ct = (struct ct_data *)mem_alloc(sizeof (*ct));
>  	if ((cl == (CLIENT *)NULL) || (ct == (struct ct_data *)NULL)) {
>  		struct rpc_createerr *ce = &get_rpc_createerr();
> -		(void) syslog(LOG_ERR, clnt_vc_errstr,
> -		    clnt_vc_str, __no_mem_str);
>  		ce->cf_stat = RPC_SYSTEMERROR;
>  		ce->cf_error.re_errno = errno;
> +		(void) syslog(LOG_ERR, clnt_vc_errstr,
> +		    clnt_vc_str, __no_mem_str);
>  		goto err;
>  	}
>  	ct->ct_addr.buf = NULL;
> 
