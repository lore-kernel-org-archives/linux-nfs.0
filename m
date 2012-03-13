Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859Ab2CMUzg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Mar 2012 16:55:36 -0400
Date: Tue, 13 Mar 2012 16:55:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Peng Tao <bergwolf@gmail.com>
Cc: NeilBrown <neilb@suse.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Nick Piggin <npiggin@gmail.com>, Nick Piggin <npiggin@kernel.dk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120313205529.GC21991@fieldses.org>
References: <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org>
 <20110308181320.GA15566@fieldses.org>
 <20110310105821.GE22723@ZenIV.linux.org.uk>
 <20110311150749.2fa2be66@notabene.brown>
 <20120214170300.GA4309@fieldses.org>
 <20120215165633.GE12490@fieldses.org>
 <20120216140603.08cb4900@notabene.brown>
 <20120216223011.GA23997@fieldses.org>
 <CA+a=Yy7WgT37Gost38MrV-qtk8MgnTdqKmjBQDvRLGmuh59r3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CA+a=Yy7WgT37Gost38MrV-qtk8MgnTdqKmjBQDvRLGmuh59r3g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 18, 2012 at 12:34:14AM +0800, Peng Tao wrote:
> > diff --git a/fs/dcache.c b/fs/dcache.c
> > index f68e193..1fd2256 100644
> > --- a/fs/dcache.c
> > +++ b/fs/dcache.c
> > @@ -1602,9 +1602,8 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
> >
> >        if (inode && S_ISDIR(inode->i_mode)) {
> >                spin_lock(&inode->i_lock);
> > -               new = __d_find_alias(inode, 1);
> by replacing this, the want_discon argument is no longer in use. care
> to remove it as well?

Yep, both patches follow; Al, could you take these?

--b.
