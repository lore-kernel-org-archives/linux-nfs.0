Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52849 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbbDFMCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2015 08:02:48 -0400
Date: Mon, 6 Apr 2015 05:02:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfsd: clear NFSEXP_PNFS flags if not supports pnfs in
 kernel
Message-ID: <20150406120247.GB13634@infradead.org>
References: <55215117.2050504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55215117.2050504@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 05, 2015 at 11:13:27PM +0800, Kinglong Mee wrote:
> nfsd should not show "pnfs" flag in proc file if the filesystem
> does not support pnfs.

Hmm, do we want to silently clear or reject it?  Either way the
!CONFIG_NFSD_PNFS stub needs to do the same.
