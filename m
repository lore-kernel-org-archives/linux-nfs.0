Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33911 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab3LVT20 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Dec 2013 14:28:26 -0500
Date: Sun, 22 Dec 2013 11:28:18 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Vyacheslav Dubeyko <slava@dubeyko.com>
Cc: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
Subject: Re: [PATCH 21/21] hfsplus: remove can_set_xattr
Message-ID: <20131222192818.GA32565@infradead.org>
References: <20131220131635.650823732@bombadil.infradead.org>
 <20131220132524.900291394@bombadil.infradead.org>
 <636E01BC-12FD-452B-8B1C-320B6EADAEFD@dubeyko.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <636E01BC-12FD-452B-8B1C-320B6EADAEFD@dubeyko.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 21, 2013 at 08:07:51PM +0300, Vyacheslav Dubeyko wrote:
> > -static int can_set_xattr(struct inode *inode, const char *name,
> > -				const void *value, size_t value_len)
> 
> This function works for all handlers. So, I don't think that it makes sense
> to delete it.

It "works" in a minimal sense that it won't crash or actively cause
harm.  But it also is useless except for the check that we can abuse
the osx namespace to set an attribute in another namespace, which we
still do in the proper way after my patch.

> > -	if (!strncmp(name, XATTR_MAC_OSX_PREFIX, XATTR_MAC_OSX_PREFIX_LEN)) {
> > -		/*
> > -		 * This makes sure that we aren't trying to set an
> > -		 * attribute in a different namespace by prefixing it
> > -		 * with "osx."
> > -		 */
> > -		if (is_known_namespace(name + XATTR_MAC_OSX_PREFIX_LEN))
> > -			return -EOPNOTSUPP;
> 
> I think that this check is important. It forbids such combinations as "osx.system.*" or
> "osx.trusted.*", for example. Because "osx.*" is virtual namespace for xattrs that
> it can be under Mac OS X. If you want to set xattr from "system.*" namespace, for example,
> then you need to use another handler. And such namespace should be without
> addition of "osx." prefix.

Right, and we keep exactly the check, just in a different place.

> The __hfsplus_setxattr() is common method for all handlers. So, removing
> this call means that we don't check validity of namespace. I don't think
> that such modification is a right way.

The generic code already checks for the validity of the namespace for
you. xattr_resolve_name in fs/xattr.c makes sure only attributes for a
namespace that the filesystem registered can be set or modified.

> > @@ -841,10 +761,6 @@ int hfsplus_removexattr(struct dentry *dentry, const char *name)
> > 	if (!HFSPLUS_SB(inode->i_sb)->attr_tree)
> > 		return -EOPNOTSUPP;
> > 
> > -	err = can_set_xattr(inode, name, NULL, 0);
> 
> Ditto. Moreover, it is used namely hfsplus_removexattr() and not
> __hfsplus_setxattr() for removing xattrs in hfsplus driver. So, removing
> this check is not good way.

Oh, I just noticed that hfsplus does not use the xattr handlers for
removing, while it does for getting and setting xattrs.  That's a really
bad a confusing design, and we'll indeed need to fix that as well.

> > 	if (len > HFSPLUS_ATTR_MAX_STRLEN)
> > 		return -EOPNOTSUPP;
> > 
> > +	if (is_known_namespace(name))
> > +		return -EOPNOTSUPP;
> 
> If common check in __hfsplus_setxattr() will be on the same place then
> this addition doesn't make sense.

Having both does indeed not make sense, but this is the better place to
have it.

