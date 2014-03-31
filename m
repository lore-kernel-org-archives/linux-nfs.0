Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbaCaVLO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Mar 2014 17:11:14 -0400
Date: Mon, 31 Mar 2014 17:11:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] nfsd4: fix memory leak in nfsd4_encode_fattr()
Message-ID: <20140331211100.GC20024@fieldses.org>
References: <1394444501-20826-1-git-send-email-zheng.z.yan@intel.com>
 <20140310102101.GA25752@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140310102101.GA25752@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 03:21:01AM -0700, Christoph Hellwig wrote:
> On Mon, Mar 10, 2014 at 05:41:41PM +0800, Yan, Zheng wrote:
> > The temporary file handle should be freed when nfsd4_encode_fattr()
> > finishes its job. Christoph Hellwig suggests to move the code that
> > generates the temporary file handle into nfsd4_encode_dirent_fattr()
> > 
> > Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>
> 
> I'd also add a BUG_ON to assert we have the file handle if needed in
> nfsd4_encode_fattr.
> 
> But maybe I was a bit too fast in my initial reply and we should put in
> your simple fix first for the current -rc and -stable and have the
> cleanup on top of it.  There's a lot more refactoring that should be
> done to nfsd4_encode_fattr anyway.

Makes sense; applying the bare fix for 3.15 with a stable cc, assuming
somebody will follow up with any cleanup.  (Moving this case to
nfsd4_encode_dirent_fattr() as in this patch certianly looks fine to
me.)

--b.
