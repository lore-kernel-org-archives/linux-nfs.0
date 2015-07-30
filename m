Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38250 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbG3Psl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 11:48:41 -0400
Date: Thu, 30 Jul 2015 08:48:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/5] nfsd: Fix a encode bug of FS_LAYOUT_TYPES and
 LAYOUT_TYPES
Message-ID: <20150730154840.GA1073@infradead.org>
References: <55BA2B46.90204@gmail.com>
 <55BA2C2C.10507@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55BA2C2C.10507@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 30, 2015 at 09:52:44PM +0800, Kinglong Mee wrote:
> Each bitmap needs one layout_type information,
> if setting both, nfsd only return one right now.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Indeed.  Thanks for catching this.

Reviewed-by: Christoph Hellwig <hch@lst.de>
