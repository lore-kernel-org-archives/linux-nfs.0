Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755594Ab3HASpv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 14:45:51 -0400
Message-ID: <51FAACD9.8020205@redhat.com>
Date: Thu, 01 Aug 2013 14:45:45 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: Miklos Szeredi <miklos@szeredi.hu>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Anand Avati <avati@redhat.com>, Brian Foster <bfoster@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Alexander Viro <aviro@redhat.com>, David Howells <dhowells@redhat.com>,
        Eric Paris <eparis@redhat.com>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] [REPOST] fuse: drop dentry on failed revalidate
References: <20130725055209.GA15621@sh-el5.eng.rdu2.redhat.com> <51F13948.3050100@redhat.com> <CAJfpegtpcXz+i-3txRC_NjTsYjXP5S4oJUdGstG+-PWVzazEWQ@mail.gmail.com> <51F81465.9010402@redhat.com> <20130801163940.GA1356@tucsk.piliscsaba.szeredi.hu>
In-Reply-To: <20130801163940.GA1356@tucsk.piliscsaba.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/01/2013 12:39 PM, Miklos Szeredi wrote:
> On Tue, Jul 30, 2013 at 03:30:45PM -0400, Ric Wheeler wrote:
>> On 07/30/2013 12:16 PM, Miklos Szeredi wrote:
>>>>>    fs/fuse/dir.c | 4 ++++
>>>>>    1 file changed, 4 insertions(+)
>>>>>
>>>>> diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
>>>>> index a1d9047..83c217e 100644
>>>>> --- a/fs/fuse/dir.c
>>>>> +++ b/fs/fuse/dir.c
>>>>> @@ -226,6 +226,10 @@ static int fuse_dentry_revalidate(struct dentry
>>>>> *entry, unsigned int flags)
>>>>>                  if (!err) {
>>>>>                          struct fuse_inode *fi = get_fuse_inode(inode);
>>>>>                          if (outarg.nodeid != get_node_id(inode)) {
>>>>> +                               if (!have_submounts(entry)) {
>>>>> +                                       shrink_dcache_parent(entry);
>>>>> +                                       d_drop(entry);
>>>>> +                               }
>>> Doing d_drop() on a subtree really has problems.  Take this example:
>>>
>>> cd /mnt/foo/bar
>>> mkdir my-mount-point
>>> [->d_revalidate() drops "/mnt/foo"]
>>> mount whatever on ./my-mount-point
>>> cd /
>>>
>>> At this point that mount is not accessible in any way.  The only way
>>> to umount it is to lazy umount the parent mount.  If the parent mount
>>> was root, then that's not a practical thing to do.
>>>
>>> AFAICS nothing prevents this from happening on NFS and root privs are
>>> not required (e.g. mounting a fuse fs on an NFS home dir).
>>>
> Here's a patch that tries to address the mount issue in NFS (and in FUSE in the
> future).  I haven't yet tested it, just interested in whether the concept looks
> OK or not.
>
> Not sure if the ENOENT is the best error.  Also I have a little fear that this
> will cause a regression in some weird setup.  Possibly we should use a new
> dentry flag for unhashing the directory dentry specifically to invalidate it.
>
> Thanks,
> Miklos

Adding in the NFS list for broader review.

I thought that the issue was primarily in FUSE itself, not seen in practice in NFS?

Ric

>
>
>
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 87bdb53..5c51217 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1103,6 +1103,34 @@ rename_retry:
>   }
>   EXPORT_SYMBOL(have_submounts);
>   
> +static bool __has_unlinked_ancestor(struct dentry *dentry)
> +{
> +	struct dentry *this;
> +
> +	for (this = dentry; !IS_ROOT(this); this = this->d_parent) {
> +		if (d_unhashed(this))
> +			return true;
> +	}
> +	return false;
> +}
> +
> +/*
> + * Called by mount code to check if the mountpoint is reachable (e.g. NFS can
> + * unhash a directory dentry and then the complete subtree can become
> + * unreachable).
> + */
> +bool has_unlinked_ancestor(struct dentry *dentry)
> +{
> +	bool found;
> +
> +	/* Need exclusion wrt. have_submounts() */
> +	write_seqlock(&rename_lock);
> +	found = __has_unlinked_ancestor(dentry);
> +	write_sequnlock(&rename_lock);
> +
> +	return found;
> +}
> +
>   /*
>    * Search the dentry child list of the specified parent,
>    * and move any unused dentries to the end of the unused
> diff --git a/fs/internal.h b/fs/internal.h
> index 7c5f01c..d232355 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -126,6 +126,7 @@ extern int invalidate_inodes(struct super_block *, bool);
>    * dcache.c
>    */
>   extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
> +extern bool has_unlinked_ancestor(struct dentry *dentry);
>   
>   /*
>    * read_write.c
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 7b1ca9b..bb92a9c 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -634,6 +634,15 @@ static struct mountpoint *new_mountpoint(struct dentry *dentry)
>   	}
>   	dentry->d_flags |= DCACHE_MOUNTED;
>   	spin_unlock(&dentry->d_lock);
> +
> +	if (has_unlinked_ancestor(dentry)) {
> +		spin_lock(&dentry->d_lock);
> +		dentry->d_flags &= ~DCACHE_MOUNTED;
> +		spin_unlock(&dentry->d_lock);
> +		kfree(mp);
> +		return ERR_PTR(-ENOENT);
> +	}
> +
>   	mp->m_dentry = dentry;
>   	mp->m_count = 1;
>   	list_add(&mp->m_hash, chain);

