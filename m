Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60270 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757842AbbBEQX1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 11:23:27 -0500
Date: Thu, 5 Feb 2015 08:23:26 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150205162326.GA18977@infradead.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20150205141325.GC4522@infradead.org>
 <54D394EC.9030902@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54D394EC.9030902@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 05, 2015 at 11:06:04AM -0500, Anna Schumaker wrote:
> > If the READ_PLUS implementation can't use the splice read path it's
> > probably a loss for most workloads.
> > 
> 
> I'll play around with the splice path, but I don't think it was designed for encoding multiple read segments.

The problem is that the typical case of all data won't use splice
every with your patches as the 4.2 client will always send a READ_PLUS.

So we'll have to find a way to use it where it helps.  While we might be
able to add some hacks to only use splice for the first segment I guess
we just need to make the splice support generic enough in the long run.
