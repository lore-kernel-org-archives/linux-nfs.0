Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48212 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932721AbbERUnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2015 16:43:49 -0400
Date: Mon, 18 May 2015 16:43:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas =?utf-8?Q?Gr=C3=BCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
Message-ID: <20150518204348.GC31295@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
 <20150514150925.GE12861@fieldses.org>
 <CAHpGcMLK+=Sd+5xS5bsq+7FffiKQAH_t53yAMpiukeVh1JB6Mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHpGcMLK+=Sd+5xS5bsq+7FffiKQAH_t53yAMpiukeVh1JB6Mw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 18, 2015 at 10:39:37PM +0200, Andreas Grünbacher wrote:
> 2015-05-14 17:09 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > Looks fine to me.
> >
> > From a quick check of
> >
> >         git://github.com/andreas-gruenbacher/richacl.git
> >
> > it looks like the userspace is all done too?
> 
> Yes, with pretty light testing.
> 
> > Do we have wireshark patches?
> 
> We do now:
> 
> https://code.wireshark.org/review/#/c/8526/1

Great!--b.

> 
> > On Fri, Apr 24, 2015 at 01:04:17PM +0200, Andreas Gruenbacher wrote:
> > Nit, but: I'd find a way to really emphasize this and put it in the very
> > first sentence of the changelog and any documentation.  People keep
> > missing it.
> 
> Okay, I'll try.
> 
> Thanks,
> Andreas
