Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:58338 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753475AbbBZNmb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 08:42:31 -0500
Received: from tot-qpr-mailcore1.delacy.com ([172.27.56.68] helo=tot-qpr-mailcore1)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YQyhz-0000La-94
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 08:42:31 -0500
Received: from mail-yk0-f169.google.com ([209.85.160.169])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YQyhz-0005Xt-3H
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 08:42:31 -0500
Received: by ykp9 with SMTP id 9so4047521ykp.5
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 05:42:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
 <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
 <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
 <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
 <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
 <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
 <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com> <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>
From: Chris Perl <cperl@janestreet.com>
Date: Thu, 26 Feb 2015 08:42:10 -0500
Message-ID: <CAAih9mgbDhde-hoD0aCF2ZwSXZZvi53GOmbnWy-r0tJqjgamEQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> If you are saying that we're not making it clear enough that "you
> ignore these rules at your peril" then, fair enough, I'm sure Chuck
> would be able to add a line to the faq stating just that.

Yes, that's basically what I'm saying.  I doubt many end users of NFS
realize that, given default mount options on modern Linux
distributions, simply catting a file that may have just been updated
on another system can result in reading back extra bytes that don't
exist in the file.

I guess my main point is the notion of reading "stale" data vs reading
"corrupt" data from the cache.

> However if you are asking us for an extensive list of "this is what I
> can expect if I ignore these rules", then I don't think you will find
> much traction. Such a list would be committing us to defining a model
> for "non-close-to-open" semantics, which isn't of interest to me at
> least, and I doubt anyone else is interested in committing to
> maintaining that.

I was just asking if such a thing existed.  It sounds like it doesn't.
I don't expect you to produce one.

I, for one, simply was not aware that close-to-open cache consistency
required that if a file is open for writing on one client that it MUST
NOT be read by other clients at the same time (unless you potentially
want to read corrupt data).

Thanks for taking the time to discuss and clarify, its much appreciated.
