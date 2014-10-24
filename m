Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33263 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756587AbaJXNm6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 09:42:58 -0400
Date: Fri, 24 Oct 2014 06:42:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeffrey Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Ensure that NFSv4 always drops the connection when
 dropping a request
Message-ID: <20141024134258.GA16355@infradead.org>
References: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
 <1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 24, 2014 at 01:08:28PM +0300, Trond Myklebust wrote:
> Both RFC3530 and RFC5661 impose a requirement on the server that it MUST NOT
> drop a request unless the connection is broken.

I can still reproduce the issue with this patch applied.
