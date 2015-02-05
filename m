Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:35918 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960AbbBEQGl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2015 11:06:41 -0500
Message-ID: <54D3950A.5050906@Netapp.com>
Date: Thu, 5 Feb 2015 11:06:34 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/6] NFS: Add READ_PLUS support for data segments
References: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com> <1422477830-28090-2-git-send-email-Anna.Schumaker@Netapp.com> <20150205141007.GA4522@infradead.org>
In-Reply-To: <20150205141007.GA4522@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2015 09:10 AM, Christoph Hellwig wrote:
> On Wed, Jan 28, 2015 at 03:43:45PM -0500, Anna Schumaker wrote:
>> +	if (type == NFS4_CONTENT_DATA)
>> +		status = decode_read_plus_data(xdr, res);
>> +	else
>> +		status = -ENOTSUPP;
>> +
>> +	if (segments > 1)
>> +		res->eof = 0;
> 
> Given that the server can return any amount of data and hole
> segments it doesn't make any sense to separate this patch from patches 4
> and 6.
> 

I had them split up to make development easier, but I can squash them together if that would make more sense.
