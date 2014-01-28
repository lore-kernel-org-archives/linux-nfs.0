Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:65257 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaA1NuV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jan 2014 08:50:21 -0500
Received: by mail-ie0-f176.google.com with SMTP id tp5so377171ieb.7
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jan 2014 05:50:21 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] NFS: fix the handling of NFS_INO_INVALID_DATA flag in nfs_revalidate_mapping
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140128083829.00538279@tlielax.poochiereds.net>
Date: Tue, 28 Jan 2014 08:50:19 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <0641E1F1-DAD7-465F-9EC7-0ECE21904E8C@primarydata.com>
References: <1390848375-17034-1-git-send-email-jlayton@redhat.com> <20140128083829.00538279@tlielax.poochiereds.net>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 28, 2014, at 8:38, Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 27 Jan 2014 13:46:15 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
>> There is a possible race in how the nfs_invalidate_mapping function is
>> handled.  Currently, we go and invalidate the pages in the file and then
>> clear NFS_INO_INVALID_DATA.
>> 
>> The problem is that it's possible for a stale page to creep into the
>> mapping after the page was invalidated (i.e., via readahead). If another
>> writer comes along and sets the flag after that happens but before
>> invalidate_inode_pages2 returns then we could clear the flag
>> without the cache having been properly invalidated.
>> 
>> So, we must clear the flag first and then invalidate the pages. Doing
>> this however, opens another race:
>> 
>> It's possible to have two concurrent read() calls that end up in
>> nfs_revalidate_mapping at the same time. The first one clears the
>> NFS_INO_INVALID_DATA flag and then goes to call nfs_invalidate_mapping.
>> 
>> Just before calling that though, the other task races in, checks the
>> flag and finds it cleared. At that point, it trusts that the mapping is
>> good and gets the lock on the page, allowing the read() to be satisfied
>> from the cache even though the data is no longer valid.
>> 
>> These effects are easily manifested by running diotest3 from the LTP
>> test suite on NFS. That program does a series of DIO writes and buffered
>> reads. The operations are serialized and page-aligned but the existing
>> code fails the test since it occasionally allows a read to come out of
>> the cache incorrectly. While mixing direct and buffered I/O isn't
>> recommended, I believe it's possible to hit this in other ways that just
>> use buffered I/O, though that situation is much harder to reproduce.
>> 
>> The problem is that the checking/clearing of that flag and the
>> invalidation of the mapping really need to be atomic. Fix this by
>> serializing concurrent invalidations with a bitlock.
>> 
>> At the same time, we also need to allow other places that check
>> NFS_INO_INVALID_DATA to check whether we might be in the middle of
>> invalidating the file, so fix up a couple of places that do that
>> to look for the new NFS_INO_INVALIDATING flag.
>> 
>> Doing this requires us to be careful not to set the bitlock
>> unnecessarily, so this code only does that if it believes it will
>> be doing an invalidation.
>> 
>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>> ---
>> fs/nfs/dir.c           |  3 ++-
>> fs/nfs/inode.c         | 42 ++++++++++++++++++++++++++++++++++++++----
>> fs/nfs/nfstrace.h      |  1 +
>> fs/nfs/write.c         |  6 +++++-
>> include/linux/nfs_fs.h |  1 +
>> 5 files changed, 47 insertions(+), 6 deletions(-)
>> 
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index b266f73..b39a046 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -288,7 +288,8 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
>> 
>> 			new_pos = desc->current_index + i;
>> 			if (ctx->attr_gencount != nfsi->attr_gencount
>> -			    || (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))) {
>> +			    || (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))
>> +			    || test_bit(NFS_INO_INVALIDATING, &nfsi->flags)) {
>> 				ctx->duped = 0;
>> 				ctx->attr_gencount = nfsi->attr_gencount;
>> 			} else if (new_pos < desc->ctx->pos) {
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index c63e152..0a972ee 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -977,11 +977,11 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
>> 		if (ret < 0)
>> 			return ret;
>> 	}
>> -	spin_lock(&inode->i_lock);
>> -	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
>> -	if (S_ISDIR(inode->i_mode))
>> +	if (S_ISDIR(inode->i_mode)) {
>> +		spin_lock(&inode->i_lock);
>> 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
>> -	spin_unlock(&inode->i_lock);
>> +		spin_unlock(&inode->i_lock);
>> +	}
>> 	nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
>> 	nfs_fscache_wait_on_invalidate(inode);
>> 
>> @@ -1008,6 +1008,7 @@ static bool nfs_mapping_need_revalidate_inode(struct inode *inode)
>> int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
>> {
>> 	struct nfs_inode *nfsi = NFS_I(inode);
>> +	unsigned long *bitlock = &nfsi->flags;
>> 	int ret = 0;
>> 
>> 	/* swapfiles are not supposed to be shared. */
>> @@ -1019,12 +1020,45 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
>> 		if (ret < 0)
>> 			goto out;
>> 	}
>> +
>> +	/*
>> +	 * We must clear NFS_INO_INVALID_DATA first to ensure that
>> +	 * invalidations that come in while we're shooting down the mappings
>> +	 * are respected. But, that leaves a race window where one revalidator
>> +	 * can clear the flag, and then another checks it before the mapping
>> +	 * gets invalidated. Fix that by serializing access to this part of
>> +	 * the function.
>> +	 *
>> +	 * At the same time, we need to allow other tasks to see whether we
>> +	 * might be in the middle of invalidating the pages, so we only set
>> +	 * the bit lock here if it looks like we're going to be doing that.
>> +	 */
>> +	for (;;) {
>> +		ret = wait_on_bit(bitlock, NFS_INO_INVALIDATING,
>> +				  nfs_wait_bit_killable, TASK_KILLABLE);
>> +		if (ret)
>> +			goto out;
>> +		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA))
>> +			goto out;
>> +		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING, bitlock))
>> +			break;
>> +	}
>> +
> 
> So, I should mention that while the testcase does pass with this
> patchset, I think there are still races in here.
> 
> I think it's possible for two tasks to enter this code nearly
> simultaneously such that the bitlock is clear. One gets the lock and
> then clears NFS_INO_INVALID_DATA, and the other then checks the flag,
> finds it clear and exits the function before the pages were invalidated.

So what? Something can always come up later to cause the NFS client to invalidate the cache again. That’s pretty much per the definition of weak cache consistency.

All we should need to care about in nfs_revalidate_mapping is that the function respects any and all NFS_INO_INVALID_DATA settings that were in effect _before_ entering the above code.

> I wonder if we'd be better served with a new cache_validity flag
> NFS_INO_INVALIDATING_DATA or something, and not have other functions
> trying to peek at the bitlock.

The one thing that I’m not sure of above is whether or not we need an ACCESS_ONCE() around the read of nfsi->cache_validity. I think not, since wait_on_bit and test_and_set_bit should both contain barriers, but I’m not an ultimate authority in the matter.

--
Trond Myklebust
Linux NFS client maintainer

