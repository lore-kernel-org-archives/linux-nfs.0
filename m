Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40196 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbcFOHIl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 03:08:41 -0400
Date: Wed, 15 Jun 2016 00:08:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/12] NFS: Don't hold the inode lock across fsync()
Message-ID: <20160615070840.GA4318@infradead.org>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 14, 2016 at 03:05:09PM -0400, Trond Myklebust wrote:
> Commits are no longer required to be serialised.

But we need something to lock out new callers of inode_dio_end
when calling inode_dio_wait.  Then again the current code already
fails to to do that..
