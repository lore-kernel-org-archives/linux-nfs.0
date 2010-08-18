From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 06/50] pnfs_submit: introduce include/linux/nfs4_pnfs.h
Date: Wed, 18 Aug 2010 16:27:18 -0400
Message-ID: <20100818202718.GB16851@infradead.org>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org,
	Dean Hildebrand <seattleplus@gmail.com>
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42918 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976Ab0HRU1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:27:19 -0400
In-Reply-To: <1281735122-1496-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +++ b/include/linux/nfs4_pnfs.h
> @@ -0,0 +1,15 @@
> +/*
> + *  include/linux/nfs4_pnfs.h

Please don't include these kinds of comments, they only purpose they
serve is frequently getting out of date.  That applies to just about
every file added in this series.

> + *
> + *  Common data structures needed by the pnfs client and pnfs layout driver.
> + *
> + *  Copyright (c) 2002 The Regents of the University of Michigan.
> + *  All rights reserved.
> + *
> + *  Dean Hildebrand   <dhildebz-nNDzPDmKTdnSiEDVxGk4TQ@public.gmane.org>
> + */
> +
> +#ifndef LINUX_NFS4_PNFS_H
> +#define LINUX_NFS4_PNFS_H
> +
> +#endif /* LINUX_NFS4_PNFS_H */

Adding a file that only contains copyrights and inclusion headers is
rather odd.  I think you want your split a little more corse grained.

