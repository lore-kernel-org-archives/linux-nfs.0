Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:60469 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172Ab1BJVtM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 16:49:12 -0500
Received: from mac.home (port-92-206-155-227.dynamic.qsc.de [92.206.155.227])
	by eazy.amigager.de (Postfix) with ESMTPA id 34256F3001A
	for <linux-nfs@vger.kernel.org>; Thu, 10 Feb 2011 22:49:11 +0100 (CET)
Date: Thu, 10 Feb 2011 22:49:14 +0100
From: Tino Keitel <tino.keitel@tikei.de>
To: linux-nfs@vger.kernel.org
Subject: Re: 2.6.38-rc3: kernel BUG at fs/nfsd/nfs4state.c:3132!
Message-ID: <20110210214914.GA24324@mac.home>
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

It is something after -rc3, and I have another patch applied (regarding
sd devices at suspend wakeup).

My nfs4state.c was last touched by the merge commit
18bce371ae09af6c20ee62c1092a4d1d0e84dd49.

Regards,
Tino
