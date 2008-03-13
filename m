From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs: fix encode_fsinfo_maxsz
Date: Thu, 13 Mar 2008 12:55:12 -0400
Message-ID: <1205427312.11399.23.camel@heimdal.trondhjem.org>
References: <1205414790-1710-1-git-send-email-bhalevy@panasas.com>
	 <1205425264.11399.3.camel@heimdal.trondhjem.org>
	 <Pine.BSO.4.64.0803131227380.29614@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
To: Fredric Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:44120 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753765AbYCMQzS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 12:55:18 -0400
In-Reply-To: <Pine.BSO.4.64.0803131227380.29614@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-03-13 at 12:29 -0400, Fredric Isaman wrote:
> 
> On Thu, 13 Mar 2008, Trond Myklebust wrote:
> > Has this ever been observed to cause problems in the mainline NFSv4?
> > Having never seen any such problems myself, I'm a bit inclined to delay
> > this until the 2.6.26 merge window. That said, if you can point to an
> > instance where it caused a bug, then I'll push it to Linus sooner.
> >
> > Cheers
> >  Trond
> >
> >
> 
> I just noticed it in the process of adding some attributes to fsinfo, as 
> opposed to searching down a bug.

OK. I'll queue it up for 2.6.26, then.

Again thanks!

  Trond

