Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:51065 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847Ab1G0Ums (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:42:48 -0400
Message-ID: <4E307839.4020609@panasas.com>
Date: Wed, 27 Jul 2011 13:42:33 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Jim Rees <rees@umich.edu>, <linux-nfs@vger.kernel.org>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v3 06/25] pnfs: cleanup_layoutcommit
References: <1311792048-12551-1-git-send-email-rees@umich.edu>		 <1311792048-12551-7-git-send-email-rees@umich.edu>	 <1311796389.25645.20.camel@lade.trondhjem.org>	 <4E3072F3.7090802@panasas.com> <1311798322.25645.35.camel@lade.trondhjem.org>
In-Reply-To: <1311798322.25645.35.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/2011 01:25 PM, Trond Myklebust wrote:
> On Wed, 2011-07-27 at 13:20 -0700, Boaz Harrosh wrote: 
>> On 07/27/2011 12:53 PM, Trond Myklebust wrote:
>>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>>> index bddd8b9..f271425 100644
>>>> --- a/fs/nfs/pnfs.h
>>>> +++ b/fs/nfs/pnfs.h
>>>> @@ -113,6 +113,9 @@ struct pnfs_layoutdriver_type {
>>>>  				     struct xdr_stream *xdr,
>>>>  				     const struct nfs4_layoutreturn_args *args);
>>>>  
>>>> +	void (*cleanup_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>>>> +				      struct nfs4_layoutcommit_data *data);
>>>> +
>>>>  	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>>>>  				     struct xdr_stream *xdr,
>>>>  				     const struct nfs4_layoutcommit_args *args);
>>>
>>> This really needs to go. We should have
>>>
>>>       int (*layoutcommit)()...
>>>
>>> instead of 'encode' and 'cleanup' methods...
>>>
>>
>> Theoretically it is not possible because the blocks-layout protocol mandates
>> different handling depending on the "error" response from the Server which
>> will be received on RPC done.
> 
> ???? If the blocks code is in charge of actually doing the RPC call, why
> would it not be able to perform its own error handling?
> 

Is it? I thought it was the Generic layer that was Initiating the layoutcommit
(From the pnfs_layoutcommit_inode called from nfs_write_inode)

The LD only has a chance to encode the payload on rpc-setup and here the blocks
code needs cleanup depending on the return-status of rpc-done

[I do think that setup and done might be better names to reflect the rpc states)

Thanks
Boaz
