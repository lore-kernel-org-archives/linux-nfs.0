Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50091 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbaCJKVC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Mar 2014 06:21:02 -0400
Date: Mon, 10 Mar 2014 03:21:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v3] nfsd4: fix memory leak in nfsd4_encode_fattr()
Message-ID: <20140310102101.GA25752@infradead.org>
References: <1394444501-20826-1-git-send-email-zheng.z.yan@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1394444501-20826-1-git-send-email-zheng.z.yan@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 05:41:41PM +0800, Yan, Zheng wrote:
> The temporary file handle should be freed when nfsd4_encode_fattr()
> finishes its job. Christoph Hellwig suggests to move the code that
> generates the temporary file handle into nfsd4_encode_dirent_fattr()
> 
> Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>

I'd also add a BUG_ON to assert we have the file handle if needed in
nfsd4_encode_fattr.

But maybe I was a bit too fast in my initial reply and we should put in
your simple fix first for the current -rc and -stable and have the
cleanup on top of it.  There's a lot more refactoring that should be
done to nfsd4_encode_fattr anyway.

