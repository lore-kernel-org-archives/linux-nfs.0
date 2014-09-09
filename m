Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52380 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbaIIRxk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 13:53:40 -0400
Date: Tue, 9 Sep 2014 10:53:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] NFSD: Add generic v4.2 infrastructure
Message-ID: <20140909175337.GA10399@infradead.org>
References: <1409679038-32179-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1409679038-32179-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409679038-32179-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 02, 2014 at 01:30:37PM -0400, Anna.Schumaker@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> It's cleaner to introduce everything at once and have the server reply
> with "not supported" than it would be to introduce extra operations when
> implementing a specific one in the middle of the list.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
