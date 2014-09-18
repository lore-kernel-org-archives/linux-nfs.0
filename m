Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:40174 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755694AbaIRObt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2014 10:31:49 -0400
Received: by mail-vc0-f177.google.com with SMTP id im17so748744vcb.8
        for <linux-nfs@vger.kernel.org>; Thu, 18 Sep 2014 07:31:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <541AD7E5.8020409@engr.wisc.edu>
References: <541AD7E5.8020409@engr.wisc.edu>
Date: Thu, 18 Sep 2014 10:31:48 -0400
Message-ID: <CAHQdGtQZ0kcBZ0QCb+sf52thERjJgz-5M++CsT7kdoDweG61sQ@mail.gmail.com>
Subject: Re: NFS Kernel Bug
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: James Drews <drews@engr.wisc.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 18, 2014 at 9:02 AM, James Drews <drews@engr.wisc.edu> wrote:
> Good morning!
>
> I believe we have found a bug in the NFS kernel area.  The "bug" is a leak
> of a file handle where the NFS client never tells the server to close the
> file. The problem is very similar to one we had reported and got a fix for
> previously. We are using that patch, but ran in to another case where the
> client sends out an OPEN_DOWNGRADE but never sends a CLOSE.
>
> Attached is a simple c program that we have been able to reproduce the bug
> with, along with a packet capture of what we see on the wire.
>
> To reproduce the bug:
> -compile the c code
> -execute the c code with:
>
> ./test ; cat testfile3 > /dev/nul
>
> -now if we try to remove the file we get a file in use error (server is
> using mandatory locking)
>
> Things to note:
>
> -if you just run the program without the immediate cat'ing of the file, the
> bug does not happen
> suggesting a timing issue
> -If you alter the program so the code mimics the cat of the file, the bug
> does not happen (ie, add an open, read file, close to the code).
> -If you run the program as described above, and then run it again without
> the "; cat testfile3 > /dev/nul", the kernel squeaks out the file close to
> the server when the code does the close.
>
> The attached packet capture is us doing:
>
> ./test ; cat testfile3 > /dev/null
> rm testfile3
> ./test
> rm testfile3
>
> where we are denied the rm the first time, but not the second.
>

Argh. This is a situation where the client shouldn't have called
OPEN_DOWNGRADE, but should have done a CLOSE. The issue is that the
client opens the file with OPEN4_SHARE_ACCESS_BOTH, so it is not
allowed to downgrade to OPEN4_SHARE_ACCESS_READ. Instead it should
have closed the file, and then used the delegation...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
