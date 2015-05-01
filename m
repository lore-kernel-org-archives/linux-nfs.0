Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:54466 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786AbbEAIoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 May 2015 04:44:05 -0400
Date: Fri, 1 May 2015 10:44:03 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd: fix callback restarts
Message-ID: <20150501084403.GA9315@lst.de>
References: <1430387365-24348-1-git-send-email-hch@lst.de> <1430387365-24348-3-git-send-email-hch@lst.de> <20150430203556.GA9509@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150430203556.GA9509@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 30, 2015 at 04:35:56PM -0400, J. Bruce Fields wrote:
> This is an rpc callback, so tk_client better still be allocated.
> cl_cb_client too, since as far as I can tell that's never changed
> without shutting down the rpc client first (which will wait for all
> tasks to exit).
> 
> So I agree that this is wrong, but I think the reason it's actually
> wrong is that the condition is just never true....

It was never true in my testing, but I assumed that was because
of slab reuse.  So you're probably right here.
