Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34568 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaF2Gt6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 02:49:58 -0400
Date: Sat, 28 Jun 2014 23:49:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 020/117] nfsd: Cleanup - Let nfsd4_lookup_stateid()
 take a cstate argument
Message-ID: <20140629064956.GC17739@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-21-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-21-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:12:00PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> The cstate already holds information about the session, and hence
> the client id, so it makes more sense to pass that information
> rather than the current practice of passing a 'minor version' number.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
