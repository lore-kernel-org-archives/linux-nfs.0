Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53523 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab1BOLOH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 06:14:07 -0500
Date: Tue, 15 Feb 2011 06:14:04 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Jim Rees <rees@umich.edu>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/6] nfsd4: split up nfsd_break_deleg_cb
Message-ID: <20110215111404.GA12517@infradead.org>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
 <1297227351-15365-2-git-send-email-bfields@redhat.com>
 <20110209050118.GA2485@infradead.org>
 <20110209151402.GA13624@pad.home.fieldses.org>
 <20110209162838.GA21056@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110209162838.GA21056@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 09, 2011 at 11:28:38AM -0500, Jim Rees wrote:
> J. Bruce Fields wrote:
> 
>   Agreed.  Those two lines were actually untouched by this patch, no
>   matter what diff thinks--but I'm just as happy to fix it up while we're
>   there; done.
> 
> I agree too, but "indent -linux" likes "static" on a line by itself, and
> prefers it over "static void".  This is not the first time I've disagreed
> with it, although I use it a lot.

The linux styles of most indent-like programs are utter garbage.  If you
want Linux style use the scripts/Lindent script in the source tree.  It
still has a few quirks, like stupid ways to split overly long lines, but
generally does a reasonable job.
