From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: permission denied with >= ~2.6.25
Date: Wed, 19 May 2010 13:13:47 -0400
Message-ID: <20100519171347.GB8137@fieldses.org>
References: <4BE7ED5D.90801@itwm.fraunhofer.de> <4BE93940.5070804@itwm.fraunhofer.de> <4BED1E44.4020708@itwm.fraunhofer.de> <20100516175213.GA9225@lts032.itwm.fhg.de> <4BF25109.40300@itwm.fraunhofer.de> <4BF3C7A4.8030906@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Martin Vogt <martin.vogt@itwm.fraunhofer.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60821 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253Ab0ESRNs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 13:13:48 -0400
In-Reply-To: <4BF3C7A4.8030906@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 19, 2010 at 01:12:36PM +0200, Martin Vogt wrote:
> Martin Vogt wrote:
> > Hello,
> > 
> > 
> > today I tried 2.6.34 on server/client with standard
> > hardware. After around the 69th checkout I had an
> > "Invalid cross-device link" Error.
> > (Before that it was EIO/EPERM)
> > 
> > Test ran for around 9 hours before it failed.
> > 
> >> svn: In directory 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc'
> >> svn: Can't move
> > 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h.tmp'
> >> to 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h': Invalid
> >> cross-device link
> >> Mon May 17 23:46:32 CEST 2010,1
> >> runcounter: 69
> > 
> 
> Ok.
> RTFM: no_subtree_check :-(
> 
> This option made the checkouts reliable.

Erp.  Should have thought of that.  It's no longer the default in recent
nfs-utils, for this sort of reason.

(But, note: for anyone exporting directories that aren't mountpoints,
that may expose more of their filesystem than intended.)

--b.
