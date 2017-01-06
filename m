Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58914 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751892AbdAFVNk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Jan 2017 16:13:40 -0500
Date: Fri, 6 Jan 2017 16:13:39 -0500
From: Bruce James Fields <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] RFC 7530: Filehandle of opened file after the REMOVE
Message-ID: <20170106211339.GC31401@fieldses.org>
References: <20161229024703.GA21325@fieldses.org>
 <20161229074830.GA3002@lst.de>
 <20161229205426.GA389@fieldses.org>
 <20161230083530.GA26413@lst.de>
 <20170101135817.GA18418@lst.de>
 <20170101221025.GA7216@fieldses.org>
 <20170102084005.GA3471@lst.de>
 <20170102152741.GA16526@fieldses.org>
 <20170104174245.GD17649@fieldses.org>
 <20170105055130.GA10939@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170105055130.GA10939@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 05, 2017 at 06:51:30AM +0100, Christoph Hellwig wrote:
> On Wed, Jan 04, 2017 at 12:42:45PM -0500, Bruce James Fields wrote:
> > Dumb question: don't local filesystems have the ability to do some sort
> > of emergency conversion to read-only on detecting corruption?
> 
> Yes.
> 
> > Does that
> > prevent any open-file cleanup?
> 
> Yes, at least before the reboot.
> 
> > If not that, is there some other
> > mechanism nfsd could use to crash the filesystem on shutdown if
> > appropriate (so if it's holding opens on a filesystem and if the
> > filesystem was mounted with the new option)?
> > 
> > Possibly better would be if we could keep a separate list of
> > unlinked-but-still-held-by-nfsd files that was managed diferently than
> > the existing list.
> > 
> > But, I don't have the local filesystem knowledge to know where the
> > nightmares are here.
> 
> Maybe I shouldn't have called it a nighmare, but it's significantly
> more effort.  We'll need a way for NFSD to mark a file as not being
> allowed to cleaned up before the final iput for the reboot case
> mostly.
> 
> I'll try to come up with a prototype later this month, but it might not
> be pretty.

OK, thanks, I'll look forward to seeing how it works, pretty or not.

--b.
