From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 10:15:50 -0400
Message-ID: <444F8096.2070308@redhat.com>
References: <444EC96B.80400@RedHat.com>	 <1146056601.8177.34.camel@lade.trondhjem.org> <444F7250.2070200@redhat.com> <1146060112.8177.72.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1146060112.8177.72.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:

>On Wed, 2006-04-26 at 09:14 -0400, Peter Staubach wrote:
> =20
>
>>Trond Myklebust wrote:
>>
>>   =20
>>
>>>On Tue, 2006-04-25 at 21:14 -0400, Steve Dickson wrote:
>>>=20
>>>
>>>     =20
>>>
>>>>Currently the NFS client caches ACCESS information on a per uid bas=
is
>>>>which fall apart when different process with different uid consiste=
ntly
>>>>access the same directory. The end result being a storm of needless
>>>>ACCESS calls...
>>>>
>>>>The attached patch used a hash table to store the nfs_access_entry
>>>>entires which cause the ACCESS request to only happen when the
>>>>attributes timeout.. The table is indexed by the addition of the
>>>>nfs_inode pointer and the cr_uid in the cred structure which should
>>>>spread things out nicely for some decent scalability (although the
>>>>locking scheme may need to be reworked a bit). The table has 256 en=
tries
>>>>of struct list_head giving it a total size of 2k.
>>>>  =20
>>>>
>>>>       =20
>>>>
>>>Instead of having the field 'id', why don't you let the nfs_inode ke=
ep a
>>>small (hashed?) list of all the nfs_access_entry objects that refer =
to
>>>it? That would speed up searches for cached entries.
>>>
>>>I agree with Neil's assessment that we need a bound on the size of t=
he
>>>cache. In fact, enforcing a bound is pretty much the raison d'=EAtre=
 for a
>>>global table (by which I mean that if we don't need a bound, then we
>>>might as well cache everything in the nfs_inode).
>>>How about rather changing that hash table into an LRU list, then add=
ing
>>>a shrinker callback (using set_shrinker()) to allow the VM to free u=
p
>>>entries when memory pressure dictates that it must?
>>>
>>>     =20
>>>
>>Previous implementations have shown that a single per inode linear=20
>>linked list
>>ends up not being scalable enough in certain situations.  There would=
 end up
>>being too many entries in the list and searching the list would becom=
e
>>a bottleneck.  Adding a set of hash buckets per inode also proved to =
be
>>inefficient because in order to have enough hash buckets to make the =
hashing
>>efficient, much space was wasted.  Having a single set of hash bucket=
s,
>>adequately sized, ended up being the best solution.
>>   =20
>>
>
>What situations? AFAIA the number of processes in a typical setup are
>almost always far smaller than the number of cached inodes.
>
> =20
>

The situation that doesn't scale is one where there are many different
users on the system.  It is the situation where there are more then jus=
t
a few users per file.  This can happen on compute servers or systems
used for timesharing sorts of purposes.

>For instance on my laptop, I'm currently running 146 processes, but
>according to /proc/slabinfo I'm caching 330000 XFS inodes + 141500 ext=
3
>inodes.
>If I were to assume that a typical nfsroot system will show roughly th=
e
>same behaviour, then it would mean that a typical bucket in Steve's 25=
6
>hash entry table will contain at least 2000 entries that I need to
>search through every time I want to do an access call.
>

=46or such a system, there needs to be more than 256 hash buckets.  The=
 number
of the access cache hash buckets needs to be on scale with the number o=
f=20
hash
buckets used for similarly sized caches and tables.

       ps
-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
