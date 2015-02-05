Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:62237 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757733AbbBEQGG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2015 11:06:06 -0500
Message-ID: <54D394EC.9030902@Netapp.com>
Date: Thu, 5 Feb 2015 11:06:04 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com> <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com> <20150205141325.GC4522@infradead.org>
In-Reply-To: <20150205141325.GC4522@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2015 09:13 AM, Christoph Hellwig wrote:
>> +	p = xdr_reserve_space(xdr, 4 + 8 + 4); /* content type, offset, maxcount */
>> +	if (!p)
>> +		return nfserr_resource;
>> +	xdr_commit_encode(xdr);
>> +
>> +	maxcount = svc_max_payload(resp->rqstp);
>> +	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
>> +	maxcount = min_t(unsigned long, maxcount, read->rd_length);
>> +
>> +	err = nfsd4_encode_readv(resp, read, file, &maxcount);
> 
> If the READ_PLUS implementation can't use the splice read path it's
> probably a loss for most workloads.
> 

I'll play around with the splice path, but I don't think it was designed for encoding multiple read segments.
