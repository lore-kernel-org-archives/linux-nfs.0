Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:48725 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaCFPau (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 10:30:50 -0500
Date: Thu, 6 Mar 2014 09:30:42 -0600
From: Serge Hallyn <serge.hallyn@ubuntu.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: James Morris <james.l.morris@oracle.com>,
        Serge Hallyn <serge.hallyn@canonical.com>,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] security: have cap_dentry_init_security return error
Message-ID: <20140306153042.GA14791@sergelap>
References: <1394041657-7114-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1394041657-7114-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Jeff Layton (jlayton@redhat.com):
> Currently, cap_dentry_init_security returns 0 without actually
> initializing the security label. This confuses its only caller
> (nfs4_label_init_security) which expects an error in that situation, and
> causes it to end up sending out junk onto the wire instead of simply
> suppressing the label in the attributes sent.
> 
> When CONFIG_SECURITY is disabled, security_dentry_init_security returns
> -EOPNOTSUPP. Have cap_dentry_init_security do the same.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>

> ---
>  security/capability.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/security/capability.c b/security/capability.c
> index 8b4f24ae4338..9323bbeba296 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -116,7 +116,7 @@ static int cap_dentry_init_security(struct dentry *dentry, int mode,
>  					struct qstr *name, void **ctx,
>  					u32 *ctxlen)
>  {
> -	return 0;
> +	return -EOPNOTSUPP;
>  }
>  
>  static int cap_inode_alloc_security(struct inode *inode)
> -- 
> 1.8.5.3
> 
