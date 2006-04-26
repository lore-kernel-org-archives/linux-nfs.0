From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 09:14:56 -0400
Message-ID: <444F7250.2070200@redhat.com>
References: <444EC96B.80400@RedHat.com> <1146056601.8177.34.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1146056601.8177.34.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:

>On Tue, 2006-04-25 at 21:14 -0400, Steve Dickson wrote:
> =20
>
>>Currently the NFS client caches ACCESS information on a per uid basis
>>which fall apart when different process with different uid consistent=
ly
>>access the same directory. The end result being a storm of needless
>>ACCESS calls...
>>
>>The attached patch used a hash table to store the nfs_access_entry
>>entires which cause the ACCESS request to only happen when the
>>attributes timeout.. The table is indexed by the addition of the
>>nfs_inode pointer and the cr_uid in the cred structure which should
>>spread things out nicely for some decent scalability (although the
>>locking scheme may need to be reworked a bit). The table has 256 entr=
ies
>>of struct list_head giving it a total size of 2k.
>>   =20
>>
>
>Instead of having the field 'id', why don't you let the nfs_inode keep=
 a
>small (hashed?) list of all the nfs_access_entry objects that refer to
>it? That would speed up searches for cached entries.
>
>I agree with Neil's assessment that we need a bound on the size of the
>cache. In fact, enforcing a bound is pretty much the raison d'=EAtre f=
or a
>global table (by which I mean that if we don't need a bound, then we
>might as well cache everything in the nfs_inode).
>How about rather changing that hash table into an LRU list, then addin=
g
>a shrinker callback (using set_shrinker()) to allow the VM to free up
>entries when memory pressure dictates that it must?
>

Previous implementations have shown that a single per inode linear=20
linked list
ends up not being scalable enough in certain situations.  There would e=
nd up
being too many entries in the list and searching the list would become
a bottleneck.  Adding a set of hash buckets per inode also proved to be
inefficient because in order to have enough hash buckets to make the ha=
shing
efficient, much space was wasted.  Having a single set of hash buckets,
adequately sized, ended up being the best solution.

Why have a limit?  A better solution is to have the cache grow dynamica=
lly
as need requires and then have the system reclaim the memory when it st=
arts
to run low on memory.

       ps
-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
