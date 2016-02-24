Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:64950 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbcBXPIl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Feb 2016 10:08:41 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: y2038@lists.linaro.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Deepa Dinamani <deepa.kernel@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [Y2038] [PATCH 8/8] net: sunrpc: Replace CURRENT_TIME by current_fs_time()
Date: Wed, 24 Feb 2016 16:08:23 +0100
Message-ID: <3612929.btSLWR6eWu@wuerfel>
In-Reply-To: <CAHQdGtR26gqy7GzWui-bnb+W5W1PnUL_=okBZwz+XFmj_Q4A3A@mail.gmail.com>
References: <1456154274-30487-1-git-send-email-deepa.kernel@gmail.com> <1456154274-30487-9-git-send-email-deepa.kernel@gmail.com> <CAHQdGtR26gqy7GzWui-bnb+W5W1PnUL_=okBZwz+XFmj_Q4A3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 22 February 2016 10:34:31 Trond Myklebust wrote:
> > diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> > index 31789ef..bab3187 100644
> > --- a/net/sunrpc/rpc_pipe.c
> > +++ b/net/sunrpc/rpc_pipe.c
> > @@ -477,7 +477,9 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
> >                 return NULL;
> >         inode->i_ino = get_next_ino();
> >         inode->i_mode = mode;
> > -       inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
> > +       inode->i_atime = current_fs_time(sb);
> > +       inode->i_mtime = inode->i_atime;
> > +       inode->i_ctime = inode->i_atime;
> >         switch (mode & S_IFMT) {
> >         case S_IFDIR:
> >                 inode->i_fop = &simple_dir_operations;
> 
> Why would we care? This is a pseudo-fs. There is no expectation w.r.t.
> timestamp accuracy or resolution.

As Deepa said, the primary goal is to unify the interface, so we have only
one place function that handles setting the time in an inode, and we want
to avoid CURRENT_TIME, as that is currently used in a couple of places
for things other than inode timestamps that we don't want to convert to
64-bit times at the same time.

current_fs_time() has a very small overhead compared to CURRENT_TIME,
if you think it's worth avoiding that, we could introduce a
current_pseudo_fs_time() function that does not take a superblock
argument but is more tied to inode timestamps than CURRENT_TIME is.

	Arnd
