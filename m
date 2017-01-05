Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:58569 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752911AbdAEFw0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Jan 2017 00:52:26 -0500
Date: Thu, 5 Jan 2017 06:51:30 +0100
From: Christoph Hellwig <hch@lst.de>
To: Bruce James Fields <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Trond Myklebust <trondmy@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] RFC 7530: Filehandle of opened file after the REMOVE
Message-ID: <20170105055130.GA10939@lst.de>
References: <C496AE44-0F27-4B66-A1F6-A76AEAFD7A90@gmail.com> <20161229024703.GA21325@fieldses.org> <20161229074830.GA3002@lst.de> <20161229205426.GA389@fieldses.org> <20161230083530.GA26413@lst.de> <20170101135817.GA18418@lst.de> <20170101221025.GA7216@fieldses.org> <20170102084005.GA3471@lst.de> <20170102152741.GA16526@fieldses.org> <20170104174245.GD17649@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170104174245.GD17649@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 04, 2017 at 12:42:45PM -0500, Bruce James Fields wrote:
> Dumb question: don't local filesystems have the ability to do some sort
> of emergency conversion to read-only on detecting corruption?

Yes.

> Does that
> prevent any open-file cleanup?

Yes, at least before the reboot.

> If not that, is there some other
> mechanism nfsd could use to crash the filesystem on shutdown if
> appropriate (so if it's holding opens on a filesystem and if the
> filesystem was mounted with the new option)?
> 
> Possibly better would be if we could keep a separate list of
> unlinked-but-still-held-by-nfsd files that was managed diferently than
> the existing list.
> 
> But, I don't have the local filesystem knowledge to know where the
> nightmares are here.

Maybe I shouldn't have called it a nighmare, but it's significantly
more effort.  We'll need a way for NFSD to mark a file as not being
allowed to cleaned up before the final iput for the reboot case
mostly.

I'll try to come up with a prototype later this month, but it might not
be pretty.
