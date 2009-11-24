From: Grant Grundler <grundler-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
Subject: Re: [PATCHSET 0-5] remove unneeded nfsd #includes
Date: Tue, 24 Nov 2009 14:27:06 -0700
Message-ID: <20091124212706.GB25755@lackof.org>
References: <4B0C1EB7.50508@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-parisc <linux-parisc@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:39835 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934007AbZKXV1B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2009 16:27:01 -0500
In-Reply-To: <4B0C1EB7.50508@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2009 at 07:58:15PM +0200, Boaz Harrosh wrote:
> Some arch files had unneeded #includes directives from linux/nfsd/*.
> Some vfs files had unneeded #includes directives from linux/nfsd/*.
...
> patches:
> [PATCH 1/5] parsic: remove unused nfsd #includes
> 	Some kind soul, please compile with this patch? compile
> 	is all that's needed.

Boaz,
linux-2.6 compiles for parisc with this patch. Please add:
    Tested-by: Grant Grundler <grundler-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>

thanks,
grant

> 
> [PATCH 2/5] sparc: remove unused nfsd #includes
> [PATCH 3/5] s390: remove unused nfsd #includes
> 	These two were cross compiled. Should we submit them through
> 	nfsd tree or the ARCH trees?
> 
> [PATCH 4/5] vfs: nfsctl.c unused nfsd #includes
> [PATCH 5/5] lockd: Remove unused nfsd headers #includes
> 	Can these patches go through the nfsd tree?
> 	Who's ACKs should we collect? Andrew?
> 
> Bruce Hi
> With this set applied, the only nfsd files used publicly are:
> 	const.h	export.h nfsfh.h stats.h syscall.h
> 
> These files can be moved to source folder:
> 	cache.h  debug.h  nfsd.h  state.h xdr3.h  xdr4.h  xdr.h
> 
> Why is debug.h exported from Kernel? (include/linux/nfsd/Kbuild)
> 
> So just to see how this move might look like see last patch:
> [RFC] nfsd: Move private headers to source directory
> 	This patch was compiled, as well, on x86(32/64), sparc64, s390
> 
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-parisc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
