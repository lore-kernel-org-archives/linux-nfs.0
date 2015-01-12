Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:41065 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbbALMqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2015 07:46:38 -0500
Date: Mon, 12 Jan 2015 13:46:35 +0100
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 14/18] nfsd: pNFS block layout driver
Message-ID: <20150112124635.GB29681@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-15-git-send-email-hch@lst.de> <20150112061419.GB107426@slacker.internal.excfb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150112061419.GB107426@slacker.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2015 at 01:14:19AM -0500, Tom Haynes wrote:
> 
> > +file system must sit on shared storage (typically iSCSI) that is accessible
> > +to the clients as well as the server.  The file system needs to either sit
> > +directly on the exported volume, or on a RAID 0 using the MD software RAID
> 
> a RAID 0 what?

I don't quite understand that comment.  But I'll have to revise that
text anyway as the RAID0/1 support isn't part of this submission yet,
as it needs a little more work and involves two more subsystems.

For those who are curious about the md support, it is available at:

	git://git.infradead.org/users/hch/pnfs.git pnfsd-block-md-support


> What reclaims bex in both error cases??
> 
> The call flow seems to be:
> 
> nfsd4_proc_compound -> nfsd4_layoutget -> nfsd4_block_proc_layoutget
> 
> lg_content gets freed in nfsd4_encode_layoutget() in all paths.
> 
> nfsd4_encode_operation() calls nfsd4_encode_layoutget().
> 
> But nfsd4_encode_layoutget() is not called in all paths:
> 
>         p = xdr_reserve_space(xdr, 8);
>         if (!p) {
>                 WARN_ON_ONCE(1);
>                 return;  // leak
>         }
> ...
>         if (op->opnum == OP_ILLEGAL)
>                 goto status;  // Not really a leak, if we hit this, bigger issues apply.
> 
> So bex is correctly accounted for, but in general
> nfsd4_encode_operation() can leak any operation
> specific memory.

I guess we need to fix properly in the nfsd core eventually.  For
example by adding a new method called for successful and error completions
that can free all ressources.
