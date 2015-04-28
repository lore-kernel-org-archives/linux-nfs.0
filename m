Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f49.google.com ([209.85.216.49]:33558 "EHLO
	mail-vn0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030729AbbD1Ryc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 13:54:32 -0400
Received: by vnbf1 with SMTP id f1so362832vnb.0
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2015 10:54:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150428174934.GA5887@lst.de>
References: <1430139014-28013-1-git-send-email-hch@lst.de>
	<1430139014-28013-3-git-send-email-hch@lst.de>
	<20150427203943.GI4083@fieldses.org>
	<20150427193008.1195d7dd@tlielax.poochiereds.net>
	<20150428081456.GA21413@lst.de>
	<20150428160353.GN4083@fieldses.org>
	<20150428174934.GA5887@lst.de>
Date: Tue, 28 Apr 2015 13:54:31 -0400
Message-ID: <CAHQdGtQfM3jOi5Ydu1MAhCe8J=XQ7aHDPPVZFpC_zTGZ+2G0eg@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfsd: fix pNFS return on close semantics
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        Jeff Layton <jlayton@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2015 at 1:49 PM, Christoph Hellwig <hch@lst.de> wrote:
>
> On Tue, Apr 28, 2015 at 12:03:53PM -0400, J. Bruce Fields wrote:
> > > I'm ok with a cc to stable, but it's a bit borderline.  Note that currently
> > > you even applied my two patches to your 4.2 incoming queue, not even 4.1..
> >
> > Yeah, those -incoming branches are random works-in-progress and will get
> > rebased frequently, I'll move the other to for-4.1 and leave this one
> > for 4.2.
>
> I would prefer if we could queue it up for 4.1 if possible.
>

The main reason why you may want these patches is that without
return-on-close, you typically can end up with layouts being cached in
knfsd without the filesystem being pinned. When you then unmount the
filesystem...

Cheers
  Trond
