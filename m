Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:52942 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753087AbaA3O2A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 09:28:00 -0500
Date: Thu, 30 Jan 2014 14:27:52 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Subject: Re: NFS client broken in Linus' tip
Message-ID: <20140130142752.GX15937@n2100.arm.linux.org.uk>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk> <20140130141405.GA23985@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140130141405.GA23985@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 30, 2014 at 06:14:05AM -0800, Christoph Hellwig wrote:
> On Thu, Jan 30, 2014 at 02:08:34PM +0000, Russell King - ARM Linux wrote:
> > into nfs3_proc_create(), but this ends up calling down into nfs3_get_acl(),
> > which does this:
> > 
> >         if (!nfs_server_capable(inode, NFS_CAP_ACLS))
> >                 return ERR_PTR(-EOPNOTSUPP);
> 
> Does replacing that return with a
> 
> 		return NULL;
> 
> fix the issue for you?

Yes and no.  I still end up with an empty /etc/mtab, but the file now
exists.  However, I can create and echo data into /etc/mtab, but it seems
that can't happen at boot time.

I also find that kerberos doesn't work - again, it's weird - I can create
the file which kerberos is trying to create in /var/tmp (which is also on
the root nfs) manually, but when the kerberos daemons try to create it,
it fails with -EOPNOTSUPP.  The kerberos daemon is running as uid 0 at
that point (I don't know about the other uids/gids though since I wasn't
able to catch them in the strace.)

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".
