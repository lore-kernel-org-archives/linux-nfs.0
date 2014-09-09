Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:61980 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408AbaIITRv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 15:17:51 -0400
Message-ID: <540F5259.1090203@Netapp.com>
Date: Tue, 9 Sep 2014 15:17:45 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 2/2] NFSD: Implement SEEK
References: <1409679038-32179-1-git-send-email-Anna.Schumaker@Netapp.com> <1409679038-32179-3-git-send-email-Anna.Schumaker@Netapp.com> <20140909175607.GB10399@infradead.org>
In-Reply-To: <20140909175607.GB10399@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/09/2014 01:56 PM, Christoph Hellwig wrote:
>> +	switch (seek->seek_whence) {
>> +	case NFS4_CONTENT_DATA:
>> +		seek->seek_pos = vfs_llseek(file, seek->seek_offset, SEEK_DATA);
>> +		break;
>> +	case NFS4_CONTENT_HOLE:
>> +		seek->seek_pos = vfs_llseek(file, seek->seek_offset, SEEK_HOLE);
>> +		break;
>> +	default:
>> +		status = nfserr_union_notsupp;
>> +		goto out;
>> +	}
> 
> nipick: maybe just assign pos in the switch, and have a single
> vfs_llseek call?
> 
> Also this might want a comment that vfs_llseek is changing file->f_pos,
> but nothing in NFSD should ever rely on file->f_pos.

Sure.

> 
>>  static __be32
>> +nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
>> +		  struct nfsd4_seek *seek)
>> +{
>> +	__be32 *p;
>> +
>> +	if (nfserr)
>> +		return nfserr;
>> +
>> +	p = xdr_reserve_space(&resp->xdr, 12);
> 
> nipick: can you replace the 12 by a "4 + 8"?  I think having one
> literal for each field later encoded helps reading the XDR code a lot.
> And although it might not matter for a trivial encoder like this it
> set standards for future copy and paste code.

I can change that, too.  Thanks for looking!

Anna
> 

