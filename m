Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49714 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbaCJIEh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Mar 2014 04:04:37 -0400
Date: Mon, 10 Mar 2014 01:04:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH] nfsd4: fix memory leak in nfsd4_encode_fattr()
Message-ID: <20140310080437.GA24753@infradead.org>
References: <1394427127-9985-1-git-send-email-zheng.z.yan@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1394427127-9985-1-git-send-email-zheng.z.yan@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 12:52:07PM +0800, Yan, Zheng wrote:
> fh_put() does not free the temporary file handle.

Btw, it seems like the code to generate the file handle if it's missing
should be moved out of nfsd4_encode_fattr and into
nfsd4_encode_dirent_fattr or a small helper just called from there so that:

 a) the code flow is more obvious
 b) the calling conventions for nfsd4_encode_fattr are sensible
 c) nfsd4_encode_fattr shrinks at least a tiny bit
 d) the required cleanup becomes more obvious by being paired with the
    allocation and initialization of the FH.

Just curious: which client asks for the FH or FSID in READDIRPLUS?
