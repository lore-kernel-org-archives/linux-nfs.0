Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753931Ab3KEKnE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Nov 2013 05:43:04 -0500
Date: Tue, 5 Nov 2013 05:42:56 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        chutzpah@gentoo.org, liguangc@cn.ibm.com
Subject: Re: [PATCH] [RFC] vfs: don't revalidate dentries that serve as
 mountpoints
Message-ID: <20131105054256.59328806@tlielax.poochiereds.net>
In-Reply-To: <CADT32eJ_cqej0wnjKOZk1x0UtRqoNy201hFt8hQLLShjcbp3Dg@mail.gmail.com>
References: <1383614186-8039-1-git-send-email-jlayton@redhat.com>
	<CADT32eJ_cqej0wnjKOZk1x0UtRqoNy201hFt8hQLLShjcbp3Dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 4 Nov 2013 21:00:23 -0600
Shirish Pargaonkar <shirishpargaonkar@gmail.com> wrote:

> For a similar issue in cifs vfs (samba bugzilla 8950), I was going to try
> unset the bit DCACHE_OP_REVALIDATE of d_flags of the
> dentry.  Would something like work for the mountpoint dentry?
> 
> 

I don't think that's the same issue at all. The problem there is that
you need to instantiate a dentry for the root of the mount on the
client, when you don't have any information about the parents.

In this case, we have dentries that are acting as mountpoints that were
getting invalidated.

> 
> On Mon, Nov 4, 2013 at 7:16 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > We had a couple of reports of people that are mounting NFS filesystems,
> > and then bind mounting certain local files onto dentries in that nfs
> > mount (sort of like a poor-man's unionmount).
> >
> > This all works well until the dentry serving as the mountpoint fails
> > d_revalidate. The dentry will end up being invalidated which makes the
> > bind mount unreachable via pathwalk.
> >
> > It doesn't make much sense to me to allow dentries to serve as
> > mountpoints to end up invalidated, so there's no real point in
> > attempting to d_revalidate them at all.
> >
> > Reported-by: Patrick McLean <chutzpah@gentoo.org>
> > Reported-by: Guang Cheng Li <liguangc@cn.ibm.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/namei.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/fs/namei.c b/fs/namei.c
> > index caa2805..5b10ad0 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -585,6 +585,9 @@ drop_root_mnt:
> >
> >  static inline int d_revalidate(struct dentry *dentry, unsigned int flags)
> >  {
> > +       /* dentries that serve as mountpoints are always considered valid */
> > +       if (d_mountpoint(dentry))
> > +               return 1;
> >         return dentry->d_op->d_revalidate(dentry, flags);
> >  }
> >
> > --
> > 1.8.3.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@redhat.com>
