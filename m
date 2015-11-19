Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:36247 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbKSUwc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Nov 2015 15:52:32 -0500
Received: by obdgf3 with SMTP id gf3so71267207obd.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2015 12:52:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151119200651.GB8506@fieldses.org>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
	<1447761180-4250-32-git-send-email-jeff.layton@primarydata.com>
	<20151119200651.GB8506@fieldses.org>
Date: Thu, 19 Nov 2015 15:52:31 -0500
Message-ID: <CAHQdGtRS8OEUL5Rkcm8o5g7H7pCcCg8GpyMaURN6Ou+78tnf1A@mail.gmail.com>
Subject: Re: [PATCH v1 31/38] nfs: replace d_add with d_splice_alias in atomic_open
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 19, 2015 at 3:06 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Tue, Nov 17, 2015 at 06:52:53AM -0500, Jeff Layton wrote:
> > From: Peng Tao <tao.peng@primarydata.com>
> >
> > It's a trival change but follows knfsd export document that asks
> > for d_splice_alias during lookup.
>
> This is a bug even before you start exporting, isn't it?
>
> OK, I see, in the atomic_open case we're probably only dealing with a
> positive dentry for a regular file at this point, in which case
> d_splice_alias is really just d_add....
>
> I'm not sure this patch is really necessary, then.
>

d_splice_alias() also instantly reduces to d_add() whenever the
'inode' argument is NULL.

Cheers
  Trond
