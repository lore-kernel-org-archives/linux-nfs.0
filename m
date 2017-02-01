Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26316 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750974AbdBATkD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2017 14:40:03 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 2/7] svcrdma: Clean up RPC-over-RDMA Reply header encoder
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170201182518.GA32532@infradead.org>
Date: Wed, 1 Feb 2017 14:39:08 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <27A37972-64DA-4300-874A-DF980D150D6B@oracle.com>
References: <20170131184623.14185.35480.stgit@klimt.1015granger.net> <20170131185302.14185.10775.stgit@klimt.1015granger.net> <20170201182518.GA32532@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 1, 2017, at 1:25 PM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> I'm always confused when a cleanup adds more line than it removes,
> but it seems to be just comments in this case and some other
> patches in the series.
> 
>> + * svc_rdma_xdr_encode_reply_header - Encode Reply's fixed header fields
>> + * @rdma: controlling transport
>> + * @rdma_argp: Call's transport header
>> + * @rdma_resp: Reply's transport header
>> + * @rdma_type: procedure number
>> + *
>> + */
>> +void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *rdma,
>> +				      __be32 *rdma_argp, __be32 *rdma_resp,
>> +				      __be32 rdma_type)
> 
> To me it would seem much cleaner to just take the few lines of encoding
> into the only caller.

Fair enough, that's what is done in the backchannel.


--
Chuck Lever



