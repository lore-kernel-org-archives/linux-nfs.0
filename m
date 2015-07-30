Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33568 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbG3NbV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:31:21 -0400
Message-ID: <55BA2713.6090409@gmail.com>
Date: Thu, 30 Jul 2015 21:30:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 9/9 v8] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
References: <55B5A012.1030006@gmail.com>	<55B5A186.7040004@gmail.com> <20150729135616.7eaffb6c@noble>
In-Reply-To: <20150729135616.7eaffb6c@noble>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/29/2015 11:56, NeilBrown wrote:
> On Mon, 27 Jul 2015 11:12:06 +0800 Kinglong Mee <kinglongmee@gmail.com>
> wrote:
> 
>> If there are some mount points(not exported for nfs) under pseudo root,
>> after client's operation of those entry under the root,  anyone *can't*
>> unmount those mount points until export cache expired.
>>
... snip...
>>  
>>  static void expkey_request(struct cache_detail *cd,
>> @@ -83,7 +91,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
>>  		return -EINVAL;
>>  	mesg[mlen-1] = 0;
>>  
>> -	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
>> +	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
> 
> Why this change?  There are certainly times when kzmalloc is
> appropriate but I don't see that this is one of them, or that the
> change has anything to do with the rest of the patch.

It is for [1/9] at first, without zalloc of memory, the fs_pin->done
maybe a bad value for use. If applying [1/9], change to kzalloc is
not needed here.

Maybe it should be a separated patch.
I will drop the change in the next version is true.

> 
> 
>>  	err = -ENOMEM;
>>  	if (!buf)
>>  		goto out;
>> @@ -119,6 +127,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
>>  	if (key.h.expiry_time == 0)
>>  		goto out;
>>  
>> +	key.cd = cd;
>>  	key.ek_client = dom;	
>>  	key.ek_fsidtype = fsidtype;
>>  	memcpy(key.ek_fsid, buf, len);
>> @@ -181,7 +190,11 @@ static int expkey_show(struct seq_file *m,
>>  	if (test_bit(CACHE_VALID, &h->flags) && 
>>  	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
>>  		seq_printf(m, " ");
>> -		seq_path(m, &ek->ek_path, "\\ \t\n");
>> +		if (legitimize_mntget(ek->ek_path.mnt)) {
>> +			seq_path(m, &ek->ek_path, "\\ \t\n");
>> +			mntput(ek->ek_path.mnt);
>> +		} else
>> +			seq_printf(m, "Dir umounting");
> 
> This "Dir umounting" needs to parse as a single word, so having a space
> in there is bad.  Maybe "Dir-unmounting".

Thanks.

> 
> 
>>  	}
>>  	seq_printf(m, "\n");
>>  	return 0;
>> @@ -210,6 +223,26 @@ static inline void expkey_init(struct cache_head *cnew,
>>  	new->ek_fsidtype = item->ek_fsidtype;
>>  
>>  	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
>> +	new->cd = item->cd;
>> +}
>> +
>> +static void expkey_pin_kill(struct fs_pin *pin)
>> +{
>> +	struct svc_expkey *key = container_of(pin, struct svc_expkey, ek_pin);
>> +
>> +	if (!completion_done(&key->ek_done)) {
>> +		schedule_work(&key->ek_work);
>> +		wait_for_completion(&key->ek_done);
>> +	}
>> +
>> +	path_put_unpin(&key->ek_path, &key->ek_pin);
>> +	expkey_destroy(key);
>> +}
>> +
>> +static void expkey_close_work(struct work_struct *work)
>> +{
>> +	struct svc_expkey *key = container_of(work, struct svc_expkey, ek_work);
>> +	cache_delete_entry(key->cd, &key->h);
>>  }
> 
> I'm perplexed by this separate scheduled work.
> You say:
> 
>> 2. add a work_struct for pin_kill decreases the reference indirectly.
> 
> above.
> cache_delete_entry() can call cache_put() which would call expkey_put()
> which calls pin_kill(), which will block until path_put_unpin calls
> pin_remove() which of course now cannot happen.
> 
> So I can see why you have it, but I really really don't like it. :-(
> 
> I'll post a patch to make a change to fs_pin so this sort of thing
> should be much easier.

I will review your patch, and try to update the new resolve.

> 
>>  
>>  static inline void expkey_update(struct cache_head *cnew,
>> @@ -218,16 +251,19 @@ static inline void expkey_update(struct cache_head *cnew,
>>  	struct svc_expkey *new = container_of(cnew, struct svc_expkey, h);
>>  	struct svc_expkey *item = container_of(citem, struct svc_expkey, h);
>>  
>> +	init_fs_pin(&new->ek_pin, expkey_pin_kill);
>>  	new->ek_path = item->ek_path;
>> -	path_get(&item->ek_path);
>> +	path_get_pin(&new->ek_path, &new->ek_pin);
>>  }
>>  
>>  static struct cache_head *expkey_alloc(void)
>>  {
>> -	struct svc_expkey *i = kmalloc(sizeof(*i), GFP_KERNEL);
>> -	if (i)
>> +	struct svc_expkey *i = kzalloc(sizeof(*i), GFP_KERNEL);
>> +	if (i) {
>> +		INIT_WORK(&i->ek_work, expkey_close_work);
>> +		init_completion(&i->ek_done);
>>  		return &i->h;
>> -	else
>> +	} else
>>  		return NULL;
>>  }
> 
> I'm slightly less offended by this kzalloc, but I still think it needs
> to be justified if it is going to remain.
> 
> 
>>  
>> @@ -306,14 +342,21 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
>>  	fsloc->locations = NULL;
>>  }
>>  
>> -static void svc_export_put(struct kref *ref)
>> +static void svc_export_destroy(struct svc_export *exp)
>>  {
>> -	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
>> -	path_put(&exp->ex_path);
>>  	auth_domain_put(exp->ex_client);
>>  	nfsd4_fslocs_free(&exp->ex_fslocs);
>>  	kfree(exp->ex_uuid);
>> -	kfree(exp);
>> +	kfree_rcu(exp, rcu_head);
>> +}
>> +
>> +static void svc_export_put(struct kref *ref)
>> +{
>> +	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
>> +
>> +	rcu_read_lock();
>> +	complete(&exp->ex_done);
>> +	pin_kill(&exp->ex_pin);
>>  }
>>  
>>  static void svc_export_request(struct cache_detail *cd,
>> @@ -520,7 +563,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>>  		return -EINVAL;
>>  	mesg[mlen-1] = 0;
>>  
>> -	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
>> +	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
>>  	if (!buf)
>>  		return -ENOMEM;
>>  
>> @@ -636,7 +679,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>>  	if (expp == NULL)
>>  		err = -ENOMEM;
>>  	else
>> -		exp_put(expp);
>> +		cache_put(&expp->h, expp->cd);
>>  out4:
>>  	nfsd4_fslocs_free(&exp.ex_fslocs);
>>  	kfree(exp.ex_uuid);
>> @@ -664,7 +707,12 @@ static int svc_export_show(struct seq_file *m,
>>  		return 0;
>>  	}
>>  	exp = container_of(h, struct svc_export, h);
>> -	seq_path(m, &exp->ex_path, " \t\n\\");
>> +	if (legitimize_mntget(exp->ex_path.mnt)) {
>> +		seq_path(m, &exp->ex_path, " \t\n\\");
>> +		mntput(exp->ex_path.mnt);
>> +	} else
>> +		seq_printf(m, "Dir umounting");
>> +
> 
> again, "Dir-umounting" .. or even "Dir-unmounting" with the 'n'.
> 
> 
>>  	seq_putc(m, '\t');
>>  	seq_escape(m, exp->ex_client->name, " \t\n\\");
>>  	seq_putc(m, '(');
>> @@ -694,15 +742,35 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
>>  		path_equal(&orig->ex_path, &new->ex_path);
>>  }
>>  
>> +static void export_pin_kill(struct fs_pin *pin)
>> +{
>> +	struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);
>> +
>> +	if (!completion_done(&exp->ex_done)) {
>> +		schedule_work(&exp->ex_work);
>> +		wait_for_completion(&exp->ex_done);
>> +	}
>> +
>> +	path_put_unpin(&exp->ex_path, &exp->ex_pin);
>> +	svc_export_destroy(exp);
>> +}
>> +
>> +static void export_close_work(struct work_struct *work)
>> +{
>> +	struct svc_export *exp = container_of(work, struct svc_export, ex_work);
>> +	cache_delete_entry(exp->cd, &exp->h);
>> +}
>> +
>>  static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
>>  {
>>  	struct svc_export *new = container_of(cnew, struct svc_export, h);
>>  	struct svc_export *item = container_of(citem, struct svc_export, h);
>>  
>> +	init_fs_pin(&new->ex_pin, export_pin_kill);
>>  	kref_get(&item->ex_client->ref);
>>  	new->ex_client = item->ex_client;
>>  	new->ex_path = item->ex_path;
>> -	path_get(&item->ex_path);
>> +	path_get_pin(&new->ex_path, &new->ex_pin);
>>  	new->ex_fslocs.locations = NULL;
>>  	new->ex_fslocs.locations_count = 0;
>>  	new->ex_fslocs.migrated = 0;
>> @@ -740,10 +808,12 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
>>  
>>  static struct cache_head *svc_export_alloc(void)
>>  {
>> -	struct svc_export *i = kmalloc(sizeof(*i), GFP_KERNEL);
>> -	if (i)
>> +	struct svc_export *i = kzalloc(sizeof(*i), GFP_KERNEL);
>> +	if (i) {
>> +		INIT_WORK(&i->ex_work, export_close_work);
>> +		init_completion(&i->ex_done);
>>  		return &i->h;
>> -	else
>> +	} else
>>  		return NULL;
>>  }
>>  
>> @@ -798,6 +868,11 @@ svc_export_update(struct svc_export *new, struct svc_export *old)
>>  		return NULL;
>>  }
>>  
>> +static void exp_put_key(struct svc_expkey *key)
>> +{
>> +	mntput(key->ek_path.mnt);
>> +	cache_put(&key->h, key->cd);
>> +}
> 
> This is only called in one place.  Does it really help clarity to make
> it a separate function?

I will update it with your next comments about legitimize_mntget()
in exp_get_by_name().

> 
>>  
>>  static struct svc_expkey *
>>  exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
>> @@ -809,6 +884,7 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
>>  	if (!clp)
>>  		return ERR_PTR(-ENOENT);
>>  
>> +	key.cd = cd;
>>  	key.ek_client = clp;
>>  	key.ek_fsidtype = fsid_type;
>>  	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
>> @@ -819,6 +895,12 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
>>  	err = cache_check(cd, &ek->h, reqp);
>>  	if (err)
>>  		return ERR_PTR(err);
>> +
>> +	if (!legitimize_mntget(ek->ek_path.mnt)) {
>> +		cache_put(&ek->h, ek->cd);
>> +		return ERR_PTR(-ESTALE);
>> +	}
>> +
> 
> I think -ENOENT would be a better error code here.
> Just pretend that the entry doesn't exist - because in a moment it
> won't.

Yes, -ESTALE is for filehandle.
-ENOENT is better for cache entry.

> 
> 
>>  	return ek;
>>  }
>>  
>> @@ -842,6 +924,12 @@ exp_get_by_name(struct cache_detail *cd, struct auth_domain *clp,
>>  	err = cache_check(cd, &exp->h, reqp);
>>  	if (err)
>>  		return ERR_PTR(err);
>> +
>> +	if (!legitimize_mntget(exp->ex_path.mnt)) {
>> +		cache_put(&exp->h, exp->cd);
>> +		return ERR_PTR(-ESTALE);
>> +	}
>> +
>>  	return exp;
>>  }
> 
> You *really* don't need this legitimize_mntget() here, just mntget().
> You already have a legitimate reference to the mnt here.

Got it!

> 
> 
> I think this patch is mostly good - there only serious problem is the
> "Dir umounting" string that you use in place of a pathname, and which
> contains a space.
> 
> But I'd really like to get rid of the completion and work struct if I
> can...

Thanks again for your comments. I will update those patches later!

thanks,
Kinglong Mee
