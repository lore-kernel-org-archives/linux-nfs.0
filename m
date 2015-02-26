Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:46069 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbbBZXnj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 18:43:39 -0500
Received: by mail-vc0-f169.google.com with SMTP id kv19so5262655vcb.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 15:43:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAih9mi4NpzpA-EzbkKxJ=cJHtZWjzJ8GHTz4gwUNx2MStooFQ@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
	<CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
	<CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
	<CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
	<CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
	<CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
	<CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
	<CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
	<CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
	<CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>
	<CAAih9mgbDhde-hoD0aCF2ZwSXZZvi53GOmbnWy-r0tJqjgamEQ@mail.gmail.com>
	<CAAih9mgBqLyNCPmjnXcYKXZGNfx0oZkyGZ3trNg6xmOV_+V1Dw@mail.gmail.com>
	<1424964150.13431.57.camel@willson.usersys.redhat.com>
	<1424964871.10136.6.camel@primarydata.com>
	<CAAih9mi4NpzpA-EzbkKxJ=cJHtZWjzJ8GHTz4gwUNx2MStooFQ@mail.gmail.com>
Date: Thu, 26 Feb 2015 18:43:38 -0500
Message-ID: <CAHQdGtRzT9yuJxNw5NPk4oOnV2_q+cx=aRhRZcT_g_uQWNQkhw@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chris Perl <cperl@janestreet.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 26, 2015 at 11:00 AM, Chris Perl <cperl@janestreet.com> wrote:
>> It is up to you to ensure that you don't set up such a situation, just
>> like it is also your responsibility to ensure that you don't run 2
>> applications that do read-modify-writes to the same file on a regular
>> POSIX filesystem.
>>
>> This is a rule that has worked just fine for the NFS community for more
>> than 30 years. It isn't anything new that we're only adding to Linux.
>
> I'm not trying to be annoying and hope I'm not coming across as such.
>
> Given that I've used NFS for many years being blissfully unaware of
> the close-to-open cache consistency requirement you've described (it
> seems to work most of the time!), I'm generally curious if there are
> other such rules I must follow or if the one we've been discussing is
> the only such rule.

The only other things that I can think of are:

1) Attributes are generally not immediately updated on clients. Even
if you specify 'noac', there is no locking that can ensure size
changes, for instance, are reflected well enough on the client to
ensure perfect O_APPEND semantics.
2) Readdir results are unreliable when the directory is being updated
on the server or on other clients. You should still be able to depend
on O_EXCL file create semantics, though.
3) the lack of flock() type locks. We have to emulate them using byte
range locks, which means that under NFS the fcntl() and flock() locks
can and will conflict with one another.
4) file notifications generally do not work well, since there is no
protocol support for that either

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
