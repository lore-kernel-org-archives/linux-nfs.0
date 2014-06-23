Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39023 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972AbaFWQFu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:05:50 -0400
Date: Mon, 23 Jun 2014 09:05:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 006/104] NFSd: Add a mutex to protect the NFSv4.0 open
 owner replay cache
Message-ID: <20140623160549.GD24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-7-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403189450-18729-7-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 19, 2014 at 10:49:12AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> We don't want to rely on the state_lock() for protection in the
> case of NFSv4 open owners. Instead, we add a mutex that will
> only be taken for NFSv4.0 state mutating operations, and
> that will be released once the entire compound is done.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks reasonable to me, but doesn't this create a lock order reversal
with the client_lock until it is removed?  

