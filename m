Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:55486 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758379AbaDXQqh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 12:46:37 -0400
Received: by mail-vc0-f178.google.com with SMTP id hu19so3261592vcb.37
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 09:46:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140424163414.GA16429@fieldses.org>
References: <20140424062516.GA8891@fieldses.org>
	<CAHQdGtRfybuqsxiS=Hd4Stkm1ex13f6SeEk5XbQcy35UZStHRA@mail.gmail.com>
	<20140424153116.GA15459@fieldses.org>
	<20140424163414.GA16429@fieldses.org>
Date: Thu, 24 Apr 2014 12:46:36 -0400
Message-ID: <CAHQdGtQ_WMRrEWb5Lq8zS7A6eeuN5_UrEtB9baOfciCbuNSLjA@mail.gmail.com>
Subject: Re: nfsd bug fixes for 3.15
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Layton Jeff <jlayton@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 24, 2014 at 12:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Apr 24, 2014 at 11:31:16AM -0400, J. Bruce Fields wrote:
>> On Thu, Apr 24, 2014 at 06:51:03AM -0400, Trond Myklebust wrote:
>> > Hi Bruce,
>> >
>> > On Thu, Apr 24, 2014 at 2:25 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > > Please pull the following bug fixes for 3.15 from:
>> > >
>> > >   git://linux-nfs.org/~bfields/linux.git for-3.15
>> > >
>> > > Three small nfsd bugfixes (including one locks.c fix for a bug triggered
>> > > only from nfsd).
>> > >
>> > > Jeff's patches are for long-existing problems that became easier to
>> > > trigger since the addition of vfs delegation support.
>> > >
>> > > --b.
>> > >
>> > > ----------------------------------------------------------------
>> > > J. Bruce Fields (1):
>> > >       Revert "nfsd4: fix nfs4err_resource in 4.1 case"
>> > >
>> >
>> > Wait. Why?
>>
>> Have you changed your mind since our previous discussion, or just
>> forgotten it?  (Or did I screw up and revert the wrong commit?)  See
>>
>>       http://mid.gmane.org/<BAD6904F-A82A-4FBC-807F-16560B2A23E0@primarydata.com>
>>
>> > NFS4ERR_RESOURCE breaks the Linux client.
>>
>> This returns us to pre-3.15 behavior so shouldn't introduce any new
>> breakage.
>>
>> Fundamentally the problem is that we're returning an error in cases that
>> shouldn't succeed, and rather than replacing one incorrect error by
>
> s/shouldn't/should/, apologies!--b.
>
>> another it seemed better to wait for a proper fix.
>>
>> --b.

I really shouldn't try to read my email before 8am (or at least not
before my third espresso). I was confusing this with the
NFS4ERR_STALE_STATEID problem that was merged as part of the same
pull.
Reverting the NFS4ERR_RESOURCE patch is fine.

Apologies,
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
