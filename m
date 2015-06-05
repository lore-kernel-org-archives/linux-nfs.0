Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from emvm-gh1-uea09.nsa.gov ([63.239.67.10]:63816 "EHLO
	emvm-gh1-uea09.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596AbbFEMky (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2015 08:40:54 -0400
Message-ID: <5571951E.4010902@tycho.nsa.gov>
Date: Fri, 05 Jun 2015 08:25:02 -0400
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, Paul Moore <paul@paul-moore.com>,
        Eric Paris <eparis@parisplace.org>
CC: Richard Chan <rc556677@outlook.com>, linux-nfs@vger.kernel.org,
        David Quigley <dpquigl@davequigley.com>, selinux@tycho.nsa.gov
Subject: Re: [PATCH] selinux: fix setting of security labels on NFS
References: <20150604195725.GC5209@fieldses.org>
In-Reply-To: <20150604195725.GC5209@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/04/2015 03:57 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Before calling into the filesystem, vfs_setxattr calls
> security_inode_setxattr, which ends up calling selinux_inode_setxattr in
> our case.  That returns -EOPNOTSUPP whenever SBLABEL_MNT is not set.
> SBLABEL_MNT was supposed to be set by sb_finish_set_opts, which sets it
> only if selinux_is_sblabel_mnt returns true.
> 
> The selinux_is_sblabel_mnt logic was broken by eadcabc697e9 "SELinux: do
> all flags twiddling in one place", which didn't take into the account
> the SECURITY_FS_USE_NATIVE behavior that had been introduced for nfs
> with eb9ae686507b "SELinux: Add new labeling type native labels".
> 
> This caused setxattr's of security labels over NFSv4.2 to fail.
> 
> Cc: stable@kernel.org
> Cc: Eric Paris <eparis@redhat.com>
> Cc: David Quigley <dpquigl@davequigley.com>
> Reported-by: Richard Chan <rc556677@outlook.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>

> ---
>  security/selinux/hooks.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index e8a060bd9677..171fb30e4b99 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -403,6 +403,7 @@ static int selinux_is_sblabel_mnt(struct super_block *sb)
>  	return sbsec->behavior == SECURITY_FS_USE_XATTR ||
>  		sbsec->behavior == SECURITY_FS_USE_TRANS ||
>  		sbsec->behavior == SECURITY_FS_USE_TASK ||
> +		sbsec->behavior == SECURITY_FS_USE_NATIVE ||
>  		/* Special handling. Genfs but also in-core setxattr handler */
>  		!strcmp(sb->s_type->name, "sysfs") ||
>  		!strcmp(sb->s_type->name, "pstore") ||
> 

