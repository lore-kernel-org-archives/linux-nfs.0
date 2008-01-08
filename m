From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/3] Remove per-lock-operation nlm_lookup_host() call
Date: Tue, 8 Jan 2008 16:37:39 +0000
Message-ID: <20080108163739.GA20897@infradead.org>
References: <20080108152113.20097.96094.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:49031 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510AbYAHQhw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 11:37:52 -0500
In-Reply-To: <20080108152113.20097.96094.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2008 at 10:31:59AM -0500, Chuck Lever wrote:
> By pinning an nlm_host for each mount point, we trade the overhead of
> looking up or creating a fresh nlm_host struct during every NLM procedure
> call for a little extra memory space utilization.

This sound like exactly the trade off we do everywhere else in the
filesystem / VFS code :)

