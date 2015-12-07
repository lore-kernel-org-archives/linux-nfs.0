Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49538 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932913AbbLGPNV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 10:13:21 -0500
Date: Mon, 7 Dec 2015 16:13:19 +0100
From: Christoph Hellwig <hch@lst.de>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, viro@zeniv.linux.org.uk,
        tao.peng@primarydata.com, jeff.layton@primarydata.com,
        bfields@fieldses.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 2/4] vfs: pull btrfs clone API to vfs layer
Message-ID: <20151207151319.GA2472@lst.de>
References: <1449143992-7415-1-git-send-email-hch@lst.de> <1449143992-7415-3-git-send-email-hch@lst.de> <20151207005331.GA10582@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151207005331.GA10582@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 06, 2015 at 04:53:31PM -0800, Darrick J. Wong wrote:
> > +	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
> > +		return -EISDIR;
> > +	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> > +		return -EOPNOTSUPP;
> 
> I thought we were moving to -EINVAL for wrong file types?
> 
> Though, perhaps "I've also prepared a btrfs patch for this and clone" from the
> earlier thread about generic/157 wasn't referring to /this/ patch. :)
> 
> In any case, I'm ok with EINVAL, and I haven't heard any objections to
> changing -EOPNOTSUPP -> -EINVAL when trying to reflink/dedupe/whatever
> non-file non-dir fds.

I'm fine with with EINVAL - not sure why I ended up with EOPNOTSUP,
probably because 157 is already failing as in general the errors for
something in the VFS vs a specific ioctl handler are just too different.
