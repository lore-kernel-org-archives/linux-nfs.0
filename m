Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:29497 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754900AbbCDElp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 23:41:45 -0500
Date: Wed, 4 Mar 2015 15:41:41 +1100
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150304044141.GQ18360@dastard>
References: <20150303221033.GB19439@fieldses.org>
 <20150303224456.GV4251@dastard>
 <20150304020826.GD19439@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150304020826.GD19439@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2015 at 09:08:26PM -0500, J. Bruce Fields wrote:
> By the way, Christoph, an unrelated question: how are the devices found,
> and what are the chances of a client writing to the wrong block device?
> 
> (E.g., if they're addressed based on a uuid that doesn't change on
> cloning the block device, and if the client had access to another device
> with an identical copy of the filesystem, could it end up writing to
> that instead?)

As I understand it, nothing will prevent this - if you don't change
the UUID on the filesystem when you clone it, then the UUID will
still match and writes can be directed to any block deice with a
matching offset/UUID pair.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
