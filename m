Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:59338 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754010Ab1GNWZ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2011 18:25:58 -0400
Subject: Re: [PATCH] xfs: failure mapping nfs fh to inode should return
 ESTALE
From: Alex Elder <aelder@sgi.com>
Reply-To: <aelder@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <xfs-masters@oss.sgi.com>, <xfs@oss.sgi.com>, <linux-nfs@vger.kernel.org>
In-Reply-To: <20110714205036.GA19457@fieldses.org>
References: <20110714205036.GA19457@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Jul 2011 17:25:50 -0500
Message-ID: <1310682350.2067.110.camel@doink>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-07-14 at 16:50 -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> On xfs exports, nfsd is incorrectly returning ENOENT instead of ESTALE
> on attempts to use a filehandle of a deleted file (spotted with pynfs
> test PUTFH3).  The ENOENT was coming from xfs_iget.
> 
> (It's tempting to wonder whether we should just map all xfs_iget errors
> to ESTALE, but I don't believe so--xfs_iget can also return ENOMEM at
> least, which we wouldn't want mapped to ESTALE.)
> 
> While we're at it, the other return of ENOENT in xfs_nfs_get_inode()
> also looks wrong.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Looks reasonable to me.

I'll give others a chance to weigh in, but otherwise I'll
get this in for Linux 3.1.

Reviewed-by: Alex Elder <aelder@sgi.com>


