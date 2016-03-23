Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from r00tworld.com ([212.85.137.150]:41545 "EHLO r00tworld.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534AbcCWSqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2016 14:46:30 -0400
From: "PaX Team" <pageexec@freemail.hu>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexey Dvoichenkov <xale@hyperplane.net>
Date: Wed, 23 Mar 2016 19:32:58 +0100
MIME-Version: 1.0
Subject: Re: nfs_super_set_maxbytes patch
Reply-to: pageexec@freemail.hu
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, spender@grsecurity.net
Message-ID: <56F2E15A.28679.B5D94B8@pageexec.freemail.hu>
In-reply-to: <20160318085525.07dac0c5e437d577bb53f1f0@hyperplane.net>
References: <20160317141307.531709bf667a915973060eae@hyperplane.net>, <CAHQdGtREL65zXvkdqJ8=hrSXWVyLBGCTAfdO02cXPsC6W26ZVQ@mail.gmail.com>, <20160318085525.07dac0c5e437d577bb53f1f0@hyperplane.net>
Content-type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18 Mar 2016 at 8:55, Alexey Dvoichenkov wrote:

> On Thu, 17 Mar 2016 09:20:14 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > > --- fs/nfs/internal.h.orig      2015-11-02 10:05:25.000000000 +1000
> > > +++ fs/nfs/internal.h   2016-01-02 03:19:04.599120855 +1000
> > > @@ -612,9 +612,9 @@
> > >  static inline
> > >  void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
> > >  {
> > > +       if (maxfilesize > MAX_LFS_FILESIZE || maxfilesize == 0)
> > > +               maxfilesize = MAX_LFS_FILESIZE;
> > >         sb->s_maxbytes = (loff_t)maxfilesize;
> > > -       if (sb->s_maxbytes > MAX_LFS_FILESIZE || sb->s_maxbytes <= 0)
> > > -               sb->s_maxbytes = MAX_LFS_FILESIZE;
> > >  }
> > >
> > 
> > Why are we having to change _correct_ code in order to work with a
> > checking tool?

first of all, it's correct in that it relies on implementation defined
behaviour and not UB. C99 6.3.1.3 says:

    Otherwise, the new type is signed and the value cannot be represented
    in it; either the result is implementation-defined or an implementation-
    defined signal is raised.

it's still unfortunate of course as the reliance on the above is trivially
avoidable (and would also satisfy the size overflow plugin which otherwise
chooses the other possible behaviour). all that said, i think the bigger
problem with this code pattern is that it's putting the cart before the
horses so to speak, so it'd be better if it was changed for that reason
alone.

