Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:46384 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311AbaFYWeS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 18:34:18 -0400
Received: by mail-vc0-f173.google.com with SMTP id lf12so2660077vcb.32
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 15:34:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <029c01cf90c4$ebae6b60$c30b4220$@mindspring.com>
References: <029301cf90c0$4fabe660$ef03b320$@mindspring.com>
	<CAHQdGtSdQ3keA2UgiAbtWWUMvheWQ8oanpAt_evAY2DSkr+y+Q@mail.gmail.com>
	<029c01cf90c4$ebae6b60$c30b4220$@mindspring.com>
Date: Wed, 25 Jun 2014 18:34:17 -0400
Message-ID: <CAHQdGtRxORG5kn-9D1Bp7WZ80yF6jGL_M8yT+0KeJ7x-jyVojg@mail.gmail.com>
Subject: Re: Execute only permission issue with client
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 25, 2014 at 6:29 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
>> On Wed, Jun 25, 2014 at 5:56 PM, Frank Filz <ffilzlnx@mindspring.com>
>> wrote:
>> > Back a year ago or so, I ran the following test against Ganesha:
>> >
>> > http://www.tuxera.com/community/posix-test-suite/
>> >
>> > On NFS v4, one of the issues it tripped over was execute only files.
>> > Apparently the Linux v4 client doesn't make ACCESS calls in
>> > conjunction with an open system call, with the result that you can
>> > open an execute only file (per RFC 3530bis, the server is allowing
>> > such to allow clients to execute executables).
>>
>> That information is outdated. A wireshark dump should show that recent
>> Linux kernels include an ACCESS operation as part of the open() COMPOUND
>> and that it uses that information to distinguish between executable and read
>> access permissions.
>
> Oh, cool, do you know when that went in? I'll go look and see if I can find it...
>

It should be a feature of Linux 3.7 (Dec 2012) and newer kernels.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
