Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cpe-75-80-152-117.san.res.rr.com ([75.80.152.117]:60106 "EHLO
	NickAndBarb2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007Ab2HaPiS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2012 11:38:18 -0400
Date: Fri, 31 Aug 2012 08:32:06 -0700
From: Nick Pasich <Nick@NickAndBarb.net>
To: Pavel Shilovsky <piastryyy@gmail.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: WARNING: at fs/inode.c:280 drop_nlink+0x31/0x33()
Message-ID: <20120831153206.GA28908@NICK2>
References: <20120829162527.GA3635@NickAndBarb.net> <20120829151641.20cde4bc@corrin.poochiereds.net> <20120831043352.GA23663@NickAndBarb.net> <CAKywueSY+NOV3irDm9YxepeCyJJhh82o2mgmDLogr+hJPbaYig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKywueSY+NOV3irDm9YxepeCyJJhh82o2mgmDLogr+hJPbaYig@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 31, 2012 at 12:00:26PM +0400, Pavel Shilovsky wrote:
> 2012/8/31 Nick Pasich <Nick@nickandbarb.net>:
> > Jeff,
> >
> > I applied this patch to Kernel 3.5.3 from Pavel and the
> > the warning is gone with no problems.
> >
> > Thanks,
> >
> > --( Nick Pasich
> >
> > ##########################################################
> >
> > From df2d6b1fbf2401c5ee04f2ac143ea0954e3a87a6 Mon Sep 17 00:00:00 2001
> > From: Pavel Shilovsky <pshilovsky@samba.org>
> > Date: Fri, 13 Jul 2012 11:59:45 +0400
> > Subject: [PATCH] CIFS: Protect i_nlink from being negative
> >
> > that can cause warning messages.
> >
> > Signed-off-by: Pavel Shilovsky <pshilovsky@samba.org>
> > ---
> >  fs/cifs/inode.c |   13 +++++++++++--
> >  1 files changed, 11 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
> > index 7354877..88afb1a 100644
> > --- a/fs/cifs/inode.c
> > +++ b/fs/cifs/inode.c
> > @@ -1110,6 +1110,15 @@ undo_setattr:
> >                 goto out_close;
> >  }
> >
> > +/* copied from fs/nfs/dir.c with small changes */
> > +static void
> > +cifs_drop_nlink(struct inode *inode)
> > +{
> > +       spin_lock(&inode->i_lock);
> > +       if (inode->i_nlink > 0)
> > +               drop_nlink(inode);
> > +       spin_unlock(&inode->i_lock);
> > +}
> >
> >  /*
> >   * If dentry->d_inode is null (usually meaning the cached dentry
> > @@ -1166,13 +1175,13 @@ retry_std_delete:
> >  psx_del_no_retry:
> >                 if (!rc) {
> >                                 if (inode)
> > -                       drop_nlink(inode);
> > +                       cifs_drop_nlink(inode);
> >                 } else if (rc == -ENOENT) {
> >                                 d_drop(dentry);
> >                 } else if (rc == -ETXTBSY) {
> >                                 rc = cifs_rename_pending_delete(full_path, dentry, xid);
> >                                 if (rc == 0)
> > -                       drop_nlink(inode);
> > +                       cifs_drop_nlink(inode);
> >                 } else if ((rc == -EACCES) && (dosattr == 0) && inode) {
> >                                 attrs = kzalloc(sizeof(*attrs), GFP_KERNEL);
> >                                 if (attrs == NULL) {
> > --
> > 1.7.3.3
> >
> > ##########################################################
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> This one fixes only a part of the problem. Now we have another patch
> for this problem:
> 
> https://git.samba.org/sfrench/?p=sfrench/cifs-2.6.git;a=commitdiff;h=b7ca69289680cf631fb20b7d436467c4ec1153cd;hp=6dab7ede9390d4d937cb89feca932e4fd575d2da
> 
> -- 
> Best regards,
> Pavel Shilovsky.



Since I'm using kernel 3.5.3 , I get an error on hunk 7 of the patch.

I can do it by hand... But I want to check with you first.

Thanks,

--( Nick Pasich )--


####################################################################

Hmm...  Looks like a unified diff to me...
The text leading up to this was:
--------------------------
|From b7ca69289680cf631fb20b7d436467c4ec1153cd Mon Sep 17 00:00:00 2001
|From: Steve French <smfrench@gmail.com>
|Date: Fri, 3 Aug 2012 08:43:01 -0500
|Subject: [PATCH 1/1] CIFS: Protect i_nlink from being negative
|
|that can cause warning messages.  Pavel had initially
|suggested a smaller patch around drop_nlink, after
|a similar problem was discovered NFS.  Protecting
|additional places where nlink is touched was
|suggested by Jeff Layton and is included in this.
|
|Reviewed-by: Pavel Shilovsky <pshilovsky@samba.org>
|Reviewed-by: Jeff Layton <jlayton@redhat.com>
|Signed-off-by: Steve French <sfrench@us.ibm.com>
|Signed-off-by: Steve French <smfrench@gmail.com>
|---
| fs/cifs/inode.c |   24 ++++++++++++++++--------
| fs/cifs/link.c  |    2 ++
| 2 files changed, 18 insertions(+), 8 deletions(-)
|
|diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
|index 7354877..cb79c7e 100644
|--- a/fs/cifs/inode.c
|+++ b/fs/cifs/inode.c
--------------------------
Patching file fs/cifs/inode.c using Plan A...
Hunk #1 succeeded at 124.
Hunk #2 succeeded at 148.
Hunk #3 succeeded at 155.
Hunk #4 succeeded at 905 (offset 50 lines).
Hunk #5 succeeded at 1107 (offset -1 lines).
Hunk #6 succeeded at 1224 (offset 51 lines).
Hunk #7 FAILED at 1299.
1 out of 7 hunks FAILED -- saving rejects to file fs/cifs/inode.c.rej
Hmm...  The next patch looks like a unified diff to me...
The text leading up to this was:
--------------------------
|diff --git a/fs/cifs/link.c b/fs/cifs/link.c
|index 09e4b3a..e6ce3b1 100644
|--- a/fs/cifs/link.c
|+++ b/fs/cifs/link.c
--------------------------
Patching file fs/cifs/link.c using Plan A...
Hunk #1 succeeded at 433.
Hmm...  Ignoring the trailing garbage.
done


