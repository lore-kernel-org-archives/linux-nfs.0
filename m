Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:55976 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752454AbaBCUZh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 15:25:37 -0500
Date: Mon, 3 Feb 2014 20:25:21 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Viro Alexander <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Subject: Re: NFS client broken in Linus' tip
Message-ID: <20140203202521.GM26684@n2100.arm.linux.org.uk>
References: <20140130141405.GA23985@infradead.org> <20140130142752.GX15937@n2100.arm.linux.org.uk> <20140130143208.GB9573@infradead.org> <20140130153812.GA15937@n2100.arm.linux.org.uk> <1391201970.6978.1.camel@leira.trondhjem.org> <20140203080325.GB806@infradead.org> <85AAFCF5-60EE-42E5-B103-37A4613C5947@primarydata.com> <20140203145759.GA30263@infradead.org> <3003D7E5-93F8-4B32-ACDB-07ED3F6CE70D@primarydata.com> <1391458935.17089.1.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1391458935.17089.1.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 03, 2014 at 03:22:15PM -0500, Trond Myklebust wrote:
> On Mon, 2014-02-03 at 10:45 -0500, Trond Myklebust wrote:
> > On Feb 3, 2014, at 9:57, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > > On Mon, Feb 03, 2014 at 09:17:30AM -0500, Trond Myklebust wrote:
> > >> As I said above, that causes posix_acl_xattr_get() to return the wrong answer (ENODATA instead of EOPNOTSUPP).
> > > 
> > > Is it really the wrong answer?  How does userspace care wether this
> > > server doesn't support ACLs at all or none is set?  The resulting
> > > behavior is the same.
> > 
> > It will certainly cause acl_get_file() to behave differently than previously. I’ve no idea how that will affect applications, though.
> > 
> > > If there's a good reason to care we might have to go with your patch,
> > > but if we can avoid it I'd prefer to keep things simple.
> > 
> > One alternative is to simply wrap posix_acl_xattr_get() in fs/nfs/nfs3acl.c, and have it check the value of nfs_server_capable(inode, NFS_CAP_ACLS) before returning ENODATA. That’s rather ugly too...
> 
> FWIW, here is the alternative patch. I've tested it, and it seems to
> work.

Thanks.

As there's now two fixes, which would you like me to test?

One comment on this patch though:

> +static int
> +nfs_posix_acl_xattr_get(struct dentry *dentry, const char *name,
> +		void *value, size_t size, int type)
> +{
> +	int ret;
> +
> +	ret = posix_acl_xattr_get(dentry, name, value, size, type);
> +	/*
> +	 * This check is needed to override the ENODATA error that
> +	 * posix_acl_xattr_get will return if the acl probe fails.
> +	 */
> +	if (!nfs_server_capable(dentry->d_inode, NFS_CAP_ACLS))
> +		ret = -EOPNOTSUPP;

I'm not familiar with this code, but the above looks slightly weird,
and a little suspicious - especially with the lack of blank line
before the comment.  Is the above actually intended?

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".
