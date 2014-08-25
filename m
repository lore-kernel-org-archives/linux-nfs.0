Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:40823 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932398AbaHYOVB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 10:21:01 -0400
Date: Mon, 25 Aug 2014 16:20:59 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/19] pnfs: add return_range method
Message-ID: <20140825142059.GA14932@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-9-git-send-email-hch@lst.de> <53FB3F2A.409@Netapp.com> <20140825140952.GA13911@lst.de> <53FB4574.9090205@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53FB4574.9090205@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 25, 2014 at 10:17:24AM -0400, Anna Schumaker wrote:
> > To catch the intent - the first two clauses find excuses why we can't return
> > quite yet, while this if is for an optional feature in the actual return
> > path. If I wasn't updating but newly writing the function I'd actually
> > do something like:
> 
> I'm a fan of nice looking code, and I like what you have below better.  Can you arrange things to end up in this state?  Or maybe send a cleanup patch after?

I'll send a cleanup later, that is unless I need to respin the series in this
area anyway for Boaz different layoutcommit on recall proposal.

