Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34970 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758427AbbKSU7f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Nov 2015 15:59:35 -0500
Received: by qgec40 with SMTP id c40so60054906qge.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2015 12:59:34 -0800 (PST)
Date: Thu, 19 Nov 2015 15:59:31 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1 31/38] nfs: replace d_add with d_splice_alias in
 atomic_open
Message-ID: <20151119155931.2535b795@tlielax.poochiereds.net>
In-Reply-To: <20151119200651.GB8506@fieldses.org>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
	<1447761180-4250-32-git-send-email-jeff.layton@primarydata.com>
	<20151119200651.GB8506@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 19 Nov 2015 15:06:51 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

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
> --b.
> 
> 
> > 
> > Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> > ---
> >  fs/nfs/dir.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index ce5a21861074..a4df1137878e 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -1534,7 +1534,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
> >  		switch (err) {
> >  		case -ENOENT:
> >  			d_drop(dentry);
> > -			d_add(dentry, NULL);
> > +			d_splice_alias(NULL, dentry);
> >  			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
> >  			break;
> >  		case -EISDIR:
> > -- 
> > 2.4.3

Ahh right -- good point. d_splice_alias does this:

        if (!inode) {
                __d_instantiate(dentry, NULL);
                goto out;
        }
[...]
out:
	security_d_instantiate(dentry, inode);
        d_rehash(dentry);
        return NULL;

...which is exactly what d_add does. So yeah, that change isn't
strictly necessary. Still, it might be more future-proof to use
d_splice_alias there if the semantics ever change...

-- 
Jeff Layton <jlayton@poochiereds.net>
