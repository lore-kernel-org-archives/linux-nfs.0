Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:39632 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753537AbdFSPai (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jun 2017 11:30:38 -0400
Date: Mon, 19 Jun 2017 08:30:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
Message-ID: <20170619153018.GA2667@infradead.org>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
 <20170616152254.14210.48071.stgit@klimt.1015granger.net>
 <20170617150705.GA27917@infradead.org>
 <A573E1EB-48DB-4E4A-B710-34914B0CF016@oracle.com>
 <20170618073438.GA15358@infradead.org>
 <14AD4311-5092-441C-8A3B-F7EC7E801358@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14AD4311-5092-441C-8A3B-F7EC7E801358@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 19, 2017 at 11:22:41AM -0400, Chuck Lever wrote:
> I'm going to submit this again with a comment change and
> Jeff's Reviewed-by. Can I add your Reviewed-by as well?

It looks ok as a quick fix for me but at least needs a big comment.
I'd also be much happier if we could find and fix the root cause.
