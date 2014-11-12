Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:62428 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbaKLO0R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 09:26:17 -0500
Received: by mail-wi0-f180.google.com with SMTP id hi2so5027092wib.7
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 06:26:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141112102440.GA31344@lst.de>
References: <20141111162849.GA12527@lst.de>
	<20141111162704.GA12103@lst.de>
	<20141111222710.GY23575@dastard>
	<20141112102440.GA31344@lst.de>
Date: Wed, 12 Nov 2014 09:26:16 -0500
Message-ID: <CAHQdGtRi-20XRthpU7vrkAE+=3d9HG6g8i6REGYn+uo0xkbmRw@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 5:24 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Wed, Nov 12, 2014 at 09:27:10AM +1100, Dave Chinner wrote:
>> To clarify what Christoph wrote, XFS updates i_version is updated
>> once per transaction that modifies the inode. So if a VFS level
>> operation results in multiple transactions then each transaction
>> will but the version.
>>
>> It was implemented that way because nobody could tell me what the
>> actual granularity requirement for change detection was.  Hence what
>> I implemented was "be able to detect any persistent change that is
>> made" to cover all bases.
>
> Honestly the XFS implementation seems most sensible, and easiest to
> verify for me.  I don't really understand the rationale behind the
> fairly convoluted NFS4_CHANGE_TYPE_IS_VERSION_COUNTER semantics, and
> I doubt you could actually implemet them on any Unix-like semantics.
>
> Trond, given that the language in the standard is from you:
>
>  1) how do you expect to use NFS4_CHANGE_TYPE_IS_VERSION_COUNTER
>     semantics in the client

Basically, I'd like to use it the same way that AFS does. I want to be
able to issue an RPC call which does the equivalent of a single system
call (e.g. mkdir(), write(), link(), unlink(), etc) and be able to
predict what the effect should be on the change attribute (1 increment
on the parent directory for a successful mkdir(), 1 increment on the
file for a successful write(), ...) so that I can detect if someone
else has been modifying the file/directory/symlink while I wasn't
looking and hence know when I need to invalidate my cached
metadata+data for that object.

>  2) what server do you have in mind that could actually implement them?

As I said, AFS has this kind of semantics, and the AFS client on Linux
uses them to do this kind of 3rd party change detection.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
