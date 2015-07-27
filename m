Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41660 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755058AbbG0Cvc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Jul 2015 22:51:32 -0400
Date: Mon, 27 Jul 2015 12:51:21 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150727125121.23655367@noble>
In-Reply-To: <55B59764.1020506@gmail.com>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150713142059.493a790e@noble>
	<20150713044553.GN17109@ZenIV.linux.org.uk>
	<20150724120515.023322d4@noble>
	<55B59764.1020506@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 27 Jul 2015 10:28:52 +0800 Kinglong Mee <kinglongmee@gmail.com>
wrote:

> On 7/24/2015 10:05, NeilBrown wrote:
> > On Mon, 13 Jul 2015 05:45:53 +0100 Al Viro <viro@ZenIV.linux.org.uk>
> > wrote:
> > 
> >> On Mon, Jul 13, 2015 at 02:20:59PM +1000, NeilBrown wrote:
> >>
> >>> Actually, with that change to pin_kill, this side of things becomes
> >>> really easy.
> >>> All expXXX_pin_kill needs to do is call your new cache_delete_entry.
> >>> If that doesn't cause the entry to be put, then something else has a
> >>> temporary reference which will be put soon.  In any case, pin_kill()
> >>> will wait long enough, but not indefinitely.
> >>> No need for kref_get_unless_zero() or any of that.
> >>
> >> No.  You are seriously misunderstanding what ->kill() is for and what the
> >> existing instances are doing.  Again, there is no promise whatsoever that
> >> the object containing fs_pin instance will *survive* past ->kill().
> >> At all.
> >>
> >> RTFS, please.  What is sorely missing in this recurring patchset is a clear
> >> description of lifetime rules and ordering (who waits for whom and how long).
> >> For all the objects involved.
> > 
> > Good point.  Let me try.
> > 
> > Entries in the sunrpc 'cache' each contain some 'key' fields and some
> > 'content' fields.
> > 
> > The key fields are set by the .init() method when the entry is
> > created, which can happen in a call to sunrpc_cache_lookup() or to
> > sunrpc_cache_update().
> > 
> > The content fields are set by the .update() method when a value is
> > provided for the cache entry.  This happens in sunrpc_cache_update();
> > 
> > A cache entry can be not-valid, negative, or valid.
> > It starts non-valid when sunrpc_cache_lookup() fails to find the search
> > key and so creates a new entry (and sets up the key with .init).
> > It then transitions to either negative or valid.
> > This can happen through sunrpc_cache_update() or through an error when
> > instigating an up-call, in which case it goes to negative.
> > Once it is negative or valid, it stays that way until it is released.
> > If sunrpc_cache_update is called on an entry that is not not-valid,
> > then a new entry is created and the old one is marked as expired.
> > A cache search will find the new one before the old.
> > 
> > The vfsmount object is involved in two separate caches.
> > It is part of the content of svc_expkey and part of the key of
> > svc_export.
> > 
> > An svc_expkey entry is only ever held transiently.  It is held while an
> > update is being processed, and it is held briefly while mapping a
> > filehandle to a mnt+dentry.
> > Firstly part of the filehandle is used to acccess the svc_expkey cache
> > to get the vfsmnt.  Then that vfsmnt plus the client identification is
> > looked up in the svc_export cache to find the export options.  Then the
> > svc_expkey cache entry is released.
> > 
> > So it is only held during a lookup of another cache.  This can take an
> > arbitrarily long time as the lookup can go to rpc.mountd in user-space.
> > 
> > 
> > The svc_export cache entry can be held for the duration of a single NFS
> > request.  It is stored in the 'struct svc_fh' file handle structure
> > which is release at the end of handling the request.
> > 
> > The vfsmnt and dentry are only "used" to validate the filehandle and
> > then while that filehandle is still active.
> > 
> > 
> > To avoid having unmount hang while nfsd is performing an upcall to
> > mountd, we need to legitimize the vfsmnt in the svc_expkey.  If that
> > fails, exp_find_key() can fail and we would never perform the lookup on
> > svc_export.
> > 
> > If it succeeds, then the legitimacy can be handed over to the svc_export
> > cache entry, which could then continue to own it, or could hand it on
> > to the svc_fh.
> > 
> > The latter is *probably* cleanest.
> > i.e. an svc_fh should always own a reference to exp->ex_path.mnt, and
> > fh_put must put it.
> 
> I don't agree adding new argument (eg, fh_vfsmnt) in svc_fh.

I wasn't suggesting that a new field be added to svc_fh.
Just that if svc_fh->fh_export was not NULL, then the svc_fh "owned" a
reference to svc_fh->fh_export->ex_path.mnt which it had to mnt_put()
when it released ->fh_export.

So fh_put would need to change, but not much else.

It isn't the only way to handle that references - it just seemed the
neatest as I was writing the description.  Something else might work
better in the code.

> 
> With it, should nfsd using fh_vfsmnt always, never using exp->ex_path.mnt
> outside of export.c/export.h ?
> 
> If choose fh_vfsmnt, so many codes need be updated, especially functions.
> If exp->ex_path.mnt, the new argument fh_vfsmnt seems redundant.
> 
> Thanks for your work.
> 
> It reminders a new method,
> 
> 1. There are only one outlet from each cache, exp_find_key() for expkey, 
>    exp_get_by_name() for export.
> 2. Any fsid to export or filehandle to export will call the function.
> 3. exp_get()/exp_put() increase/decrease the reference of export.
> 
> Like the fh_vfsmnt (not same), call legitimize_mntget() in the only
> outlet function exp_find_key()/exp_get_by_name(), if fail return STALE,
> otherwise, any valid expkey/export from the cache is validated (Have
> get the reference of vfsmnt).
> 
> Add mntget() in exp_get() and mntput() in exp_put(), because the export
> passed to exp_get/exp_put are returned from exp_find_key/exp_get_by_name.
> 
> > 
> > exp_find_key needs to legitimize ek->ek_path.mnt, so a successful
> > return from exp_find implies an active refernece to ->ex_path.mnt.
> > If exp_find fails, it needs to mnt_put(ek->ek_path.mnt).
> 
> Yes, it's great.
> 
> > All callers of exp_find need to mnt_put(exp->ex_path.mnt) when they
> > decide not to use the exp, and must otherwise store it in an svc_fh.
> > 
> > With this, pin_kill() should only need to wait for  exp_find_key() to
> > discover that it cannot legitimize the mount, or for expkey_path() to
> > replace the key via sunrpc_cache_update(), or maybe for cache_clean()
> > to discard an old entry.
> > 
> > Hopefully that makes it all clear.
> 
> Yes, thanks again.
> 
> With my method, for expkey cache,
> 1. At first, a fsid is passed to exp_find_key, and lookup a cache
>    in svc_expkey_lookup, if success, ekey->ek_path is pined to mount.
> 2. Then call legitimize_mntget getting a reference of vfsmnt 
>    before return from exp_find_key.
> 3. Any calling exp_find_key with valid cache must put the vfsmnt.
> 
> for export cache,
> 1. At first, a path (returned from exp_find_key) with validate vfsmnt
>    is passed to exp_get_by_name, if success, exp->ex_path is pined to mount.
> 2. Then call legitimize_mntget getting a reference of vfsmnt 
>    before return from exp_get_by_name.

I don't see any point in calling legitimise_mntget here.  exp_find_key
already did the 'legitimize' bit so there is no need to do it again.

> 3. Any calling exp_get_by_name with valid cache must put the vfsmnt
>    by exp_put();
> 4. Any using the exp returned from exp_get_by_name must call exp_get(),
>    will increase the reference of vfsmnt.
> 
> So,
> a. After getting the reference in 2, any umount of filesystem will get -EBUSY.
> b. After put all reference after 4, or before get the reference in 2, 
>    any umount of filesystem will call pin_kill, and delete the cache directly,
>    also unpin the vfsmount.
> c. Between 1 and 2, have get the reference of exp/key cache, with invalidate vfsmnt.
>    As you said, umount of filesystem only wait exp_find_key/exp_get_by_name
>    put the reference of cache when legitimize_mntget fail.
> 
> A new update of this patch site will be push later.

I look forward to it.  Thanks,

NeilBrown

