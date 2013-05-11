Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37980 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467Ab3EKSn5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 11 May 2013 14:43:57 -0400
Date: Sat, 11 May 2013 14:43:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Simo Sorce <simo@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Wei Yongjun <yongjun_wei@trendmicro.com.cn>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] svcauth_gss: fix error code in use_gss_proxy()
Message-ID: <20130511184335.GD15765@fieldses.org>
References: <20130511161349.GA20451@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130511161349.GA20451@elgon.mountain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 11, 2013 at 07:13:49PM +0300, Dan Carpenter wrote:
> This should return zero on success and -EBUSY on error so the type
> needs to be int instead of bool.

Oops, you're right--thanks.  Applying.--b.

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 871c73c..2c6a1ec 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1287,7 +1287,7 @@ static bool use_gss_proxy(struct net *net)
>  
>  #ifdef CONFIG_PROC_FS
>  
> -static bool set_gss_proxy(struct net *net, int type)
> +static int set_gss_proxy(struct net *net, int type)
>  {
>  	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>  	int ret = 0;
