Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45878 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531Ab1CPQo5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 12:44:57 -0400
Date: Wed, 16 Mar 2011 12:44:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-nfs@vger.kernel.org,
        linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Neil Brown <neilb@suse.de>
Subject: Re: linux-next: Tree for March 16 (nfsd)
Message-ID: <20110316164453.GB9299@fieldses.org>
References: <20110316191444.d91a3263.sfr@canb.auug.org.au>
 <20110316093234.a82a8b0b.randy.dunlap@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110316093234.a82a8b0b.randy.dunlap@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 16, 2011 at 09:32:34AM -0700, Randy Dunlap wrote:
> On Wed, 16 Mar 2011 19:14:44 +1100 Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20110315:
> 
> 
> ERROR: "gss_mech_put" [fs/nfsd/nfsd.ko] undefined!
> ERROR: "gss_mech_get_by_name" [fs/nfsd/nfsd.ko] undefined!

Let me know if this is not fixed by
0a5e5f122c756d1c1a6ca712eda76ea8664e5fd9 in the latest

	git://linux-nfs.org/~bfields/linux.git for-2.6.39

--b.
