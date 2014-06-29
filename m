Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:32892 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbaF2MAG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 08:00:06 -0400
Date: Sun, 29 Jun 2014 05:00:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 021/117] nfsd: clean up nfsd4_close_open_stateid
Message-ID: <20140629120003.GA16150@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-22-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-22-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:12:01PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Minor cleanup that should introduce no behavioral changes.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

The actual change looks okay, the changelog is severly lacking,
as it nicer explains what changed nor why.

