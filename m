Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49634 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751038AbdHXEfa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Aug 2017 00:35:30 -0400
Subject: Re: Do we really need d_weak_revalidate???
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name>
 <1502430944.3822.1.camel@primarydata.com>
 <1502449309.4950.2.camel@redhat.com>
 <87zib3niqn.fsf@notabene.neil.brown.name>
 <1502705432.4978.1.camel@redhat.com>
 <877ey4nsep.fsf@notabene.neil.brown.name>
 <1502883253.4847.6.camel@redhat.com>
 <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com>
 <878tihmora.fsf@notabene.neil.brown.name>
 <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
 <87h8x1l9qp.fsf@notabene.neil.brown.name>
 <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com>
 <87r2w3jdn5.fsf@notabene.neil.brown.name>
 <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com>
 <1bfd81b3-4f16-b0a7-6b51-0c0cb23ed0a0@redhat.com>
 <87lgm9k5vm.fsf@notabene.neil.brown.name>
From: Ian Kent <ikent@redhat.com>
Message-ID: <80ffdd76-f8bd-591b-e025-d8eaeed7a47b@redhat.com>
Date: Thu, 24 Aug 2017 12:35:17 +0800
MIME-Version: 1.0
In-Reply-To: <87lgm9k5vm.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24/08/17 11:21, NeilBrown wrote:
> On Wed, Aug 23 2017, Ian Kent wrote:
> 
>> On 23/08/17 10:32, Ian Kent wrote:
>>> On 23/08/17 09:06, NeilBrown wrote:
>>>> On Mon, Aug 21 2017, Ian Kent wrote:
>>>>
>>>>>>
>>>>>> A mount isn't triggered by kern_path(pathname, 0, &path).
>>>>>> That '0' would need to include one of
>>>>>>   LOOKUP_PARENT | LOOKUP_DIRECTORY |
>>>>>>   LOOKUP_OPEN | LOOKUP_CREATE | LOOKUP_AUTOMOUNT
>>>>>>
>>>>>> to trigger an automount (otherwise you just get -EISDIR).
>>>>>
>>>>> It's perfectly sensible to think that but there is a case where a
>>>>> a mount is triggered when using kern_path().
>>>>>
>>>>> The EISDIR return occurs for positive dentrys, negative dentrys
>>>>> will still trigger an automount (which is autofs specific,
>>>>> indirect mount map using nobrowse option, the install default).
>>>>
>>>> Ok, I understand this better now.  This difference between direct and
>>>> indirect mounts is slightly awkward. It is visible from user-space, but
>>>> not elegant to document.
>>>> When you use O_PATH to open a direct automount that has not already been
>>>> triggered, the open returns the underlying directory (and fstatfs
>>>> confirms that it is AUTOFS_SUPER_MAGIC).  When you use O_PATH on
>>>> an indirect automount, it *will* trigger the automount when "nobrowse" is
>>>> in effect, but it won't when "browse" is in effect.
>>>
>>> That inconsistency has bothered me for quite a while now.
>>>
>>> It was carried over from the autofs module behavior when automounting
>>> support was added to the VFS. What's worse is it prevents the use of
>>> the AT_NO_AUTOMOUNT flag from working properly with fstatat(2) and with
>>> statx().
>>>
>>> There is some risk in changing that so it does work but it really does
>>> need to work to enable userspace to not trigger an automount by using
>>> this flag.
>>>
>>> So that's (hopefully) going to change soonish, see:
>>> http://ozlabs.org/~akpm/mmotm/broken-out/autofs-fix-at_no_automount-not-being-honored.patch
>>>
>>> The result should be that stat family calls don't trigger automounts except
>>> for fstatat(2) and statx() which will require the AT_NO_AUTOMOUNT flag.
>>>
>>>>
>>>> So we cannot just say "O_PATH doesn't trigger automounts", which is
>>>> essentially what I said in
>>>>
>>>> https://git.kernel.org/pub/scm/docs/man-pages/man-pages.git/commit/?id=97a45d02e6671482e8b2cdcce3951930bf6bdb94
>>>>
>>>> It might be possible to modify automount so that it was more consistent
>>>> - i.e. if the point is triggered by a mkdir has been done, just to the
>>>> mkdir.  If it is triggered after a mkdir has been done, do the mount.  I
>>>> guess that might be racy, and in any case is hard to justify.
>>>>
>>>> Maybe I should change it to be about "direct automounts", and add a note
>>>> that indirect automounts aren't so predictable.
>>>
>>> Right and the semantics should be much more consistent in the near future.
>>> I hope (and expect) this semantic change won't cause problems.
>>>
>>>>
>>>> But back to my original issue of wanting to discard
>>>> kern_path_mountpoint, what would you think of the following approach -
>>>> slight revised from before.
>>>>
>>>> Thanks,
>>>> NeilBrown
>>>>
>>>> diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
>>>> index beef981aa54f..7663ea82e68d 100644
>>>> --- a/fs/autofs4/autofs_i.h
>>>> +++ b/fs/autofs4/autofs_i.h
>>>> @@ -135,10 +135,13 @@ static inline struct autofs_info *autofs4_dentry_ino(struct dentry *dentry)
>>>>  /* autofs4_oz_mode(): do we see the man behind the curtain?  (The
>>>>   * processes which do manipulations for us in user space sees the raw
>>>>   * filesystem without "magic".)
>>>> + * A process performing certain ioctls can get temporary oz status.
>>>>   */
>>>> +extern struct task_struct *autofs_tmp_oz;
>>>>  static inline int autofs4_oz_mode(struct autofs_sb_info *sbi)
>>>>  {
>>>> -	return sbi->catatonic || task_pgrp(current) == sbi->oz_pgrp;
>>>> +	return sbi->catatonic || task_pgrp(current) == sbi->oz_pgrp ||
>>>> +		autofs_tmp_oz == current;
>>>>  }
>>>>  
>>>>  struct inode *autofs4_get_inode(struct super_block *, umode_t);
>>>> diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
>>>> index dd9f1bebb5a3..d76401669a20 100644
>>>> --- a/fs/autofs4/dev-ioctl.c
>>>> +++ b/fs/autofs4/dev-ioctl.c
>>>> @@ -200,6 +200,20 @@ static int autofs_dev_ioctl_protosubver(struct file *fp,
>>>>  	return 0;
>>>>  }
>>>>  
>>>> +struct task_struct *autofs_tmp_oz;
>>>> +int kern_path_oz(const char *pathname, int flags, struct path *path)
>>>> +{
>>>> +	static DEFINE_MUTEX(autofs_oz);
>>>> +	int err;
>>>> +
>>>> +	mutex_lock(&autofs_oz);
>>>> +	autofs_tmp_oz = current;
>>>> +	err = kern_path(pathname, flags, path);
>>>> +	autofs_tmp_oz = NULL;
>>>> +	mutex_unlock(&autofs_oz);
>>>> +	return err;
>>>> +}
>>>> +
>>>
>>> It's simple enough but does look like it will attract criticism as being
>>> a hack!
>>>
>>> The kern_path_locked() function is very similar to what was originally
>>> done, along with code to look down the mount stack (rather than up the
>>> way it does now) to get the mount point. In this case, to be valid the
>>> dentry can't be a symlink so that fits kern_path_locked() too.
>>
>> Oh wait, that __lookup_hash() tries too hard to resolve the dentry,
>> that won't quite work, and maybe d_lookup() can't be used safely in
>> this context either ....
>>
> 
> Why do you think that __look_hash() tries too hard?
> It does call into the filesystem ->lookup() if the name isn't in the
> cache, which probably isn't strictly needed, but that isn't harmful and
> the current code does that.

Only that the execution path can encounter the negative dentry case in
follow_automount().

Also, my saying that the dentry can't be a symlink is wrong.

For the covered fd case it's reasonable but for the mount point check
ioctl the path could be anything, eg. a symlink to an automount dentry,
and I want that ioctl to be callable by anyone.

> 
> Some the following seems sensible to me (though I haven't tested it).
> 
> Thanks,
> NeilBrown
> 
> 
> diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
> index dd9f1bebb5a3..859c198d0163 100644
> --- a/fs/autofs4/dev-ioctl.c
> +++ b/fs/autofs4/dev-ioctl.c
> @@ -208,12 +208,16 @@ static int find_autofs_mount(const char *pathname,
>  {
>  	struct path path;
>  	int err;
> +	struct dentry *de, *parent;
> +
> +	de = kern_path_locked(pathname, &path);
> +	if (IS_ERR(de))
> +		return PTR_ERR(de);
> +	parent = path.dentry;
> +	path.dentry = de;
>  
> -	err = kern_path_mountpoint(AT_FDCWD, pathname, &path, 0);
> -	if (err)
> -		return err;
>  	err = -ENOENT;
> -	while (path.dentry == path.mnt->mnt_root) {
> +	do {
>  		if (path.dentry->d_sb->s_magic == AUTOFS_SUPER_MAGIC) {
>  			if (test(&path, data)) {
>  				path_get(&path);
> @@ -222,10 +226,11 @@ static int find_autofs_mount(const char *pathname,
>  				break;
>  			}
>  		}
> -		if (!follow_up(&path))
> -			break;
> -	}
> +	} while (follow_down_one(&path));
> +
>  	path_put(&path);
> +	inode_unlock(d_inode(parent));
> +	dput(parent);
>  	return err;
>  }
>  
> 

