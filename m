Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47806 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932257AbdAAWK1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 1 Jan 2017 17:10:27 -0500
Date: Sun, 1 Jan 2017 17:10:25 -0500
From: Bruce James Fields <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] RFC 7530: Filehandle of opened file after the REMOVE
Message-ID: <20170101221025.GA7216@fieldses.org>
References: <20161214112112.Horde.aPh8AjT6iWRl37CULwihyV7@mail.telka.sk>
 <CAABAsM7v6y0bsb0jKzfvobkUjniTLhM3uv8FYjo07HcLD2004w@mail.gmail.com>
 <20161227144414.GA32002@fieldses.org>
 <CADaq8jck14SKL6Ua9QxbqPyX1=1aaA7+76wv-__EWFvh7ZcEJA@mail.gmail.com>
 <C496AE44-0F27-4B66-A1F6-A76AEAFD7A90@gmail.com>
 <20161229024703.GA21325@fieldses.org>
 <20161229074830.GA3002@lst.de>
 <20161229205426.GA389@fieldses.org>
 <20161230083530.GA26413@lst.de>
 <20170101135817.GA18418@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170101135817.GA18418@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 01, 2017 at 02:58:17PM +0100, Christoph Hellwig wrote:
> Btw, thinking about this a bit more the simplest thing possible would be a
> mount option to delay reclaiming unlinked inodes for N seconds, set to the
> NFS gracce periods plus a reasonable slack for starting NFSD after mounting
> the fs.  This would be fairly easily to implement in the fs, does not
> require tight coupling between the fs and NFSD, and will eventually reclaim
> the unlinked inodes even if the file system happens to not be exported at
> all. 
> 
> I could implement this quickly if you want to play around with the NFSD
> side.

Sure, that'd be interesting.

How do we handle clean shutdown, though?  At a minimum a server admin
needs to be able to e.g. take down the server for an OS upgrade.

--b.
