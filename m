Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753275Ab2HaQVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Aug 2012 12:21:45 -0400
Date: Fri, 31 Aug 2012 09:21:38 -0700
From: Jeff Layton <jlayton@redhat.com>
To: Nick Pasich <Nick@NickAndBarb.net>
Cc: Pavel Shilovsky <piastryyy@gmail.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: WARNING: at fs/inode.c:280 drop_nlink+0x31/0x33()
Message-ID: <20120831092138.47668603@corrin.poochiereds.net>
In-Reply-To: <20120831153206.GA28908@NICK2>
References: <20120829162527.GA3635@NickAndBarb.net>
	<20120829151641.20cde4bc@corrin.poochiereds.net>
	<20120831043352.GA23663@NickAndBarb.net>
	<CAKywueSY+NOV3irDm9YxepeCyJJhh82o2mgmDLogr+hJPbaYig@mail.gmail.com>
	<20120831153206.GA28908@NICK2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 31 Aug 2012 08:32:06 -0700
Nick Pasich <Nick@NickAndBarb.net> wrote:

> On Fri, Aug 31, 2012 at 12:00:26PM +0400, Pavel Shilovsky wrote:
> > 2012/8/31 Nick Pasich <Nick@nickandbarb.net>:
> > > Jeff,
> > >
> > > I applied this patch to Kernel 3.5.3 from Pavel and the
> > > the warning is gone with no problems.
> > >
> > > Thanks,
> > >
> > > --( Nick Pasich
> > >
> > > ##########################################################
> > >
> > > From df2d6b1fbf2401c5ee04f2ac143ea0954e3a87a6 Mon Sep 17 00:00:00 2001
> > > From: Pavel Shilovsky <pshilovsky@samba.org>
> > > Date: Fri, 13 Jul 2012 11:59:45 +0400
> > > Subject: [PATCH] CIFS: Protect i_nlink from being negative
> > >
> > > that can cause warning messages.
> > >
> > > Signed-off-by: Pavel Shilovsky <pshilovsky@samba.org>
> > > ---
> > >  fs/cifs/inode.c |   13 +++++++++++--
> > >  1 files changed, 11 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
> > > index 7354877..88afb1a 100644
> > > --- a/fs/cifs/inode.c
> > > +++ b/fs/cifs/inode.c
> > > @@ -1110,6 +1110,15 @@ undo_setattr:
> > >                 goto out_close;
> > >  }
> > >
> > > +/* copied from fs/nfs/dir.c with small changes */
> > > +static void
> > > +cifs_drop_nlink(struct inode *inode)
> > > +{
> > > +       spin_lock(&inode->i_lock);
> > > +       if (inode->i_nlink > 0)
> > > +               drop_nlink(inode);
> > > +       spin_unlock(&inode->i_lock);
> > > +}
> > >
> > >  /*
> > >   * If dentry->d_inode is null (usually meaning the cached dentry
> > > @@ -1166,13 +1175,13 @@ retry_std_delete:
> > >  psx_del_no_retry:
> > >                 if (!rc) {
> > >                                 if (inode)
> > > -                       drop_nlink(inode);
> > > +                       cifs_drop_nlink(inode);
> > >                 } else if (rc == -ENOENT) {
> > >                                 d_drop(dentry);
> > >                 } else if (rc == -ETXTBSY) {
> > >                                 rc = cifs_rename_pending_delete(full_path, dentry, xid);
> > >                                 if (rc == 0)
> > > -                       drop_nlink(inode);
> > > +                       cifs_drop_nlink(inode);
> > >                 } else if ((rc == -EACCES) && (dosattr == 0) && inode) {
> > >                                 attrs = kzalloc(sizeof(*attrs), GFP_KERNEL);
> > >                                 if (attrs == NULL) {
> > > --
> > > 1.7.3.3
> > >
> > > ##########################################################
> > >
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > This one fixes only a part of the problem. Now we have another patch
> > for this problem:
> > 
> > https://git.samba.org/sfrench/?p=sfrench/cifs-2.6.git;a=commitdiff;h=b7ca69289680cf631fb20b7d436467c4ec1153cd;hp=6dab7ede9390d4d937cb89feca932e4fd575d2da
> > 
> > -- 
> > Best regards,
> > Pavel Shilovsky.
> 
> 
> 
> Since I'm using kernel 3.5.3 , I get an error on hunk 7 of the patch.
> 
> I can do it by hand... But I want to check with you first.
> 
> Thanks,
> 
> --( Nick Pasich )--
> 

If you fix it up by hand, consider submitting it as a backport for the
stable series as well.

-- 
Jeff Layton <jlayton@redhat.com>
