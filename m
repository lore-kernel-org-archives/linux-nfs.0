Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59560 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbaFGOIB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:08:01 -0400
Date: Sat, 7 Jun 2014 07:08:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSd: nfs4_preprocess_seqid_op should only set *stpp on
 success
Message-ID: <20140607140800.GA18140@infradead.org>
References: <1402080994-23737-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1402080994-23737-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 06, 2014 at 02:56:34PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

The new code looks correct, but shouldn't callers already take care
not to use the returned stateid only if nfs4_preprocess_seqid_op returns
0?

