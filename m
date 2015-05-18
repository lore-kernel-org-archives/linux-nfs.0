Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:36730 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331AbbERUjj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 May 2015 16:39:39 -0400
MIME-Version: 1.0
In-Reply-To: <20150514150925.GE12861@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
	<28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
	<20150514150925.GE12861@fieldses.org>
Date: Mon, 18 May 2015 22:39:37 +0200
Message-ID: <CAHpGcMLK+=Sd+5xS5bsq+7FffiKQAH_t53yAMpiukeVh1JB6Mw@mail.gmail.com>
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-14 17:09 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> Looks fine to me.
>
> From a quick check of
>
>         git://github.com/andreas-gruenbacher/richacl.git
>
> it looks like the userspace is all done too?

Yes, with pretty light testing.

> Do we have wireshark patches?

We do now:

https://code.wireshark.org/review/#/c/8526/1

> On Fri, Apr 24, 2015 at 01:04:17PM +0200, Andreas Gruenbacher wrote:
> Nit, but: I'd find a way to really emphasize this and put it in the very
> first sentence of the changelog and any documentation.  People keep
> missing it.

Okay, I'll try.

Thanks,
Andreas
