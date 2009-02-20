From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Thoughts about cache consistency and directories in particular.
Date: Fri, 20 Feb 2009 12:32:46 -0800
Message-ID: <1235161966.31066.24.camel@heimdal.trondhjem.org>
References: <18846.4842.625445.980681@notabene.brown>
	 <1235156207.31066.21.camel@heimdal.trondhjem.org>
	 <18847.2578.480148.216735@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:32832 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753693AbZBTUcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2009 15:32:52 -0500
In-Reply-To: <18847.2578.480148.216735-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-02-21 at 06:52 +1100, Neil Brown wrote:
> On Friday February 20, trond.myklebust@fys.uio.no wrote:
> > It should work fine. The ctime tracks the mtime in all cases except when
> > you setacl, setfattr, chown, chgrp, chmod, or touch the directory. Those
> > should be very rare operations for pretty much any workload...
> > 
> 
> Does that mean you'll take the patch ??

Not as it stands. You really want to be calling
nfs_force_lookup_revalidate() instead of invalidating the directory
contents.

Cheers
  Trond

