Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35203 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822AbaCKVbp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2014 17:31:45 -0400
Received: by mail-ie0-f181.google.com with SMTP id tp5so9094938ieb.26
        for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2014 14:31:45 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] nfs: Don't assume we have a security structure
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1394572274-16474-1-git-send-email-Anna.Schumaker@netapp.com>
Date: Tue, 11 Mar 2014 17:31:43 -0400
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <8722C868-F019-428F-8223-0A9759B9202B@primarydata.com>
References: <1394572274-16474-1-git-send-email-Anna.Schumaker@netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Could it be bad to do this when selinux is enabled?  Could you do something based on selinux_is_enabled()?

-dros

On Mar 11, 2014, at 5:11 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> If the i_security field isn't set then security_dentry_init_security()
> won't initialize some of the values used by the security label.  This
> causes my client to hit a BUG_ON() while encoding a label of size
> -2128927414.
> 
> I hit this bug while testing on a client without SELinux installed.
> 
> Signed-off-by: Anna Schumaker <anna.schumaker@netapp.com>
> ---
> fs/nfs/nfs4proc.c | 3 +++
> 1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b8cd560..994ccc2 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -105,6 +105,9 @@ nfs4_label_init_security(struct inode *dir, struct dentry *dentry,
> 	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL) == 0)
> 		return NULL;
> 
> +	if (!dir->i_security)
> +		return NULL;
> +
> 	err = security_dentry_init_security(dentry, sattr->ia_mode,
> 				&dentry->d_name, (void **)&label->label, &label->len);
> 	if (err == 0)
> -- 
> 1.9.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

