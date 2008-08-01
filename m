From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 01 Aug 2008 14:56:16 +0100
Message-ID: <1217598976.3454.359.camel@pmac.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
	 <1217541264.1126.15.camel@shinybook.infradead.org>
	 <18578.21997.529551.676627@notabene.brown>
	 <1217551230.3719.15.camel@shinybook.infradead.org>
	 <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
	 <1217552437.3719.30.camel@shinybook.infradead.org>
	 <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
	 <1217597759.3454.356.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: viro@zeniv.linux.org.uk, Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60687 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbYHAN4V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2008 09:56:21 -0400
In-Reply-To: <1217597759.3454.356.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-08-01 at 14:36 +0100, David Woodhouse wrote:
> Those are needed by NFSv3 too -- and can be handled with a lookup_fh()
> method in the file system which is guaranteed to be called from within
> the filldir callback, and some support in the VFS for checking if it's a
> mountpoint.
> 
> NFSv4 introduces another problem though, which is that it seems to be
> able to return the _full_ getattr() results for each object, and there's
> no real way round the fact that we need to do the ->lookup() for that.
> 
> If sane clients aren't expected to _ask_ for that, though, then perhaps
> it would be OK to fall back to something like the existing
> readdir-to-buffer hack for that case, while most normal clients won't
> trigger it.

Or maybe we could just mask the offending attrs out of ->rd_bmval for
readdir calls, and say we don't support them? Would anyone scream if we
did that?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



