Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48144 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab0HSJpS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Aug 2010 05:45:18 -0400
Date: Thu, 19 Aug 2010 05:45:16 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, andros@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 05/50] pnfs_submit: pnfs and nfslayoutdriver kconfig
Message-ID: <20100819094516.GC15610@infradead.org>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <20100818202559.GA16851@infradead.org>
 <4C6C4BF2.30308@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C6C4BF2.30308@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 19, 2010 at 12:09:06AM +0300, Benny Halevy wrote:
> >> +	default y
> > 
> > defaulting to y for random fringe features is frowned upon.
> 
> The problem is that it will rot otherwise.
> I'd rather disable it by default using a variable and provide a way to
> enable it at run time.

That's unrelated.  Features should not default to y in Kconfig except
for very specific cases, e.g. when a new variable is required to be
set to keep working from a previous setup.  pNFS clearly does not fall
into that category.

