Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:52199 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753621AbbCENTD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2015 08:19:03 -0500
Date: Thu, 5 Mar 2015 14:19:01 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dave Chinner <david@fromorbit.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150305131901.GB16235@lst.de>
References: <20150303221033.GB19439@fieldses.org> <20150303224456.GV4251@dastard> <20150304020826.GD19439@fieldses.org> <20150304044141.GQ18360@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150304044141.GQ18360@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 04, 2015 at 03:41:41PM +1100, Dave Chinner wrote:
> As I understand it, nothing will prevent this - if you don't change
> the UUID on the filesystem when you clone it, then the UUID will
> still match and writes can be directed to any block deice with a
> matching offset/UUID pair.

Unfortunately that's the case indeed.  The whole discovery part of
the block layout protocol is fundamentally flawed, as is the recall
part.  This is my attempt to fix it, but I have no idea how to proceed
from posting my draft to the IETF to actually making it a standard:

http://tools.ietf.org/html/draft-hellwig-nfsv4-scsi-layout-00
