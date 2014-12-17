Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59176 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087AbaLQTB1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 14:01:27 -0500
Date: Wed, 17 Dec 2014 14:01:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] nfsd: fi_delegees bugfix and cleanup
Message-ID: <20141217190124.GC9617@fieldses.org>
References: <1418479900-4757-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1418479900-4757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 13, 2014 at 09:11:38AM -0500, Jeff Layton wrote:
> As I mentioned on IRC yesterday, here are a couple of patches to the
> fi_delegees handling. The first one fixes a bug. I think it's pretty
> unlikely to be hit in most cases, so I'm not sure if it's suitable for
> stable. Your call there.
> 
> The second is just a cleanup patch -- fi_delegees is always handled
> under spinlock so it really doesn't need to be an atomic_t.

Sorry for the slow response, applying for 3.19 and stable (well, the
first anyway), may not get that passed along till -rc2.

--b.

> 
> Jeff Layton (2):
>   nfsd: fix fi_delegees leak when fi_had_conflict returns true
>   nfsd: fi_delegees doesn't need to be an atomic_t
> 
>  fs/nfsd/nfs4state.c | 8 ++++----
>  fs/nfsd/state.h     | 2 +-
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> -- 
> 2.1.0
> 
