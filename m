From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 1 Aug 2008 11:03:59 +0100
Message-ID: <20080801100359.GM28946@ZenIV.linux.org.uk>
References: <1209670979.25560.587.camel@pmac.infradead.org> <20080501204820.GA5951@infradead.org> <1209681898.25560.613.camel@pmac.infradead.org> <18458.28833.539314.455215@notabene.brown> <1217541264.1126.15.camel@shinybook.infradead.org> <18578.21997.529551.676627@notabene.brown> <1217551230.3719.15.camel@shinybook.infradead.org> <18578.29049.38904.746701@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38040 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbYHAKEB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2008 06:04:01 -0400
In-Reply-To: <18578.29049.38904.746701-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 01, 2008 at 12:14:17PM +1000, Neil Brown wrote:

> It sounds to me like the core problem here is that the locking regime
> imposed by the VFS simply isn't suitable for JFFS2 .. and a bunch of
> other filesystems.
> 
> This seems to suggest that the VFS should be changed.
> Superficially, it seems that changing the locking rules so that the
> callee takes i_mutex rather than the caller taking it would help and,
> in the case of JFFS2, make f->sem redundant.  Does that match your
> understanding?

Huh?  How could that possibly help?  You are not changing the sequence
of operations on locks, you only slightly modify the timing; how could
that possibly eliminate a deadlock?  Moreover, how the _hell_ could
making exclusion area smaller make f->sem redundant?
