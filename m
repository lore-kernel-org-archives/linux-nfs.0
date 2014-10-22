Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33614 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932859AbaJVLqu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Oct 2014 07:46:50 -0400
Date: Wed, 22 Oct 2014 04:46:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: xfstests generic/075 failure on recent Linus' tree
Message-ID: <20141022114649.GA2567@infradead.org>
References: <20141020173658.GA7552@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141020173658.GA7552@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 20, 2014 at 10:36:58AM -0700, Christoph Hellwig wrote:
> Running 4.1 against a same host server backed off XFS I run into
> a hang in generic/075:

I've bisected this down to:

commit 2aca5b869ace67a63aab895659e5dc14c33a4d6e
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Wed Sep 24 22:35:58 2014 -0400

    SUNRPC: Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT


Note that I can only reproduce it when running locally, and only when
not using pNFS (block layout).
