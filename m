From: jim owens <jowens@hp.com>
Subject: Re: [patch 0/9] writeback data integrity and other fixes (take 3)
Date: Thu, 30 Oct 2008 08:51:44 -0400
Message-ID: <4909ADE0.1060205@hp.com>
References: <20081028222746.GB4985@disturbed> <20081029001653.GF15599@wotan.suse.de> <20081029031645.GE4985@disturbed> <20081029091203.GA32545@infradead.org> <20081029092143.GA5953@wotan.suse.de> <20081029094417.GA21824@infradead.org> <20081029103029.GC5953@wotan.suse.de> <20081029122234.GE846@shareable.org> <490865E3.8070102@gmail.com> <1225292196.6448.263.camel@think.oraclecorp.com> <20081030021601.GF18041@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chris Mason <chris.mason@oracle.com>,
	Ric Wheeler <ricwheeler@gmail.com>,
	Jamie Lokier <jamie@shareable.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:1235 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024AbYJ3Mvu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Oct 2008 08:51:50 -0400
In-Reply-To: <20081030021601.GF18041-B4tOwbsTzaBolqkO4TVVkw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nick Piggin wrote:
> On Wed, Oct 29, 2008 at 10:56:36AM -0400, Chris Mason wrote:
>> On Wed, 2008-10-29 at 09:32 -0400, Ric Wheeler wrote:
>>> Jamie Lokier wrote:
>>>>> Is there anything that particularly makes it a file operation
>>>>> as opposed to an inode operation?
>>>>>     
>>>> In principle, is fsync() required to flush all dirty data written
>>>> through any file descriptor ever, or just dirty data written through
>>>> the file descriptor used for fsync()?
>>>>
>>>> -- Jamie
>>>> --
>>>>   
>>> http://www.opengroup.org/onlinepubs/009695399/functions/fsync.html
>>>
>>> Is a pointer to what seems to be the official posix spec for this - it 
>>> is definitely per file descriptor, not per file system, etc...
>>>
>> Maybe I'm reading Jamie's question wrong, but I think he's saying:
>>
>> /* open exactly the same file twice */
>> fd = open("file");
>> fd2 = open("file");
>>
>> write(fd, "stuff")
>> write(fd2, "more stuff")
>> fsync(fd);
>>
>> Does the fsync promise "more stuff" will be on disk?  I think the answer
>> should be yes.
> 
> I think so. And this is in the context of making ->fsync an inode
> operation and avoid the NFS NULL-file problem... I don't think there
> is any fd specific metadata that fsync has to deal with? Any other
> reasons it has to be a file operation?

NO, or at least *not the posix definition*.  It is normal
in unix-like operating systems to always flush everything
dirty on the inode no matter what stream it arrived on.

Flushing everything is permitted but not the requirement so
applications must not expect this is *promised* or they
will not be portable.  It is only guaranteed that "stuff"
in this example will be on disk.

AFAIK the fsync semantic comes from the days of dinosaurs,
mainframes, and minicomputers... when a lot of operating
systems had user-space libraries that buffered the I/O.
On fsync(fd), the "fd2" data would still be in user-space.

jim
