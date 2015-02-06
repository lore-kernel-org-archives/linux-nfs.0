Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44822 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbbBFLzC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Feb 2015 06:55:02 -0500
Date: Fri, 6 Feb 2015 03:54:56 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150206115456.GA28915@infradead.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20150205141325.GC4522@infradead.org>
 <54D394EC.9030902@Netapp.com>
 <20150205162326.GA18977@infradead.org>
 <54D39DC2.9060808@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54D39DC2.9060808@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 05, 2015 at 11:43:46AM -0500, Anna Schumaker wrote:
> > The problem is that the typical case of all data won't use splice
> > every with your patches as the 4.2 client will always send a READ_PLUS.
> > 
> > So we'll have to find a way to use it where it helps.  While we might be
> > able to add some hacks to only use splice for the first segment I guess
> > we just need to make the splice support generic enough in the long run.
> > 
> 
> I should be able to use splice if I detect that we're only returning a single DATA segment easily enough.

You could also elect to never return more than one data segment as a
start:

   In all situations, the
   server may choose to return fewer bytes than specified by the client.
   The client needs to check for this condition and handle the
   condition appropriately.

But doing any of these for a call that's really just an optimization
soudns odd.  I'd really like to see an evaluation of the READ_PLUS
impact on various workloads before offering it.
