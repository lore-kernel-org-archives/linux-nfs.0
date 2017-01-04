Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53964 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757780AbdADRnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 12:43:20 -0500
Date: Wed, 4 Jan 2017 12:42:45 -0500
From: Bruce James Fields <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] RFC 7530: Filehandle of opened file after the REMOVE
Message-ID: <20170104174245.GD17649@fieldses.org>
References: <CADaq8jck14SKL6Ua9QxbqPyX1=1aaA7+76wv-__EWFvh7ZcEJA@mail.gmail.com>
 <C496AE44-0F27-4B66-A1F6-A76AEAFD7A90@gmail.com>
 <20161229024703.GA21325@fieldses.org>
 <20161229074830.GA3002@lst.de>
 <20161229205426.GA389@fieldses.org>
 <20161230083530.GA26413@lst.de>
 <20170101135817.GA18418@lst.de>
 <20170101221025.GA7216@fieldses.org>
 <20170102084005.GA3471@lst.de>
 <20170102152741.GA16526@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170102152741.GA16526@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 02, 2017 at 10:27:41AM -0500, Bruce James Fields wrote:
> On Mon, Jan 02, 2017 at 09:40:05AM +0100, Christoph Hellwig wrote:
> > On Sun, Jan 01, 2017 at 05:10:25PM -0500, Bruce James Fields wrote:
> > > How do we handle clean shutdown, though?  At a minimum a server admin
> > > needs to be able to e.g. take down the server for an OS upgrade.
> > 
> > That's going to be a nightmare to implement unfortunately.
> 
> Ugh.  I think it's a requirement; without it:
> 
> 	- if we set the flag that allows the client to turn off
> 	  sillyrename, then users will see a regression (ESTALE after
> 	  clean shutdowns in situations we previously guaranteed safe).
> 
> 	- if we don't set that flag, we don't get to turn off client
> 	  sillyrename.  The only improvement is that we avoid ESTALE
> 	  after crashes on files unlinked by a different client than
> 	  held it open.  I don't think that's very interesting on its
> 	  own.

Dumb question: don't local filesystems have the ability to do some sort
of emergency conversion to read-only on detecting corruption?  Does that
prevent any open-file cleanup?  If not that, is there some other
mechanism nfsd could use to crash the filesystem on shutdown if
appropriate (so if it's holding opens on a filesystem and if the
filesystem was mounted with the new option)?

Possibly better would be if we could keep a separate list of
unlinked-but-still-held-by-nfsd files that was managed diferently than
the existing list.

But, I don't have the local filesystem knowledge to know where the
nightmares are here.

--b.
