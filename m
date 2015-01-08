Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:50971 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbbAHC6V convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 21:58:21 -0500
Received: by mail-vc0-f174.google.com with SMTP id id10so327260vcb.5
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 18:58:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150108011127.GA93138@kitty>
References: <D6EB7F1B-ADD3-40F6-8A7C-A00CBBA02FC9@oracle.com>
	<CAHQdGtT0YtmG+SO7d47F+eSD1rjF7kDPv87uJkznhUaK+nzYkw@mail.gmail.com>
	<20150108011127.GA93138@kitty>
Date: Wed, 7 Jan 2015 18:58:20 -0800
Message-ID: <CAHQdGtQxr8BmO=+M8kW90DJeE7bve5pgzOdmz_ZBNyQfNX_xyA@mail.gmail.com>
Subject: Re: close(2) behavior when client holds a write delegation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dai Ngo <dai.ngo@oracle.com>, "nfsv4@ietf.org" <nfsv4@ietf.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 7, 2015 at 5:11 PM, Tom Haynes
<thomas.haynes@primarydata.com> wrote:
> Adding NFSv4 WG ....
>
> On Wed, Jan 07, 2015 at 04:05:43PM -0800, Trond Myklebust wrote:
>> On Wed, Jan 7, 2015 at 12:04 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> > Hi-
>> >
>> > Dai noticed that when a 3.17 Linux NFS client is granted a
>
> Hi, is this new behavior for 3.17 or does it happen to prior
> versions as well?
>
>> > write delegation, it neglects to flush dirty data synchronously
>> > with close(2). The data is flushed asynchronously, and close(2)
>> > completes immediately. Normally that’s OK. But Dai observed that:
>> >
>> > 1. If the server can’t accommodate the dirty data (eg ENOSPC or
>> >    EIO) the application is not notified, even via close(2) return
>> >    code.
>> >
>> > 2. If the server is down, the application does not hang, but it
>> >    can leave dirty data in the client’s page cache with no
>> >    indication to applications or administrators.
>> >
>> >    The disposition of that data remains unknown even if a umount
>> >    is attempted. While the server is down, the umount will hang
>> >    trying to flush that data without giving an indication of why.
>> >
>> > 3. If a shutdown is attempted while the server is down and there
>> >    is a pending flush, the shutdown will hang, even though there
>> >    are no running applications with open files.
>> >
>> > 4. The behavior is non-deterministic from the application’s
>> >    perspective. It occurs only if the server has granted a write
>> >    delegation for that file; otherwise close(2) behaves like it
>> >    does for NFSv2/3 or NFSv4 without a delegation present
>> >    (close(2) waits synchronously for the flush to complete).
>> >
>> > Should close(2) wait synchronously for a data flush even in the
>> > presence of a write delegation?
>> >
>> > It’s certainly reasonable for umount to try hard to flush pinned
>> > data, but that makes shutdown unreliable.
>>
>> We should probably start paying more attention to the "space_limit"
>> field in the write delegation. That field is supposed to tell the
>> client precisely how much data it is allowed to cache on close().
>>
>
> Sure, but what does that mean?
>
> Is the space_limit supposed to be on the file or the amount of data that
> can be cached by the client?
>
> Note that Spencer Dawkins effectively asked this question a couple of years ago:
>
> | In this text:
> |
> | 15.18.3.  RESULT
> |
> |     nfs_space_limit4
> |               space_limit; /* Defines condition that
> |                               the client must check to
> |                               determine whether the
> |                               file needs to be flushed
> |                               to the server on close.  */
> |
> | I'm no expert, but could I ask you to check whether this is the right
> | description for this struct? nfs_space_limit4 looks like it's either
> | a file size or a number of blocks, and I wasn't understanding how that
> | was a "condition" or how the limit had anything to do with flushing a
> | file to the server on close, so I'm wondering about a cut-and-paste error.
> |
>
> Does any server set the space_limit?
>
> And to what?
>
> Note, it seems that OpenSolaris does set it to be NFS_LIMIT_SIZE and
> UINT64_MAX. Which means that it is effectively saying that the client
> is guaranteed a lot of space. :-)

Yes... Unless they plan to never return NFS4ERR_NOSPC, then that
suggests we should probably file an errata deprecating the feature
altogether.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
