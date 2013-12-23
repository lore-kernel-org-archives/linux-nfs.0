Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy9-pub.mail.unifiedlayer.com ([69.89.24.6]:36679 "HELO
	oproxy9-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756986Ab3LWGrA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Dec 2013 01:47:00 -0500
Message-ID: <1387780809.3991.21.camel@slavad-ubuntu>
Subject: Re: [PATCH 21/21] hfsplus: remove can_set_xattr
From: Vyacheslav Dubeyko <slava@dubeyko.com>
Reply-To: slava@dubeyko.com
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
Date: Mon, 23 Dec 2013 10:40:09 +0400
In-Reply-To: <20131222192818.GA32565@infradead.org>
References: <20131220131635.650823732@bombadil.infradead.org>
	 <20131220132524.900291394@bombadil.infradead.org>
	 <636E01BC-12FD-452B-8B1C-320B6EADAEFD@dubeyko.com>
	 <20131222192818.GA32565@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2013-12-22 at 11:28 -0800, Christoph Hellwig wrote:

> 
> > > -	if (!strncmp(name, XATTR_MAC_OSX_PREFIX, XATTR_MAC_OSX_PREFIX_LEN)) {
> > > -		/*
> > > -		 * This makes sure that we aren't trying to set an
> > > -		 * attribute in a different namespace by prefixing it
> > > -		 * with "osx."
> > > -		 */
> > > -		if (is_known_namespace(name + XATTR_MAC_OSX_PREFIX_LEN))
> > > -			return -EOPNOTSUPP;
> > 
> > I think that this check is important. It forbids such combinations as "osx.system.*" or
> > "osx.trusted.*", for example. Because "osx.*" is virtual namespace for xattrs that
> > it can be under Mac OS X. If you want to set xattr from "system.*" namespace, for example,
> > then you need to use another handler. And such namespace should be without
> > addition of "osx." prefix.
> 
> Right, and we keep exactly the check, just in a different place.
> 

Maybe I missed something, but I can see that this check is removed only.
Could you point out the code in your patch that it checks and forbids
such combination as "osx.security.*", "osx.trusted.*" and so on?

I can see that is_known_namespace() is called for
hfsplus_xattr_osx_handler only. But this method doesn't contain
above-mentioned check. Moreover, hfsplus_xattr_user_handler,
hfsplus_xattr_trusted_handler, hfsplus_xattr_security_handler will be
without is_know_namespace() check. What about it?

> > The __hfsplus_setxattr() is common method for all handlers. So, removing
> > this call means that we don't check validity of namespace. I don't think
> > that such modification is a right way.
> 
> The generic code already checks for the validity of the namespace for
> you. xattr_resolve_name in fs/xattr.c makes sure only attributes for a
> namespace that the filesystem registered can be set or modified.
> 

But generic code doesn't check such names combination that it is treated
as wrong for concrete file systems. For example, "osx.security.*" is
wrong for the case of HFS+. Because it will works
hfsplus_xattr_osx_handler instead of hfsplus_xattr_security_handler.

> > > @@ -841,10 +761,6 @@ int hfsplus_removexattr(struct dentry *dentry, const char *name)
> > > 	if (!HFSPLUS_SB(inode->i_sb)->attr_tree)
> > > 		return -EOPNOTSUPP;
> > > 
> > > -	err = can_set_xattr(inode, name, NULL, 0);
> > 
> > Ditto. Moreover, it is used namely hfsplus_removexattr() and not
> > __hfsplus_setxattr() for removing xattrs in hfsplus driver. So, removing
> > this check is not good way.
> 
> Oh, I just noticed that hfsplus does not use the xattr handlers for
> removing, while it does for getting and setting xattrs.  That's a really
> bad a confusing design, and we'll indeed need to fix that as well.
> 

Why bad design? Do you mean that using .removexattr callback is bad
idea?

So, if it needs to use xattr handler only for removing then it needs to
make some refactoring of using __hfsplus_setxattr() and
hfsplus_removexattr() or merging these two functions into one. And I
think that merging is better idea.

Thanks,
Vyacheslav Dubeyko.


