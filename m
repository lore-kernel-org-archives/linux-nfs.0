Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sonic301-28.consmr.mail.gq1.yahoo.com ([98.137.64.154]:44520
        "EHLO sonic301-28.consmr.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751086AbeFDVBg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 17:01:36 -0400
Subject: Re: [PATCH] Smack: Fix memory leak in smack_inode_getsecctx
To: "linux-security-module@vger.kernel.org"
        <linux-security-module@vger.kernel.org>, Tejun Heo <tj@kernel.org>
Cc: chandan.vn@samsung.com,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        CPGS <cpgs@samsung.com>,
        Sireesha Talluri <sireesha.t@samsung.com>,
        Chris Wright <chrisw@sous-sol.org>
References: <02d9878e-65bf-5de8-9658-cf0f692f358c@schaufler-ca.com>
 <1ced6bce-92cc-7e0c-fab4-0aaa3d03b82f@schaufler-ca.com>
 <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
 <20180531153943.GR1351649@devbig577.frc2.facebook.com>
 <4f00f9ae-3302-83b9-c083-d21ade380eb2@schaufler-ca.com>
 <20180531161107.GV1351649@devbig577.frc2.facebook.com>
 <20180601085609epcms5p5fefac0156a4816e9e48751211ab595ee@epcms5p5>
 <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcms5p7>
 <20180601162913epcms5p7737f5b4376d8865af1eae119aa866550@epcms5p7>
 <5b0b157a-0e8c-d8f5-901e-836d545a8e4c@schaufler-ca.com>
 <fa278910-5c99-11dc-c9cb-b88a97592e53@schaufler-ca.com>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <b6cc4bd5-8d79-bbc2-373f-ea0bf0806884@schaufler-ca.com>
Date: Mon, 4 Jun 2018 14:01:34 -0700
MIME-Version: 1.0
In-Reply-To: <fa278910-5c99-11dc-c9cb-b88a97592e53@schaufler-ca.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/1/2018 10:45 AM, Casey Schaufler wrote:
> Fix memory leak in smack_inode_getsecctx
>
> The implementation of smack_inode_getsecctx() made
> incorrect assumptions about how Smack presents a security
> context. Smack does not need to allocate memory to support
> security contexts, so "releasing" a Smack context is a no-op.
> The code made an unnecessary copy and returned that as a
> context, which was never freed. The revised implementation
> returns the context correctly.
>
> Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>

Tejun, does this pass your tests?

> ---
>  security/smack/smack_lsm.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
>
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 0b414836bebd..5e3beae334a8 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -1545,9 +1545,9 @@ static int smack_inode_listsecurity(struct inode *inode, char *buffer,
>   */
>  static void smack_inode_getsecid(struct inode *inode, u32 *secid)
>  {
> -	struct inode_smack *isp = inode->i_security;
> +	struct smack_known *skp = smk_of_inode(inode);
>  
> -	*secid = isp->smk_inode->smk_secid;
> +	*secid = skp->smk_secid;
>  }
>  
>  /*
> @@ -4538,12 +4538,10 @@ static int smack_inode_setsecctx(struct dentry *dentry, void *ctx, u32 ctxlen)
>  
>  static int smack_inode_getsecctx(struct inode *inode, void **ctx, u32 *ctxlen)
>  {
> -	int len = 0;
> -	len = smack_inode_getsecurity(inode, XATTR_SMACK_SUFFIX, ctx, true);
> +	struct smack_known *skp = smk_of_inode(inode);
>  
> -	if (len < 0)
> -		return len;
> -	*ctxlen = len;
> +	*ctx = skp->smk_known;
> +	*ctxlen = strlen(skp->smk_known);
>  	return 0;
>  }
>  
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

