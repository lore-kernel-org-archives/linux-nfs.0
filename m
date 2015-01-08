Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:60983 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165AbbAHAFo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 19:05:44 -0500
Received: by mail-vc0-f179.google.com with SMTP id le20so131985vcb.10
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 16:05:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <D6EB7F1B-ADD3-40F6-8A7C-A00CBBA02FC9@oracle.com>
References: <D6EB7F1B-ADD3-40F6-8A7C-A00CBBA02FC9@oracle.com>
Date: Wed, 7 Jan 2015 16:05:43 -0800
Message-ID: <CAHQdGtT0YtmG+SO7d47F+eSD1rjF7kDPv87uJkznhUaK+nzYkw@mail.gmail.com>
Subject: Re: close(2) behavior when client holds a write delegation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dai Ngo <dai.ngo@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 7, 2015 at 12:04 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi-
>
> Dai noticed that when a 3.17 Linux NFS client is granted a
> write delegation, it neglects to flush dirty data synchronously
> with close(2). The data is flushed asynchronously, and close(2)
> completes immediately. Normally that’s OK. But Dai observed that:
>
> 1. If the server can’t accommodate the dirty data (eg ENOSPC or
>    EIO) the application is not notified, even via close(2) return
>    code.
>
> 2. If the server is down, the application does not hang, but it
>    can leave dirty data in the client’s page cache with no
>    indication to applications or administrators.
>
>    The disposition of that data remains unknown even if a umount
>    is attempted. While the server is down, the umount will hang
>    trying to flush that data without giving an indication of why.
>
> 3. If a shutdown is attempted while the server is down and there
>    is a pending flush, the shutdown will hang, even though there
>    are no running applications with open files.
>
> 4. The behavior is non-deterministic from the application’s
>    perspective. It occurs only if the server has granted a write
>    delegation for that file; otherwise close(2) behaves like it
>    does for NFSv2/3 or NFSv4 without a delegation present
>    (close(2) waits synchronously for the flush to complete).
>
> Should close(2) wait synchronously for a data flush even in the
> presence of a write delegation?
>
> It’s certainly reasonable for umount to try hard to flush pinned
> data, but that makes shutdown unreliable.

We should probably start paying more attention to the "space_limit"
field in the write delegation. That field is supposed to tell the
client precisely how much data it is allowed to cache on close().

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
