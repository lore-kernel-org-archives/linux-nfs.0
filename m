Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444AbbBYDy5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Feb 2015 22:54:57 -0500
Message-ID: <1424836484.13431.36.camel@willson.usersys.redhat.com>
Subject: Re: [patch v2] sunrpc: integer underflow in rsc_parse()
From: Simo Sorce <simo@redhat.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jeff Layton <jlayton@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Wang YanQing <udknight@gmail.com>, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Date: Tue, 24 Feb 2015 22:54:44 -0500
In-Reply-To: <20150224153401.GA12218@mwanda>
References: <20150224153401.GA12218@mwanda>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-02-24 at 18:34 +0300, Dan Carpenter wrote:
> If we call groups_alloc() with invalid values then it's might lead to
> memory corruption.  For example, with a negative value then we might not
> allocate enough for sizeof(struct group_info).
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2:  In v1, I changed groups_alloc().  The other places which call
> groups_alloc() check the value before calling.  Eric wanted that, either
> have all the callers check, or all the callers rely on groups_alloc().
> In the end, Bruce Fields said adding the check here was probably
> reasonable.
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 224a82f..1095be9 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -463,6 +463,8 @@ static int rsc_parse(struct cache_detail *cd,
>  		/* number of additional gid's */
>  		if (get_int(&mesg, &N))
>  			goto out;
> +		if (N < 0 || N > NGROUPS_MAX)
> +			goto out;
>  		status = -ENOMEM;
>  		rsci.cred.cr_group_info = groups_alloc(N);
>  		if (rsci.cred.cr_group_info == NULL)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I touched this code relatively recently, and this check looks correct.
Feel free to add Reviewed-by: Simo Sorce <simo@redhat.com>

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

