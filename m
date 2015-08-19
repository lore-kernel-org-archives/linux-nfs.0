Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49671 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbbHSEvD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 00:51:03 -0400
Date: Wed, 19 Aug 2015 05:50:59 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 6/6 v9] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150819045059.GB18890@ZenIV.linux.org.uk>
References: <55D2DBF6.3010406@gmail.com>
 <55D2DD8F.6070501@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55D2DD8F.6070501@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 18, 2015 at 03:23:59PM +0800, Kinglong Mee wrote:
> @@ -181,7 +191,11 @@ static int expkey_show(struct seq_file *m,
>  	if (test_bit(CACHE_VALID, &h->flags) && 
>  	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
>  		seq_printf(m, " ");
> -		seq_path(m, &ek->ek_path, "\\ \t\n");
> +		if (legitimize_mntget(ek->ek_path.mnt)) {
> +			seq_path(m, &ek->ek_path, "\\ \t\n");
> +			mntput(ek->ek_path.mnt);
> +		} else
> +			seq_printf(m, "Dir-unmounting");

IDGI...  What locking environment do you have here?  Note that use
of mnt_add_count(mnt, -1) in MNT_SYNC_UMOUNT case in __legitimize_mnt()
is OK only because we
	a) are under rcu_read_lock() and
	b) have synchronize_rcu() in namespace_unlock().

You don't seem to be under rcu_read_lock() here, so what's to stop that
from racing with the final mntput()?  IOW, suppose that on the first
pass through legitimize_mntget() you read mount_lock, bump refcount,
recheck the lock and notice that it has been touched.  You proceed to
decrement refcount.  Fine, except that what would've been the final
mntput() has just noticed that refcount hadn't reached 0 and buggered
off.  And in the meanwhile, MNT_UMOUNT had been set.  Now you decrement
the refcount to zero, notice that MNT_UMOUNT and go away.  Have a nice
leak...

The only reason why we are able to get away with mnt_add_count(mnt, -1) in
that specific case in legitimize_mnt() is that MNT_SYNC_UMOUNT must have
been set after we'd got rcu_read_lock() (otherwise we would've either hit
a mismatch on mount_lock before incrementing refcount or wouldn't have
run into that vfsmount at all) and thus we _know_ that the process that
has set MNT_SYNC_UMOUNT couldn't have passed through synchronize_rcu()
in namespace_unlock(), so it couldn't reach mntput_no_expire() until our
caller does rcu_read_unlock() and we are free to decrement the refcount and
leave - we won't be dropping the last reference here.

Without MNT_SYNC_UMOUNT the callers of __legitimize_mnt() must use mntput()
to drop the mistakenly acquired reference.  Exactly because they can't
rely on that syncronize_rcu() delaying the final mntput().

> @@ -664,7 +696,12 @@ static int svc_export_show(struct seq_file *m,
>  		return 0;
>  	}
>  	exp = container_of(h, struct svc_export, h);
> -	seq_path(m, &exp->ex_path, " \t\n\\");
> +	if (legitimize_mntget(exp->ex_path.mnt)) {
> +		seq_path(m, &exp->ex_path, " \t\n\\");
> +		mntput(exp->ex_path.mnt);
> +	} else
> +		seq_printf(m, "Dir-unmounting");

Ditto.  And grabbing/dropping references here seems to be an overkill...

> @@ -819,6 +867,12 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
>  	err = cache_check(cd, &ek->h, reqp);
>  	if (err)
>  		return ERR_PTR(err);
> +
> +	if (!legitimize_mntget(ek->ek_path.mnt)) {
> +		cache_put(&ek->h, ek->cd);
> +		return ERR_PTR(-ENOENT);
> +	}

Ditto.

> @@ -842,6 +896,8 @@ exp_get_by_name(struct cache_detail *cd, struct auth_domain *clp,
>  	err = cache_check(cd, &exp->h, reqp);
>  	if (err)
>  		return ERR_PTR(err);
> +
> +	mntget(exp->ex_path.mnt);

What's to make that mntget() legitimate?

>  static inline struct svc_export *exp_get(struct svc_export *exp)
>  {
>  	cache_get(&exp->h);
> +	mntget(exp->ex_path.mnt);

Ditto.
