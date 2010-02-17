From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] xfs_export_operations.commit_metadata
Date: Thu, 18 Feb 2010 10:05:44 +1100
Message-ID: <20100217230544.GY28392@discord.disaster>
References: <20100217200426.13409.32688.stgit@case> <20100217200516.13409.97524.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bld-mail18.adl2.internode.on.net ([150.101.137.103]:41572 "EHLO
	mail.internode.on.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755520Ab0BQXFv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2010 18:05:51 -0500
In-Reply-To: <20100217200516.13409.97524.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2010 at 02:05:16PM -0600, Ben Myers wrote:
> This is the commit_metadata export operation for XFS.
> 
> - Takes one inode to be committed.
> 
> - Forces the log up to the lsn of the inode.
> 
> - Doesn't force the log if the inode doesn't have a pincount.
> 
> Signed-off-by: Ben Myers <bpm@sgi.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Looks good, Ben.

Reviewed-by: Dave Chinner <david@fromorbit.com>

-- 
Dave Chinner
david@fromorbit.com
