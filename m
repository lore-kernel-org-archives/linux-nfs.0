Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:46827 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755442AbcCRFza (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Mar 2016 01:55:30 -0400
Date: Fri, 18 Mar 2016 08:55:25 +0300
From: Alexey Dvoichenkov <xale@hyperplane.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, spender@grsecurity.net
Subject: Re: nfs_super_set_maxbytes patch
Message-Id: <20160318085525.07dac0c5e437d577bb53f1f0@hyperplane.net>
In-Reply-To: <CAHQdGtREL65zXvkdqJ8=hrSXWVyLBGCTAfdO02cXPsC6W26ZVQ@mail.gmail.com>
References: <20160317141307.531709bf667a915973060eae@hyperplane.net>
	<CAHQdGtREL65zXvkdqJ8=hrSXWVyLBGCTAfdO02cXPsC6W26ZVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Mar 2016 09:20:14 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, Mar 17, 2016 at 7:13 AM, Alexey Dvoichenkov <xale@hyperplane.net> wrote:
> > Hello. I've found a small bug in what appears to be the maximum file
> > size handling code.
> >
> > The problem here, as far as I understand, is that casting from an
> > unsigned type to a signed type, when the latter cannot represent the
> > arithmetic value of the former, is UB. In practice, under the PaX size
> > overflow protection, this code crashes when mounting from FreeBSD
> > servers that send "all ones" in the size field.
> >
> > Not sure I'm doing things right with the list and I'm not subscribed, so
> > please CC.
> >
> > The fix should look something like this:
> >
> > --- fs/nfs/internal.h.orig      2015-11-02 10:05:25.000000000 +1000
> > +++ fs/nfs/internal.h   2016-01-02 03:19:04.599120855 +1000
> > @@ -612,9 +612,9 @@
> >  static inline
> >  void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
> >  {
> > +       if (maxfilesize > MAX_LFS_FILESIZE || maxfilesize == 0)
> > +               maxfilesize = MAX_LFS_FILESIZE;
> >         sb->s_maxbytes = (loff_t)maxfilesize;
> > -       if (sb->s_maxbytes > MAX_LFS_FILESIZE || sb->s_maxbytes <= 0)
> > -               sb->s_maxbytes = MAX_LFS_FILESIZE;
> >  }
> >
> 
> Why are we having to change _correct_ code in order to work with a
> checking tool?

Well, as far as I understand the standard, this cast may result in
undefined behaviour, which in my case it does. The fact that the code
crashes only under PaX, but not when compiled "normally", is a
compiler-dependent detail. So I'm not sure, in what sense is the code
correct?

On the other hand, I understand it may be annoying to fix this sort of
virtually harmless stuff. Then, perhaps, another reason to change it is
that in practice people use GRSEC with NFS and things will break.

-- AD
