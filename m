Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea01.nsa.gov ([63.239.65.39]:48214 "EHLO
	msux-gh1-uea01.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755840Ab0GHMvv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jul 2010 08:51:51 -0400
Subject: Re: [PATCH 01/10] Security: Add hook to calculate context based on
 a negative dentry.
From: Stephen Smalley <sds@tycho.nsa.gov>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        bfields@fieldses.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org
In-Reply-To: <1278513086-23964-2-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-2-git-send-email-dpquigl@tycho.nsa.gov>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 08 Jul 2010 08:51:33 -0400
Message-ID: <1278593493.14920.12.camel@moss-pluto.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-07-07 at 10:31 -0400, David P. Quigley wrote:
> There is a time where we need to calculate a context without the
> inode having been created yet. To do this we take the negative dentry and
> calculate a context based on the process and the parent directory contexts.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
> ---
>  include/linux/security.h |   22 ++++++++++++++++++++++
>  security/capability.c    |    6 ++++++
>  security/security.c      |    7 +++++++
>  security/selinux/hooks.c |   32 ++++++++++++++++++++++++++++++++
>  4 files changed, 67 insertions(+), 0 deletions(-)
> 

> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 5feecb4..435c51f 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2577,6 +2577,37 @@ static void selinux_inode_free_security(struct inode *inode)
>  	inode_free_security(inode);
>  }
>  
> +static int selinux_dentry_init_security(struct dentry *dentry, int mode, void **ctx, u32 *ctxlen)
> +{
> +	struct cred *cred = current_cred();
> +	struct task_security_struct *tsec;
> +	struct inode_security_struct *dsec;
> +	struct superblock_security_struct *sbsec;
> +	struct inode *dir = dentry->d_parent->d_inode;

Locking?

> +	u32 newsid;
> +	int rc;
> +
> +	tsec = cred->security;
> +	dsec = dir->i_security;
> +	sbsec = dir->i_sb->s_security;
> +
> +	if (tsec->create_sid && sbsec->behavior != SECURITY_FS_USE_MNTPOINT) {

The logic in selinux_inode_init_security() has changed to use
(sbsec->flags & SE_SBLABELSUPP) instead.  Possibly you should factor the
common code into a helper.

> +		newsid = tsec->create_sid;
> +	} else {
> +		rc = security_transition_sid(tsec->sid, dsec->sid,
> +					     inode_mode_to_security_class(mode),
> +					     &newsid);
> +		if (rc) {
> +			printk(KERN_WARNING "%s:  "
> +			       "security_transition_sid failed, rc=%d\n",
> +			       __FUNCTION__, -rc);
> +			return rc;
> +		}
> +	}
> +
> +	return security_sid_to_context(newsid, (char **)ctx, ctxlen);
> +}
> +
>  static int selinux_inode_init_security(struct inode *inode, struct inode *dir,
>  				       char **name, void **value,
>  				       size_t *len)
> @@ -5484,6 +5515,7 @@ static struct security_operations selinux_ops = {
>  	.sb_clone_mnt_opts =		selinux_sb_clone_mnt_opts,
>  	.sb_parse_opts_str = 		selinux_parse_opts_str,
>  
> +	.dentry_init_security =		selinux_dentry_init_security,
>  
>  	.inode_alloc_security =		selinux_inode_alloc_security,
>  	.inode_free_security =		selinux_inode_free_security,

-- 
Stephen Smalley
National Security Agency

