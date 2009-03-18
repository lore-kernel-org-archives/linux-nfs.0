From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 12/14] nfsd4: remove use of mutex for file_hashtable
Date: Wed, 18 Mar 2009 23:07:51 +0200
Message-ID: <49C162A7.3040505@panasas.com>
References: <1236731222-3294-10-git-send-email-bfields@fieldses.org> <1236731222-3294-11-git-send-email-bfields@fieldses.org> <1236731222-3294-12-git-send-email-bfields@fieldses.org> <1236731222-3294-13-git-send-email-bfields@fieldses.org> <49B8085E.5080808@panasas.com> <20090312000540.GB21854@fieldses.org> <49B8E8B5.4010205@panasas.com> <20090313171831.GA26916@fieldses.org> <20090318202859.GA18894@fieldses.org> <49C15C49.9070105@panasas.com> <20090318210329.GC18894@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	Alexandros Batsakis <batsakis@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25811 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753938AbZCRVH6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 17:07:58 -0400
In-Reply-To: <20090318210329.GC18894@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 18, 2009, 23:03 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Wed, Mar 18, 2009 at 10:40:41PM +0200, Benny Halevy wrote:
>> On Mar. 18, 2009, 22:28 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>  static inline void
>>>  put_nfs4_file(struct nfs4_file *fi)
>>>  {
>>> -	kref_put(&fi->fi_ref, free_nfs4_file);
>> missing spin_lock(&recall_lock);?
>>
>>
>>> +	if (atomic_dec_and_lock(&fi->fi_ref, &recall_lock)) {
>>> +		list_del(&fi->fi_hash);
>>> +		spin_unlock(&recall_lock);
>>> +		iput(fi->fi_inode);
>>> +		kmem_cache_free(file_slab, fi);
>>> +	}
>> 	} else {
>> 		spin_unlock(&recall_lock);
>> 	}
>>
>> or am I missing something?
> 
> From include/linux/spinlock.h:
> 
> /**
>  * atomic_dec_and_lock - lock on reaching reference count zero
>  * @atomic: the atomic counter
>  * @lock: the spinlock in question
>  *
>  * Decrements @atomic by 1.  If the result is 0, returns true and locks
>  * @lock.  Returns false for all other cases.
>  */
> 
> So it's useful for cases such as this, when a reference-counted object
> is reachable from some data structure visible to others, and you want to
> remove it from that structure on dropping the last reference (as opposed
> to keeping one reference for the structure itself, and requiring the
> object to be explicitly removed).
> 
> (Unless I'm missing something else.)

My bad. I did miss that.
Patch looks good to me now.

Benny

> 
> --b.
