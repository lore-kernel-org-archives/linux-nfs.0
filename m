From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 09/50] pnfs_submit: introduce fs/nfs/pnfs.c
Date: Thu, 19 Aug 2010 13:21:32 -0400
Message-ID: <20100819172132.GG30151@fieldses.org>
References: <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <20100818202824.GC16851@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andros@netapp.com, bhalevy@panasas.com, linux-nfs@vger.kernel.org,
	Dean Hildebrand <dhildebz-nNDzPDmKTdnSiEDVxGk4TQ@public.gmane.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49381 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000Ab0HSRXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 13:23:43 -0400
In-Reply-To: <20100818202824.GC16851@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 18, 2010 at 04:28:24PM -0400, Christoph Hellwig wrote:
> This file uses a different license than the rest of Linux.  I think
> you at least need to dual-license it under the GPLv2.

It's a common BSD-like license, GPL-compatible, and already used
elsewhere.  There's no need to dual-license.

(Agreed with point elsewhere that this should be merged with another
patch.)

--b.
