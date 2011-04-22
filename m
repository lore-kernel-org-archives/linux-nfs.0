Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6743 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369Ab1DVI1D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:27:03 -0400
Message-ID: <4DB13BD3.2000102@panasas.com>
Date: Fri, 22 Apr 2011 11:26:59 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [RFC 06/27] pnfs: encode_layoutreturn
References: <4DAF0DE1.6020609@panasas.com>	 <1303320418-21181-1-git-send-email-bhalevy@panasas.com> <1303330562.23206.36.camel@lade.trondhjem.org>
In-Reply-To: <1303330562.23206.36.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-20 23:16, Trond Myklebust wrote:
> On Wed, 2011-04-20 at 20:26 +0300, Benny Halevy wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> [fixup layout header pointer for encode_layoutreturn]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4xdr.c |    9 +++++++--
>>  fs/nfs/pnfs.h    |    4 ++++
>>  2 files changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 53ea3e5..6b64dd8 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -1927,8 +1927,13 @@ encode_layoutreturn(struct xdr_stream *xdr,
>>  		spin_unlock(&args->inode->i_lock);
>>  		p = xdr_encode_opaque_fixed(p, &stateid.data,
>>  					    NFS4_STATEID_SIZE);
>> -		p = reserve_space(xdr, 4);
>> -		*p = cpu_to_be32(0);
>> +		if (NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn) {
>> +			NFS_SERVER(args->inode)->pnfs_curr_ld->encode_layoutreturn(
>> +				NFS_I(args->inode)->layout, xdr, args);
>> +		} else {
>> +			p = reserve_space(xdr, 4);
>> +			*p = cpu_to_be32(0);
>> +		}
>>  	}
>>  	hdr->nops++;
>>  	hdr->replen += decode_layoutreturn_maxsz;
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index c315109..51dcbc1 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -98,6 +98,10 @@ struct pnfs_layoutdriver_type {
>>  
>>  	/* device notification methods */
>>  	void (*delete_deviceid)(struct nfs4_deviceid *);
>> +
>> +	void (*encode_layoutreturn) (struct pnfs_layout_hdr *layoutid,
>> +				     struct xdr_stream *xdr,
>> +				     const struct nfs4_layoutreturn_args *args);
> 
> Ugh, no... The only user of this is the OSD layout type, and it just
> uses it to pass error information. Why can't we just add that particular
> case to the layoutreturn XDR.
> 

We can do that and add the vector with the blocks layout driver
though in my opinion using the vector, even for the single use
case, is cleaner than special casing the xdr code for the obj layout...

Benny

>>  };
>>  
>>  struct pnfs_layout_hdr {
> 

