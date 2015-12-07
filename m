Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40840 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754745AbbLGVJ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 16:09:57 -0500
Date: Mon, 7 Dec 2015 13:09:46 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Christoph Hellwig <hch@lst.de>
Cc: viro@zeniv.linux.org.uk, tao.peng@primarydata.com,
        jeff.layton@primarydata.com, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 2/4] vfs: pull btrfs clone API to vfs layer
Message-ID: <20151207210946.GB28038@birch.djwong.org>
References: <1449143992-7415-1-git-send-email-hch@lst.de>
 <1449143992-7415-3-git-send-email-hch@lst.de>
 <20151207005331.GA10582@birch.djwong.org>
 <20151207151319.GA2472@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151207151319.GA2472@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 07, 2015 at 04:13:19PM +0100, Christoph Hellwig wrote:
> On Sun, Dec 06, 2015 at 04:53:31PM -0800, Darrick J. Wong wrote:
> > > +	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
> > > +		return -EISDIR;
> > > +	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> > > +		return -EOPNOTSUPP;
> > 
> > I thought we were moving to -EINVAL for wrong file types?
> > 
> > Though, perhaps "I've also prepared a btrfs patch for this and clone" from the
> > earlier thread about generic/157 wasn't referring to /this/ patch. :)
> > 
> > In any case, I'm ok with EINVAL, and I haven't heard any objections to
> > changing -EOPNOTSUPP -> -EINVAL when trying to reflink/dedupe/whatever
> > non-file non-dir fds.
> 
> I'm fine with with EINVAL - not sure why I ended up with EOPNOTSUP,
> probably because 157 is already failing as in general the errors for
> something in the VFS vs a specific ioctl handler are just too different.

Ok, I'm going to ensure that generic/1[57-60] all look for EINVAL when
the file type is wrong, and resend the xfstests patches.  I'll also
patch them up to accept the error codes that btrfs spit out before the
ioctl hoist.

--D
