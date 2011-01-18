Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39674 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab1ARWDB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 17:03:01 -0500
In-Reply-To: <20110118204509.GA10903@fieldses.org>
References: <20101129193248.GA9897@fieldses.org>
	<AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
	<20101203223326.GB28763@fieldses.org>
	<20101213051944.GA8688@amd>
	<20101214220102.GM24828@fieldses.org>
	<20101217180022.GB11515@fieldses.org>
	<20101218020118.GA3179@amd>
	<20101218161609.GA22150@fieldses.org>
	<AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
	<20101227234641.GA22248@fieldses.org>
	<20110118204509.GA10903@fieldses.org>
Date: Wed, 19 Jan 2011 09:02:59 +1100
Message-ID: <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed dentries
From: Nick Piggin <npiggin@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@kernel.dk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 19, 2011 at 7:45 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> Nick Piggin suggested fixing this by allowing d_obtain_alias to return
> the unhashed dentry that is referenced by the filp, instead of making it
> create a new dentry.
>
> Leave __d_find_alias() alone to avoid changing behavior of other
> callers.
>
> Also nfsd doesn't need all the checks of __d_find_alias(); any dentry,
> hashed or unhashed, disconnected or not, should work.
>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/dcache.c |   26 ++++++++++++++++++++++++--
>  1 files changed, 24 insertions(+), 2 deletions(-)
>
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 9f493ee..2849258 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1521,6 +1521,28 @@ struct dentry * d_alloc_root(struct inode * root_inode)
>  }
>  EXPORT_SYMBOL(d_alloc_root);
>
> +static struct dentry * __d_find_any_alias(struct inode *inode)
> +{
> +       struct dentry *alias;
> +
> +       if (list_empty(&inode->i_dentry))
> +               return NULL;
> +       alias = list_first_entry(&inode->i_dentry, struct dentry, d_alias);
> +       __dget(alias);
> +       return alias;
> +}
> +
> +static struct dentry * d_find_any_alias(struct inode *inode)
> +{
> +       struct dentry *de;
> +
> +       spin_lock(&inode->i_lock);

Yes, i_dentry/d_alias is protected by i_lock, so it looks fine.
