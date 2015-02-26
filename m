Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:45815 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbbBZPef (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 10:34:35 -0500
Received: by iecat20 with SMTP id at20so16599503iec.12
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 07:34:35 -0800 (PST)
Message-ID: <1424964871.10136.6.camel@primarydata.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Simo Sorce <simo@redhat.com>
Cc: Chris Perl <cperl@janestreet.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Date: Thu, 26 Feb 2015 10:34:31 -0500
In-Reply-To: <1424964150.13431.57.camel@willson.usersys.redhat.com>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2015-02-26 at 10:22 -0500, Simo Sorce wrote:
> On Thu, 2015-02-26 at 09:10 -0500, Chris Perl wrote:
> > > However if you are asking us for an extensive list of "this is what I
> > > can expect if I ignore these rules", then I don't think you will find
> > > much traction. Such a list would be committing us to defining a model
> > > for "non-close-to-open" semantics, which isn't of interest to me at
> > > least, and I doubt anyone else is interested in committing to
> > > maintaining that.
> > 
> > One more point on this.  I wasn't really asking for a list of what I
> > can expect if I ignore the rules (although I think pointing out that
> > reading corrupt data from the cache is worth mentioning), I was asking
> > what the rules for close-to-open consistency were so I can follow
> > them.  I now know one of them is that if a file is open for writing on
> > one client then it can't be read on another.  Are there others?
> 
> Is this a rule or a bug ?
> How does an application know that the file is open elsewhere for
> writing ?

It is up to you to ensure that you don't set up such a situation, just
like it is also your responsibility to ensure that you don't run 2
applications that do read-modify-writes to the same file on a regular
POSIX filesystem.

This is a rule that has worked just fine for the NFS community for more
than 30 years. It isn't anything new that we're only adding to Linux.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




