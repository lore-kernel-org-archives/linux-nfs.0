From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 13:01:58 -0400
Message-ID: <444FA786.90606@redhat.com>
References: <444EC96B.80400@RedHat.com>	 <1146056601.8177.34.camel@lade.trondhjem.org> <444F7250.2070200@redhat.com>	 <1146060112.8177.72.camel@lade.trondhjem.org> <444F8096.2070308@redhat.com> <1146066250.8474.18.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1146066250.8474.18.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:

>On Wed, 2006-04-26 at 10:15 -0400, Peter Staubach wrote:
>  
>
>>>What situations? AFAIA the number of processes in a typical setup are
>>>almost always far smaller than the number of cached inodes.
>>>
>>> 
>>>
>>>      
>>>
>>The situation that doesn't scale is one where there are many different
>>users on the system.  It is the situation where there are more then just
>>a few users per file.  This can happen on compute servers or systems
>>used for timesharing sorts of purposes.
>>    
>>
>
>Yes, but the number of users <= number of processes which even on those
>systems is almost always much, much less than the number of cached
>inodes.
>
>  
>

There isn't a 1-to-1 correspondence between processes and files.  A single
process accesses many different files and many of the processes will be
accessing the same files.  Shared libraries are easy examples of files
which are accessed by multiple processes and processes themselves access
multiple shared libraries.

>>>For instance on my laptop, I'm currently running 146 processes, but
>>>according to /proc/slabinfo I'm caching 330000 XFS inodes + 141500 ext3
>>>inodes.
>>>If I were to assume that a typical nfsroot system will show roughly the
>>>same behaviour, then it would mean that a typical bucket in Steve's 256
>>>hash entry table will contain at least 2000 entries that I need to
>>>search through every time I want to do an access call.
>>>
>>>      
>>>
>>For such a system, there needs to be more than 256 hash buckets.  The number
>>of the access cache hash buckets needs to be on scale with the number of 
>>hash
>>buckets used for similarly sized caches and tables.
>>    
>>
>
>The inode cache is the only similarly sized cache I can think of.
>
>That is set either by the user, or it takes a default value of (total
>memory size) / 2^14 buckets (see alloc_large_system_hash). On a 1Gb
>system, that makes the default hash table size ~ 65536 entries. I can't
>see people wanting to put up with a 256K static hash table for access
>caching too.
>
>  
>

I think that if the performance benefits warrant such a cache, then it is
worth it.  It is a very small percentage of the real memory on the system.

Previous, informal, studies showed that caching access privileges like
this was good at short circuiting 90%+ of access calls.

However, we could always divide this further when sizing the access
cache.  If we assume that 1/2 or 1/4 or some percentage of the files
accessed will be on NFS mounted file systems, then the access cache just
needs to be based on the number of NFS inodes, not the total number of
inodes.

>Furthermore, note that the inode cache is only searched when
>initialising a dentry. It is not searched on _every_ traversal of a path
>element.
>

Very true, which points out the importance of getting the access to the 
access
cache correct and fast.  The number of entries in the access cache will 
be at
least the number of NFS inodes in the system and could be much higher 
depending
upon whether the system is single-user, desktop style system, or a 
multi-user
shared system.  The key to making this cache cheap is to make the hash 
algorithm
cheap and keeping the hash chains short.

       ps
