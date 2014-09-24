Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52360 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912AbaIXIWH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 04:22:07 -0400
Date: Wed, 24 Sep 2014 10:22:04 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: Re: CB_RECALL fixes
Message-ID: <20140924082204.GA8894@lst.de>
References: <1411455529-11556-1-git-send-email-hch@lst.de> <20140923193302.GK29932@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140923193302.GK29932@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 03:33:02PM -0400, J. Bruce Fields wrote:
> On Tue, Sep 23, 2014 at 08:58:47AM +0200, Christoph Hellwig wrote:
> > First one fixes error handling in nfsd4_cb_recall_done, second is a fix from
> > Benny in the old pnfs tree which applies to restarted delegation recalls
> > as well.
> 
> Thanks, applying both for 3.18.
> 
> (Assuming that's what you intended.  When you want nfsd patches applied,
> could you do an explicit To: bfields@fieldses.org ?)

Yes, and I'll send it to you with cc to linux-nfs next time, sorry.
