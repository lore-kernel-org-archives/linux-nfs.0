Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50768 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab0LPXlC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 18:41:02 -0500
Date: Thu, 16 Dec 2010 18:40:58 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Ric Wheeler <ricwheeler@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Steve Dickson <SteveD@redhat.com>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
Message-ID: <20101216234058.GA17940@infradead.org>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
 <4D0A6503.7010901@RedHat.com>
 <20101216230524.GA16760@infradead.org>
 <4D0AA11A.2010307@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D0AA11A.2010307@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 16, 2010 at 06:30:34PM -0500, Ric Wheeler wrote:
> This has nothing to do with shame or conspiracy, it has to do with
> doing changes in an orderly way so we can test and stabilize things
> in the upstream kernel.
> 
> Changing both at once is not good for upstream or distros  in my opinion,

Steve's mail reads pretty different from that.

But it doesn't really matter as it doesn't make any sense - as Chuck
has explained theres zero overlap between the XDR decoder changes and
pnfs features anyway.  And if there was it's pretty clear something that
the about 98% of the userbase that's using NFSv3 uses should have more
priority over the 0.5% that are planning to maybe possibly use pnfs in
the next decade.
