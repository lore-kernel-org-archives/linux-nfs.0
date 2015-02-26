Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:50809 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932472AbbBZOKg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 09:10:36 -0500
Received: from tot-qpr-mailcore1.delacy.com ([172.27.56.68] helo=tot-qpr-mailcore1)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YQz99-000529-Ky
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 09:10:35 -0500
Received: from mail-yk0-f179.google.com ([209.85.160.179])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YQz99-0006Uf-G6
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 09:10:35 -0500
Received: by ykt10 with SMTP id 10so4132245ykt.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 06:10:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAih9mgbDhde-hoD0aCF2ZwSXZZvi53GOmbnWy-r0tJqjgamEQ@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
 <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
 <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
 <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
 <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
 <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
 <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
 <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com> <CAAih9mgbDhde-hoD0aCF2ZwSXZZvi53GOmbnWy-r0tJqjgamEQ@mail.gmail.com>
From: Chris Perl <cperl@janestreet.com>
Date: Thu, 26 Feb 2015 09:10:13 -0500
Message-ID: <CAAih9mgBqLyNCPmjnXcYKXZGNfx0oZkyGZ3trNg6xmOV_+V1Dw@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> However if you are asking us for an extensive list of "this is what I
> can expect if I ignore these rules", then I don't think you will find
> much traction. Such a list would be committing us to defining a model
> for "non-close-to-open" semantics, which isn't of interest to me at
> least, and I doubt anyone else is interested in committing to
> maintaining that.

One more point on this.  I wasn't really asking for a list of what I
can expect if I ignore the rules (although I think pointing out that
reading corrupt data from the cache is worth mentioning), I was asking
what the rules for close-to-open consistency were so I can follow
them.  I now know one of them is that if a file is open for writing on
one client then it can't be read on another.  Are there others?
