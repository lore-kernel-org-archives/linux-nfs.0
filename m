Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:57440 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754445AbbBZQAq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 11:00:46 -0500
Received: from tot-qpr-mailcore2.delacy.com ([172.27.56.106] helo=tot-qpr-mailcore2)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YR0rm-00065X-44
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 11:00:46 -0500
Received: from mail-yh0-f50.google.com ([209.85.213.50])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YR0rl-0001kR-V7
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 11:00:46 -0500
Received: by yhoa41 with SMTP id a41so4917967yho.9
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 08:00:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424964871.10136.6.camel@primarydata.com>
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
 <1424964150.13431.57.camel@willson.usersys.redhat.com> <1424964871.10136.6.camel@primarydata.com>
From: Chris Perl <cperl@janestreet.com>
Date: Thu, 26 Feb 2015 11:00:25 -0500
Message-ID: <CAAih9mi4NpzpA-EzbkKxJ=cJHtZWjzJ8GHTz4gwUNx2MStooFQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> It is up to you to ensure that you don't set up such a situation, just
> like it is also your responsibility to ensure that you don't run 2
> applications that do read-modify-writes to the same file on a regular
> POSIX filesystem.
>
> This is a rule that has worked just fine for the NFS community for more
> than 30 years. It isn't anything new that we're only adding to Linux.

I'm not trying to be annoying and hope I'm not coming across as such.

Given that I've used NFS for many years being blissfully unaware of
the close-to-open cache consistency requirement you've described (it
seems to work most of the time!), I'm generally curious if there are
other such rules I must follow or if the one we've been discussing is
the only such rule.
