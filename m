From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] NFS: return -EAGAIN when skipped commit in
 nfs_commit_unstable_pages()
Date: Tue, 14 Jun 2011 10:30:42 +0800
Message-ID: <20110614023042.GA5174@localhost>
References: <20110610140459.GA8021@localhost>
 <1307993886.5569.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47259 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab1FNCav (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 22:30:51 -0400
In-Reply-To: <1307993886.5569.3.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > @@ -1521,7 +1521,7 @@ static int nfs_commit_unstable_pages(str
> >  {
> >  	struct nfs_inode *nfsi = NFS_I(inode);
> >  	int flags = FLUSH_SYNC;
> > -	int ret = 0;
> > +	int ret = -EAGAIN;
> >  
> >  	if (wbc->sync_mode == WB_SYNC_NONE) {
> >  		/* Don't commit yet if this is a non-blocking flush and there
> 
> Looks good, but since this is a cleanup, I'm queueing it for 3.1 rather
> than pushing it in the regression-fixing window.

OK, thanks!

Thanks,
Fengguang
