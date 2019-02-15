Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92EA2C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 20:09:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6A4FB222BE
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 20:09:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389737AbfBOUJj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 15:09:39 -0500
Received: from fieldses.org ([173.255.197.46]:39644 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726317AbfBOUJj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 15:09:39 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 076B8BD3; Fri, 15 Feb 2019 15:09:38 -0500 (EST)
Date:   Fri, 15 Feb 2019 15:09:38 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Jeff Layton <jlayton@kernel.org>, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Pavel Shilovsky <piastryyy@gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
Message-ID: <20190215200938.GC22354@fieldses.org>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org>
 <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208201649.GA23657@fieldses.org>
 <CAOQ4uxjV2FahWEtESJJRwz0kkBZxkKosCnURzj2HtuKNwhscng@mail.gmail.com>
 <20190214205100.GB9216@fieldses.org>
 <CAOQ4uxhORdbODd01xrm6frbBUU1-U=5Rh86ZU63CrybpdyCL+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxhORdbODd01xrm6frbBUU1-U=5Rh86ZU63CrybpdyCL+A@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 15, 2019 at 09:31:48AM +0200, Amir Goldstein wrote:
> On Thu, Feb 14, 2019 at 10:51 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Feb 08, 2019 at 10:31:07PM +0200, Amir Goldstein wrote:
> > > On Fri, Feb 8, 2019 at 10:17 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > > On Fri, Feb 08, 2019 at 10:02:43PM +0200, Amir Goldstein wrote:
> > > > > On Fri, Feb 8, 2019 at 5:51 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > > > > On Fri, Feb 08, 2019 at 04:45:46PM +0200, Amir Goldstein wrote:
> > > > > > > - check_conflicting_open() is changed to use inode_is_open_for_read()
> > > > > > >   instead of checking d_count and i_count.
> > > > > >
> > > > > > Independently of the rest, I'd love to do away with those
> > > > > > d_count/i_count checks.  What's inode_is_open_for_read()?
> > > > > >
> > > > >
> > > > > It would look maybe something like this:
> > > > >
> > > > > static inline bool file_is_open_for_read(const struct inode *file)
> > > > > {
> > > > >         struct inode *inode = file_inode(file);
> > > > >         int countself = (file->f_mode & (FMODE_READ | FMODE_WRITE)) ==
> > > > > FMODE_READ) ? 1 : 0;
> > > > >
> > > > >         return atomic_read(&inode->i_readcount) > countself;
> > > > > }
> > > > >
> > > > > And it would allow for acquiring F_WRLCK lease if other
> > > > > instances of inode are open O_PATH.
> > > > > A slight change of semantics that seems harmless(?)
> > > > > and will allow some flexibility.
> > > >
> > > > How did I not know about i_readcount?  (Looking)  I guess it would mean
> > > > adding some dependence on CONFIG_IMA, hm.
> > > >
> > >
> > > Yes, or we remove ifdef CONFIG_IMA from i_readcount.
> > > I am not sure if the concern was size of struct inode
> > > (shouldn't increase on 64bit arch) or the accounting on
> > > open/close. The impact doesn't look significant (?)..
> >
> > Looks like the original patch was d984ea604943bb "fs: move i_readcount".
> > I did some googling around and looked at the discussion summarized by
> > https://lwn.net/Articles/410895/ but can't find useful discussion of
> > i_readcount impact.
> >
> > Looks like CONFIG_IMA is on in Fedora and RHEL, for what it's worth.
> >
> > Maybe something like this?
> >
> > --b.
> >
> > commit 02cfda99ed8c
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Thu Feb 14 15:02:02 2019 -0500
> >
> >     locks: use i_readcount to detect lease conflicts
> >
> >     The lease code currently uses the inode and dentry refcounts to detect
> >     whether someone has a file open for read.  This seems fragile.  Use
> >     i_readcount instead.
> >
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >
> > diff --git a/fs/locks.c b/fs/locks.c
> > index ff6af2c32601..299abad65545 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -1769,8 +1769,7 @@ check_conflicting_open(const struct dentry *dentry, const long arg, int flags)
> >         if ((arg == F_RDLCK) && inode_is_open_for_write(inode))
> >                 return -EAGAIN;
> >
> > -       if ((arg == F_WRLCK) && ((d_count(dentry) > 1) ||
> > -           (atomic_read(&inode->i_count) > 1)))
> > +       if ((arg == F_WRLCK) && (atomic_read(&inode->i_readcount) > 1))
> >                 ret = -EAGAIN;
> 
> Alas, i_readcount is not the count of file opens for read, it is the count
> of file opens O_RDONLY, so this is incorrect wrt conflict with other writers.

Whoops, thanks!

> I guess since there is a full smp_mb() before this check, then you
> can check (i_readcount + i_writecount) > 1 || (i_writecount < 0)
> 
> You can also check if caller itself is O_RDONLY to know if self
> count is expect to be in i_readcount or i_writecount, but not sure
> it is worth the trouble.

I don't know, it still looks reasonable.  I'll fool around with it.

--b.
