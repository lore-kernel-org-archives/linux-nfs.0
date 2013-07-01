Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36070 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755100Ab3GAU0z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 16:26:55 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UtkgX-0006F1-BF
	for linux-nfs@vger.kernel.org; Mon, 01 Jul 2013 16:26:53 -0400
Date: Mon, 1 Jul 2013 16:26:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: Re: nfsd dropping requests after lazy umount
Message-ID: <20130701202649.GE19945@fieldses.org>
References: <20130625191008.GA20277@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130625191008.GA20277@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 25, 2013 at 02:10:08PM -0500, Malahal Naineni wrote:
> Hi All,
> 
> I have found an issue with lazy/forced unmounts with nfsd. Let us say
> /nfs is a mount point, and we are exporting /nfs/exp directory.
> 
> After mounting from a client, this export will have a cache entry
> "svc_export" in the kernel. The exports pathname
> d_path(svc_export->ex_path) correctly resolves to "/nfs/exp"
> 
> After the /nfs is lazy unmounted, the d_path(svc_export->ex_path)
> resolves to "/exp" only.
> 
> Now, if the cache entry needs revalidation, you will see "/exp" in the
> nfsd.export/channel file that never gets cleared as that cache entry
> will be in a forever CACHE_PENDING state. We will also see
> svc_export_parse() failing with -2 err as such a pathname doesn't exist
> in the system any more.

So, mountd is trying to do a downcall for "/exp" but it's failing
because the kern_path("/exp",.,.) fails?

> I noticed that svc_export has two fields: ex_path and ex_pathname.

Not any more--see 2f1ddda1749a223d1a05e16dc6ea28632b9ec570 "NFSD: Remove
the ex_pathname field from struct svc_export".

--b.

> Is
> it possible to make a string comparison of d_path(ex_path) and
> ex_pathname? If so, we should be able to fail the upcall without making
> the upcall if those two don't match.
> 
> Regards, Malahal.
> 
