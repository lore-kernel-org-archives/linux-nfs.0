Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55124 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaHKRju (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 13:39:50 -0400
Date: Mon, 11 Aug 2014 10:39:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/3] nfs4: queue free_lock_state job submission to
 nfsiod
Message-ID: <20140811173949.GB20080@infradead.org>
References: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
 <1398940127-31150-3-git-send-email-jlayton@poochiereds.net>
 <20140811104253.GA4747@infradead.org>
 <20140811075013.77e0a29e@tlielax.poochiereds.net>
 <20140811090417.0287b32b@tlielax.poochiereds.net>
 <20140811150924.GA3683@infradead.org>
 <20140811113557.692d408b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140811113557.692d408b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> the openowner. We don't have a pointer directly to that, so we're
> probably best off just holding a reference to the open stateid, and
> pinning the superblock too.
> 
> Maybe something like this instead? I'm also running xfstests on a VM
> now to see if I can reproduce this and verify the fix:

This version has survived several xfstests run so far, so it seems
good.  I'll keep running it a bit longer.

