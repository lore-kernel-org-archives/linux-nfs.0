Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:39233 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752088AbdLCVK6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 16:10:58 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] xprtrdma: Spread reply processing over more CPUs
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20171203183523.GA29539@infradead.org>
Date: Sun, 3 Dec 2017 13:52:28 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <52245049-E101-4148-8A35-10368379FF20@oracle.com>
References: <20171202212840.11321.83261.stgit@manet.1015granger.net> <20171203183523.GA29539@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 3, 2017, at 1:35 PM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> Hmm.  I'd love to find a way to handle this in the core code, but until
> that is done you should probably move sc_rq_cq to execture in softirq
> code.

You mean revert a4699f5647f3 as well? I tried that in combination
with this change, and it did not result in any difference in
throughput results.


--
Chuck Lever



