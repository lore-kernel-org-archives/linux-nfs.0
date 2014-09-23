Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60893 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbaIWTdE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 15:33:04 -0400
Date: Tue, 23 Sep 2014 15:33:02 -0400
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: Re: CB_RECALL fixes
Message-ID: <20140923193302.GK29932@fieldses.org>
References: <1411455529-11556-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1411455529-11556-1-git-send-email-hch@lst.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 08:58:47AM +0200, Christoph Hellwig wrote:
> First one fixes error handling in nfsd4_cb_recall_done, second is a fix from
> Benny in the old pnfs tree which applies to restarted delegation recalls
> as well.

Thanks, applying both for 3.18.

(Assuming that's what you intended.  When you want nfsd patches applied,
could you do an explicit To: bfields@fieldses.org ?)

--b.
