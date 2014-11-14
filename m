Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:59791 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541AbaKNOWP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 09:22:15 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so2822446wib.11
        for <linux-nfs@vger.kernel.org>; Fri, 14 Nov 2014 06:22:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141114043505.GA29950@dastard>
References: <20141111162849.GA12527@lst.de>
	<20141111162704.GA12103@lst.de>
	<20141111222710.GY23575@dastard>
	<20141112102440.GA31344@lst.de>
	<CAHQdGtRi-20XRthpU7vrkAE+=3d9HG6g8i6REGYn+uo0xkbmRw@mail.gmail.com>
	<20141113002846.GC23575@dastard>
	<CAHQdGtRvaOTT7375p0eDjPPm+uFc19AJkf-NWDAKq-=goqZSpA@mail.gmail.com>
	<20141113235400.GM28565@dastard>
	<CAHQdGtTzs+K1dUo=9W9sp45-qGxFp5pDwXJgdHY=6UV+Myr68Q@mail.gmail.com>
	<20141114043505.GA29950@dastard>
Date: Fri, 14 Nov 2014 09:22:14 -0500
Message-ID: <CAHQdGtR6hQ=B9SvD+52jS7gdAGLw4-y4SSX829eEH5q0ONXp1w@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 11:35 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Thu, Nov 13, 2014 at 07:43:33PM -0500, Trond Myklebust wrote:
>> On Thu, Nov 13, 2014 at 6:54 PM, Dave Chinner <david@fromorbit.com> wrote:
>> > On Thu, Nov 13, 2014 at 08:02:43AM -0500, Trond Myklebust wrote:
>> >> On Wed, Nov 12, 2014 at 7:28 PM, Dave Chinner <david@fromorbit.com> wrote:
>> >> > On Wed, Nov 12, 2014 at 09:26:16AM -0500, Trond Myklebust wrote:
>> >> >> On Wed, Nov 12, 2014 at 5:24 AM, Christoph Hellwig <hch@lst.de> wrote:
>> >> >> > On Wed, Nov 12, 2014 at 09:27:10AM +1100, Dave Chinner wrote:
>> >> >> >> To clarify what Christoph wrote, XFS updates i_version is updated
>> >> >> >> once per transaction that modifies the inode. So if a VFS level
>> >> >> >> operation results in multiple transactions then each transaction
>> >> >> >> will but the version.
>> >> >> >>
>> >> >> >> It was implemented that way because nobody could tell me what the
>> >> >> >> actual granularity requirement for change detection was.  Hence what
>> >> >> >> I implemented was "be able to detect any persistent change that is
>> >> >> >> made" to cover all bases.
>> >
>> > FWIW, ext4 takes the same approach.  See Ted's post today:
>> >
>> > http://www.spinics.net/lists/linux-ext4/msg46194.html
>> >
>> > "The inode_inc_iversion() in mark4_ext4_iloc_dirty() is probably not
>> > necessary, since we already should be incrementing i_version whenever
>> > ctime and mtime gets updated.  The inode_inc_iversion() there is more
>> > of a "belt and suspenders" safety thing, on the theory that the extra
>> > bump in i_version won't hurt anything."
>> >
>>
>> It will hurt if it causes all the NFS clients to blow their caches
>> unnecessarily.
>
> Not my problem. We've just implemented what we were asked to
> implement.
>
>> Who asked for this?
>
> The only discussion where actual specifications were enumerated was
> during a thread about using i_version in the integrity measurement
> code (IMA subsystem). The NFSv4 requirements for the change counter
> were expressed here:
>
> https://lkml.org/lkml/2012/1/5/408
>
> Don't blame us for implementing the vague "changes every time"
> requirements in a way that results in no chance of a persistent
> change to either data or metadata being missed by the filesystem.

I'm not blaming anyone. I'm stating that I'm not aware of anybody who
needs to trace fiemap changes via the change attribute, and so I'm
asking where that requirement came from?
The NFSv4 requirements are specific if you take them within the
context of NFS, which is all about clients not having to care about
whether the data is stored on SSD block devices or deduped stone
tablets. Fiemap, being block specific, is irrelevant to that
environment.

So do the IMA folks use i_version and, if so, how are they using it?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
