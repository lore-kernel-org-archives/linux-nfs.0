From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [GIT *] fsid/uuid fixes
Date: Wed, 20 Aug 2008 15:29:52 -0400
Message-ID: <20080820192952.GA21226@fieldses.org>
References: <1219229787.2988.108.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56295 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757790AbYHTT35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 15:29:57 -0400
In-Reply-To: <1219229787.2988.108.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2008 at 11:56:27AM +0100, David Woodhouse wrote:
> Please pull from git://git.infradead.org/users/dwmw2/nfs-utils.git
> 
> This fixes the handling of explicit 16-byte fsid given in exportfs
> options, and also makes mountd find an fsid from statfs() where the
> kernel provides one.
> 
> I wonder if we should use the fsid from statfs() in _preference_ to
> using libblkid, since 

..?

> 
> David Woodhouse (4):
>       Fix handling of explicit uuid
>       Explicit UUID handling doesn't require blkid; factor out get_uuid_blkdev()
>       Use fsid from statfs for UUID if blkid can't cope (or not used)
>       Stop exportfs warning about needing fsid, when we actually have one
> 
>  support/nfs/exports.c     |    2 +-
>  utils/exportfs/exportfs.c |   10 +++++-
>  utils/mountd/cache.c      |   89 +++++++++++++++++++++++++++------------------
>  3 files changed, 63 insertions(+), 38 deletions(-)
> 
> -- 
> David Woodhouse                            Open Source Technology Centre
> David.Woodhouse@intel.com                              Intel Corporation
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
