Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42076 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbbHSDzH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Aug 2015 23:55:07 -0400
Date: Wed, 19 Aug 2015 13:54:56 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 6/6 v9] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150819135456.0294a334@noble>
In-Reply-To: <55D2DD8F.6070501@gmail.com>
References: <55D2DBF6.3010406@gmail.com>
	<55D2DD8F.6070501@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 18 Aug 2015 15:23:59 +0800 Kinglong Mee <kinglongmee@gmail.com>
wrote:

>  static void expkey_put(struct kref *ref)
>  {
>  	struct svc_expkey *key = container_of(ref, struct svc_expkey, h.ref);
>  
>  	if (test_bit(CACHE_VALID, &key->h.flags) &&
> -	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
> -		path_put(&key->ek_path);
> -	auth_domain_put(key->ek_client);
> -	kfree(key);
> +	    !test_bit(CACHE_NEGATIVE, &key->h.flags)) {
> +		rcu_read_lock();
> +		if (path_put_unpin(&key->ek_path, &key->ek_pin))
> +			return ;
> +	}

That rcu_read_lock() is unbalanced and not needed.

Comment applies below in svc_export code too.


> +static void expkey_pin_kill(struct fs_pin *pin)
> +{
> +	struct svc_expkey *key = container_of(pin, struct svc_expkey, ek_pin);
> +	cache_delete_entry(key->cd, &key->h);
> +	/* Must call pin_kill to wait the last reference be put */
> +	pin_kill(&key->ek_pin);
> +	expkey_destroy(key);
>  }

This, on the other hand, needs rcu_read_lock().  pin_kill() expected
rcu to be readlocked, and will drop the lock.

Same comment for svc_export code.


Did you test with lockdep enabled?  That should have caught these
issues.

Otherwise it looks good.

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown
