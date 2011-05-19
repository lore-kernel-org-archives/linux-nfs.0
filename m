Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3808 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932669Ab1ESMqK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2011 08:46:10 -0400
Message-ID: <4DD51116.4060102@panasas.com>
Date: Thu, 19 May 2011 15:46:14 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 12/29] pnfs-obj: decode layout, alloc/free lseg
References: <4DD14D8E.1070701@panasas.com> <1305562935-7738-1-git-send-email-bhalevy@panasas.com> <4DD43666.5040304@panasas.com>
In-Reply-To: <4DD43666.5040304@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/19/2011 12:13 AM, Benny Halevy wrote:
<snip>
>> +/*
>> + * Unmarshall layout and store it in pnfslay.
>> + */
>> +struct pnfs_layout_segment *
>> +objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
>> +		     struct nfs4_layoutget_res *lgr)
>> +{
>> +	int status = -ENOMEM;
>> +	struct xdr_stream stream;
>> +	struct xdr_buf buf = {
>> +		.pages =  lgr->layoutp->pages,
>> +		.page_len =  lgr->layoutp->len,
>> +		.buflen =  lgr->layoutp->len,
>> +		.len = lgr->layoutp->len,
>> +	};
> 
> - layering violation
> - introduce xdr_init_decode_pages(struct xdr_stream *, struct xdr_buf *,
> pages, len);
> - use also in filelayout_decode_layout
> 
> Benny
> 
<snip>

Benny if you are at it I was looking at this code. If the Files layout does
it and objects and so will blocks. Could we construct the xdr_buf at the
generic layer (with your above func). And pass the xdr_buf* in the lgr directly.
I think it would be cleaner.

Thanks
Boaz
