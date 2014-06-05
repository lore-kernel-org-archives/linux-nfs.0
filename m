Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:63520 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaFEQ1X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 12:27:23 -0400
Received: by mail-qa0-f52.google.com with SMTP id cm18so1665910qab.39
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 09:27:22 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 5 Jun 2014 12:27:19 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Benny Halevy <bhalevy@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 8/9] NFSd: Protect addition to the file_hashtbl
Message-ID: <20140605122719.5ed5b380@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtTEZRjPKT4BGTTZXwhfYwNxZdY8g7HzDVOaVfkj=Aq6aA@mail.gmail.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
	<1401455373-18207-9-git-send-email-jlayton@primarydata.com>
	<20140605161222.GG8362@fieldses.org>
	<CAHQdGtTEZRjPKT4BGTTZXwhfYwNxZdY8g7HzDVOaVfkj=Aq6aA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Jun 2014 12:18:09 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, Jun 5, 2014 at 12:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Fri, May 30, 2014 at 09:09:32AM -0400, Jeff Layton wrote:
> >> From: Trond Myklebust <trond.myklebust@primarydata.com>
> >>
> >> Ensure that we only can have a single struct nfs4_file per inode
> >> in the file_hashtbl and make addition atomic with respect to lookup.
> >>
> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> ---
> >>  fs/nfsd/nfs4state.c | 46 +++++++++++++++++++++++++++++++++++-----------
> >>  1 file changed, 35 insertions(+), 11 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index a500033a2f87..553c2d6d48dc 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -2519,6 +2519,8 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
> >>  {
> >>       unsigned int hashval = file_hashval(ino);
> >>
> >> +     lockdep_assert_held(&state_lock);
> >> +
> >
> > Oops, lockdep points out we overlooked a deadlock here: this function
> > also calls igrab(), which takes the i_lock, the reverse ordering from
> > what we take in the delegation-break case.
> >
> > Dropping this patch for now.
> >
> 
> This was the reason for the delegation recall locking changes which
> are also part of the series.
> 
> That said, why do we need igrab here as opposed to just ihold()?
> 

Yeah, that would be a lot simpler. We certainly already have a
reference by virtue of the dentry in the filehandle so ihold is
reasonable. I'll change it to use that.

-- 
Jeff Layton <jlayton@primarydata.com>
