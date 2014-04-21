Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44069 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbaDUNJa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 09:09:30 -0400
Date: Mon, 21 Apr 2014 06:09:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/17] NFS: Create a common path used by reads and writes
Message-ID: <20140421130926.GA24289@infradead.org>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20140421064204.GA19231@infradead.org>
 <53551339.5030207@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53551339.5030207@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 21, 2014 at 08:46:49AM -0400, Anna Schumaker wrote:
> On 04/21/2014 02:42 AM, Christoph Hellwig wrote:
> > On Thu, Apr 17, 2014 at 05:09:24PM -0400, Anna Schumaker wrote:
> >> Questions?  Comments?  Death threats?
> > Can you say what tree this is based on or even better publish a git
> > tree?  I tried to apply the series to various trees so that I can get a
> > better picture for further reviews, but git-am always bailed out
> > somewhere.
> Oops, sorry!  This is based on Trond's testing branch.  I can work on putting out a git tree later today!

Played around a bit more, and it seems like it's Trond's testing branch
+ my two pgio cleanups.  With that I managed to apply your patches.

