Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:52349 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753606AbbBZMmN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 07:42:13 -0500
Received: from tot-qpr-mailcore2.delacy.com ([172.27.56.106] helo=tot-qpr-mailcore2)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YQxlc-0003hJ-Vi
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 07:42:13 -0500
Received: from mail-yh0-f42.google.com ([209.85.213.42])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YQxlc-00043P-Qv
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 07:42:12 -0500
Received: by yhaf73 with SMTP id f73so4264084yha.11
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 04:42:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
 <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
 <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
 <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
 <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com> <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
From: Chris Perl <cperl@janestreet.com>
Date: Thu, 26 Feb 2015 07:41:52 -0500
Message-ID: <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> Ok, thanks for helping me understand this a little more clearly.  For
>> my own edification, is there somewhere I can find the details where
>> these things are spelled out (or is it just somewhere in rfc1813 that
>> I haven't seen)?
>
> There is a short description here:
>     http://nfs.sourceforge.net/#faq_a8

Yes, thanks.  I had come across that when trying to do a little
research after your initial reply.

However, I was hoping for something with a little more detail.  For
example, you said earlier that "the close-to-open cache consistency
model is clear ...", which implied to me that there was a more formal
description somewhere outlining the semantics and constraints.  Or is
it just more of an implementation detail?

Also, reading that FAQ entry seems to reinforce my original notion
that a client reading a file that is being updated might get stale
data returned from its cache, but shouldn't get corrupt data returned
from its cache.  Perhaps the FAQ entry should be updated to explicitly
note that corrupt data can be returned?

FWIW, I realize that the use case I've given as a reproducer isn't
supported and isn't supposed to work.  I accept that and that is fine.
However, we do run into this problem in "everyday types of file
sharing" (to quote that FAQ).  Sometimes (not very often, but enough
that its annoying), someone will cat a file that is already in their
clients page cache, and it happens to be at just the wrong time,
resulting in corrupt data being read.
