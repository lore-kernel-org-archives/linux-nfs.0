Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:54034 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038Ab1JURoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Oct 2011 13:44:16 -0400
Message-ID: <4EA1AF6D.60603@rath.org>
Date: Fri, 21 Oct 2011 13:44:13 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Does NFS4 need st_gen?
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>		 <20111019171551.GA32028@fieldses.org>		 <87d3dsdcf4.fsf@inspiron.ap.columbia.edu>		 <20111020120207.GL5444@fieldses.org>		 <877h3za89w.fsf@inspiron.ap.columbia.edu>		 <20111020195731.GC9987@fieldses.org>		 <871uu79z7m.fsf@inspiron.ap.columbia.edu>		 <1319155647.2768.4.camel@lade.trondhjem.org>		 <87vcrisb5y.fsf@inspiron.ap.columbia.edu>	 <1319212854.4537.9.camel@lade.trondhjem.org> <4EA1994D.6060700@rath.org> <1319217023.4537.28.camel@lade.trondhjem.org>
In-Reply-To: <1319217023.4537.28.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/21/2011 01:10 PM, Trond Myklebust wrote:
> On Fri, 2011-10-21 at 12:09 -0400, Nikolaus Rath wrote: 
>> On 10/21/2011 12:00 PM, Trond Myklebust wrote:
>>> On Fri, 2011-10-21 at 09:54 -0400, Nikolaus Rath wrote: 
>>>> Trond Myklebust <Trond.Myklebust@netapp.com> writes:
>>>>> On Thu, 2011-10-20 at 16:37 -0400, Nikolaus Rath wrote: 
>>>>>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>>>>>>> On Thu, Oct 20, 2011 at 01:21:31PM -0400, Nikolaus Rath wrote:
>>>>>>>> I'm working on a FUSE file system that stores file system metadata in an
>>>>>>>> SQL database (http://code.google.com/p/s3ql/). Not having to keep track
>>>>>>>> of inode generation numbers would keep the code much simpler, because I
>>>>>>>> want to delete inode-rows from the SQL table when the last reference to
>>>>>>>> the inode is deleted (so I can't keep track of the generation no).
>>>>>>>
>>>>>>> You can use current time, or a counter, or something, as the generation
>>>>>>> number.
>>>>>>
>>>>>> With current time I'm screwed if the system clock doesn't have
>>>>>> sufficiently fine granularity. With a counter, I either have to remember
>>>>>> counter values per-inode even after the inode is deleted, or the global
>>>>>> counter will overflow at some point (in which case I may just as well
>>>>>> require unique inodes in the first place).
>>>>>
>>>>> The filehandle is between 32 (NFSv2) and 128(NFSv4) bytes long. How long
>>>>> do you expect it to take you to create+destroy between 2^256 and 2^1024
>>>>> inodes? I'm guessing that we'll all be long dead and the universe will
>>>>> have undergone heat death before that happens...
>>>>
>>>> Please stop assuming that I'm stupid or haven't thought about the
>>>> problem at all. The bottleneck is not the length of the NFS file handle,
>>>> but the length of the inode and generation number (both of which are
>>>> restricted to 32bit by FUSE) together with the requirement that not only
>>>> both of them together need to be unique forever, but the inode also
>>>> needs to be unique at any given instant (so they cannot be trivially
>>>> combined to form a 64bit value).
>>>
>>> No. The point is you don't need a generation number if you don't want to
>>> implement one...
>>>
>>> You can use any unique identifier + the inode number, and the unique
>>> identifier is only limited by the size of the filehandle.
>>
>> So how do you choose the unique identifier? It's limited by FUSE to
>> 32bit and therefore can't be a global counter, it can't be a timestamp
> 
> AFAICS fuse gives you a 64-bit inode number and a 32-bit generation
> counter. 

Yes, with 64bit inodes everything would be fine. But fuse uses 'long'
for inodes, so on 32bit systems you only have 32bit inodes even if ino_t
is 64bit.


> IOW: start allocating inode numbers incrementally from 0 - 2^64, then
> each time you overflow the 64-bit inode number counter, bump the
> generation number. You'll have to skip those inode numbers that are
> already allocated in the subsequent generations, but the total number of
> unique combinations is still likely to be more than large enough not to
> be a worry.

Yes, as I said eariler, it is possible to do with the available 32 + 32
bits, but it does introduce additional complexity.


>> because the system clock may not have enough resolution, and it can't be
>> a per-inode counter because then I can't discard the counter after the
>> inode has been deleted.
> 
> If you need more unique values, then modify fuse to allow your
> filesystem to manage the exportfs interface. The fuse ABI is versioned,
> and can be extended to support new features.

FUSE 3 will have 64bit inodes, and I don't think this feature would make
it into 2.x.


Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
