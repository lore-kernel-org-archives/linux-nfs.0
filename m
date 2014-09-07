Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44047 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbaIGPfi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Sep 2014 11:35:38 -0400
Date: Sun, 7 Sep 2014 08:35:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/3] nfs4: queue free_lock_state job submission to
 nfsiod
Message-ID: <20140907153534.GA7026@infradead.org>
References: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
 <1398940127-31150-3-git-send-email-jlayton@poochiereds.net>
 <20140811104253.GA4747@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140811104253.GA4747@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This one is still reliably reproducable in Linus' tree.  While we
got Jeff's patch to allow sleeping in the lock methods in, the workqueue
call in nfs hasn't been reverted yet, so this is expect.
