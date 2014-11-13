Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f52.google.com ([74.125.82.52]:41091 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932622AbaKMNCp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 08:02:45 -0500
Received: by mail-wg0-f52.google.com with SMTP id b13so16674299wgh.25
        for <linux-nfs@vger.kernel.org>; Thu, 13 Nov 2014 05:02:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141113002846.GC23575@dastard>
References: <20141111162849.GA12527@lst.de>
	<20141111162704.GA12103@lst.de>
	<20141111222710.GY23575@dastard>
	<20141112102440.GA31344@lst.de>
	<CAHQdGtRi-20XRthpU7vrkAE+=3d9HG6g8i6REGYn+uo0xkbmRw@mail.gmail.com>
	<20141113002846.GC23575@dastard>
Date: Thu, 13 Nov 2014 08:02:43 -0500
Message-ID: <CAHQdGtRvaOTT7375p0eDjPPm+uFc19AJkf-NWDAKq-=goqZSpA@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 7:28 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Wed, Nov 12, 2014 at 09:26:16AM -0500, Trond Myklebust wrote:
>> On Wed, Nov 12, 2014 at 5:24 AM, Christoph Hellwig <hch@lst.de> wrote:
>> > On Wed, Nov 12, 2014 at 09:27:10AM +1100, Dave Chinner wrote:
>> >> To clarify what Christoph wrote, XFS updates i_version is updated
>> >> once per transaction that modifies the inode. So if a VFS level
>> >> operation results in multiple transactions then each transaction
>> >> will but the version.
>> >>
>> >> It was implemented that way because nobody could tell me what the
>> >> actual granularity requirement for change detection was.  Hence what
>> >> I implemented was "be able to detect any persistent change that is
>> >> made" to cover all bases.
>> >
>> > Honestly the XFS implementation seems most sensible, and easiest to
>> > verify for me.  I don't really understand the rationale behind the
>> > fairly convoluted NFS4_CHANGE_TYPE_IS_VERSION_COUNTER semantics, and
>> > I doubt you could actually implemet them on any Unix-like semantics.
>> >
>> > Trond, given that the language in the standard is from you:
>> >
>> >  1) how do you expect to use NFS4_CHANGE_TYPE_IS_VERSION_COUNTER
>> >     semantics in the client
>>
>> Basically, I'd like to use it the same way that AFS does. I want to be
>> able to issue an RPC call which does the equivalent of a single system
>> call (e.g. mkdir(), write(), link(), unlink(), etc) and be able to
>> predict what the effect should be on the change attribute (1 increment
>> on the parent directory for a successful mkdir(), 1 increment on the
>> file for a successful write(), ...)
>
> That's not the way the change version counter is implemented in the
> VFS or any filesystem. It's a low level change primitive, not
> something that is only updated on a syscall granularity.
>
> I just can't see how a change counter at the syscall level can be
> made to work reliably. NFS clients are now being told about server
> block maps, so any extent map modification done by the underlying
> filesystem needs to bump the change count so if the client is
> caching the block map it can be invalidated. And with functionality
> like delayed allocation modifications the client needs to know aout
> can happen at any time and so change count modification can not be
> limited only to syscall activity.

I didn't say it needs to be implemented in the VFS. Just that it needs
to be implemented in a way that makes sense if you are doing the
equivalent of a system call. Delayed allocations are a filesystem
implementation detail that do not change the application visible data
or metadata contents of the file; there should be no reason to have
them reflected in something like the change attribute.

As for pNFS blocks, I agree that the spec there is a little iffy, but
the intention was, I believe, that the whole LAYOUTGET->LAYOUTCOMMIT
should be considered to be a single filesystem transaction. However
the iffiness there is the main reason why I made a distinction between
pnfs vs. non-pnfs when describing the change attribute.

>> so that I can detect if someone
>> else has been modifying the file/directory/symlink while I wasn't
>> looking and hence know when I need to invalidate my cached
>> metadata+data for that object.
>
> The only way to use the change count sanely from the client is as a
> "check-and-execute" cookie on the server. If the change count sent
> by the client is unchanged at the server then the server can execute
> the operation. It can then return the new cookie to the client for
> the next operation.  But we can't even do that sanely on Linux
> because the check-and-execute operation needs to be atomic and hence
> requires the filesystem to do it deep inside their transaction
> subsystems once they've taken the locks it needs to ensure the
> change count is stable.

Applications are required to interact with the filesystem through a
well-defined API. Application visible data and metadata changes can be
(and are mostly) well defined w.r.t. that API. Where be the dragons?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
