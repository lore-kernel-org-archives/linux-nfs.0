Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:48018 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdLCT2p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 14:28:45 -0500
Date: Sun, 3 Dec 2017 11:28:44 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] xprtrdma: Spread reply processing over more CPUs
Message-ID: <20171203192844.GB311@infradead.org>
References: <20171202212840.11321.83261.stgit@manet.1015granger.net>
 <20171203183523.GA29539@infradead.org>
 <52245049-E101-4148-8A35-10368379FF20@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52245049-E101-4148-8A35-10368379FF20@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 03, 2017 at 01:52:28PM -0500, Chuck Lever wrote:
> 
> > On Dec 3, 2017, at 1:35 PM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > Hmm.  I'd love to find a way to handle this in the core code, but until
> > that is done you should probably move sc_rq_cq to execture in softirq
> > code.
> 
> You mean revert a4699f5647f3 as well? I tried that in combination
> with this change, and it did not result in any difference in
> throughput results.

Ok.  I guess we can leave things as-is for now then.
