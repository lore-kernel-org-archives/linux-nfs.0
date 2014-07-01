Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f172.google.com ([209.85.128.172]:33760 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbaGAUNk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 16:13:40 -0400
Received: by mail-ve0-f172.google.com with SMTP id jz11so10204937veb.17
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 13:13:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <012801cf9560$29ede7d0$7dc9b770$@mindspring.com>
References: <029301cf90c0$4fabe660$ef03b320$@mindspring.com>
	<CAHQdGtSdQ3keA2UgiAbtWWUMvheWQ8oanpAt_evAY2DSkr+y+Q@mail.gmail.com>
	<029c01cf90c4$ebae6b60$c30b4220$@mindspring.com>
	<CAHQdGtRxORG5kn-9D1Bp7WZ80yF6jGL_M8yT+0KeJ7x-jyVojg@mail.gmail.com>
	<012801cf9560$29ede7d0$7dc9b770$@mindspring.com>
Date: Tue, 1 Jul 2014 16:13:39 -0400
Message-ID: <CAHQdGtSMEGvsKt-k+LJM9w-PNu6dTOQABocX-u=10Uyj1tehwg@mail.gmail.com>
Subject: Re: Execute only permission issue with client
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 1, 2014 at 3:10 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
> Ok, got another question related...
>
> I am running a test that does make the following system call:
>
> open("/mnt/foo", O_CREAT | O_TRUNC | O_RDWR, 0);
>
> This fails (at least when run from my Fedora 20 client, against either Ganesha OR knfsd).

The test fails, or the open() fails?

> When I look at a wireshark trace, I see that the sequence of ops in the COMPOUND is:
>
> OPEN, ACCESS
>
> I would expect the ACCESS to fail since the created file has mode 000.

According to POSIX, the above open() system call should succeed if a
file /mnt/foo already exists and that file's ACL/mode is compatible
with the requested O_RDWR access pattern. The open() should also
succeed if a file /mnt/foo does not exist, and your process has valid
file create permissions for the directory /mnt (it will create a file
/mnt/foo with the mode bits set to 0).

In both cases, the result should be a valid file descriptor that can
be used for reading and writing.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
