From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 2 May 2008 10:08:04 -0400
Message-ID: <20080502140804.GA16959@fieldses.org>
References: <1209670979.25560.587.camel@pmac.infradead.org> <20080501204820.GA5951@infradead.org> <1209681898.25560.613.camel@pmac.infradead.org> <18458.28833.539314.455215@notabene.brown> <1209728238.25560.686.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40879 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754455AbYEBOIR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 10:08:17 -0400
In-Reply-To: <1209728238.25560.686.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 12:37:18PM +0100, David Woodhouse wrote:
> On Fri, 2008-05-02 at 11:38 +1000, Neil Brown wrote:
> > Why is there a deadlock here?
> 
> Many file systems have their own locking, and lookup() can end up trying
> to re-take a lock which readdir() is already holding. In the JFFS2 case,
> it's the fs-internal inode mutex, which is required because the garbage
> collector can't use i_mutex for lock ordering reasons.
> 
> See also the readdir implementation and surrounding comments in
> fs/xfs/linux-2.6/xfs_file.c -- and the way GFS2 uses
> gfs2_glock_is_locked_by_me() to avoid the deadlock.
> 
> The annoying thing is that JFFS2 doesn't even _implement_ i_generation,
> so you get no more useful information out of the lookup() call anyway :)
> 
> > Both readdir and lookup are called with i_mutex held on the directory
> > so there should need to do any extra locking (he said, naively).  In
> > the readdirplus cases, i_mutex is held across both the readdir and the
> > lookup....
> > 
> > One problem with your proposed solution is that filehandles aren't all
> > the same length, so you cannot reliably leave space for them.
> 
> Not without moving stuff around during the postprocessing, I suppose.
> Which isn't very pretty -- but it's prettier than some of the hacks we
> have at the moment to avoid the deadlock.

This comes up periodically.  It would be great to finally get it fixed.
The last conversation I remember started at about:

	http://marc.info/?l=linux-kernel&m=119506226209056&w=2

Summary: one approach would be to define a ->readdirplus() that passes a
dentry to its equivalent of the ->filldir callback.  (Christoph points
out that returning a stat struct would be simpler.  But unfortunately we
need to check for mountpoints here, so that's not sufficient.)

--b.
