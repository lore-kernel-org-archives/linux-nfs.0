Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:53905 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbbBZN3x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 08:29:53 -0500
Received: by mail-vc0-f180.google.com with SMTP id im6so3881883vcb.11
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 05:29:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
	<CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
	<CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
	<CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
	<CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
	<CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
	<CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
	<CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
	<CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
Date: Thu, 26 Feb 2015 08:29:51 -0500
Message-ID: <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chris Perl <cperl@janestreet.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 26, 2015 at 7:41 AM, Chris Perl <cperl@janestreet.com> wrote:
>>> Ok, thanks for helping me understand this a little more clearly.  For
>>> my own edification, is there somewhere I can find the details where
>>> these things are spelled out (or is it just somewhere in rfc1813 that
>>> I haven't seen)?
>>
>> There is a short description here:
>>     http://nfs.sourceforge.net/#faq_a8
>
> Yes, thanks.  I had come across that when trying to do a little
> research after your initial reply.
>
> However, I was hoping for something with a little more detail.  For
> example, you said earlier that "the close-to-open cache consistency
> model is clear ...", which implied to me that there was a more formal
> description somewhere outlining the semantics and constraints.  Or is
> it just more of an implementation detail?
>
> Also, reading that FAQ entry seems to reinforce my original notion
> that a client reading a file that is being updated might get stale
> data returned from its cache, but shouldn't get corrupt data returned
> from its cache.  Perhaps the FAQ entry should be updated to explicitly
> note that corrupt data can be returned?
>
> FWIW, I realize that the use case I've given as a reproducer isn't
> supported and isn't supposed to work.  I accept that and that is fine.
> However, we do run into this problem in "everyday types of file
> sharing" (to quote that FAQ).  Sometimes (not very often, but enough
> that its annoying), someone will cat a file that is already in their
> clients page cache, and it happens to be at just the wrong time,
> resulting in corrupt data being read.

If you are saying that we're not making it clear enough that "you
ignore these rules at your peril" then, fair enough, I'm sure Chuck
would be able to add a line to the faq stating just that.

However if you are asking us for an extensive list of "this is what I
can expect if I ignore these rules", then I don't think you will find
much traction. Such a list would be committing us to defining a model
for "non-close-to-open" semantics, which isn't of interest to me at
least, and I doubt anyone else is interested in committing to
maintaining that.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
