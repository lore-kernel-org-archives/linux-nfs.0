Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:39194 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932430Ab1BJXlE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 18:41:04 -0500
Received: from mac.home (port-92-206-155-227.dynamic.qsc.de [92.206.155.227])
	by eazy.amigager.de (Postfix) with ESMTPA id 2AE5BF3001A
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 00:41:03 +0100 (CET)
Date: Fri, 11 Feb 2011 00:41:06 +0100
From: Tino Keitel <tino.keitel@tikei.de>
To: linux-nfs@vger.kernel.org
Subject: Re: 2.6.38-rc3: kernel BUG at fs/nfsd/nfs4state.c:3132!
Message-ID: <20110210234106.GA29411@mac.home>
References: <20110209220427.GA12140@mac.home>
 <20110210213632.GA29900@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110210213632.GA29900@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 10, 2011 at 16:36:32 -0500, J. Bruce Fields wrote:
> On Wed, Feb 09, 2011 at 11:04:27PM +0100, Tino Keitel wrote:
> > Hi,
> > 
> > I get the following error with kernel 2.6.38-rc3 during normal file access via
> > NFS v4. The underlying FS is ext4, if that matters.
> > 
> > At least one other user seems to have the same problem:
> > http://pastebin.com/QRq1TMkj
> 
> Thanks for the report.
> 
> > 
> > <0>------------[ cut here ]------------
> > kernel BUG at fs/nfsd/nfs4state.c:3132!
> 
> This is a bit odd: v2.6.38-rc3 doesn't have a BUG on line 3132 of
> fs/nfsd/nfs4state.c.

Mine does:

$ git show | head -n 5 ; echo ; head -n 3132 fs/nfsd/nfs4state.c | tail -n 1
commit ebf53826e105f488f4f628703a108e98940d1dc5
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue Feb 1 13:05:49 2011 +1000

    Linux 2.6.38-rc3

			BUG_ON(!*filpp);
$

This is vanilla upstream source.

Regards,
Tino
