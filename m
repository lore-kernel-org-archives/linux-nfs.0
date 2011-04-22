Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7213 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab1DVJGD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 05:06:03 -0400
Message-ID: <4DB144F6.4060302@panasas.com>
Date: Fri, 22 Apr 2011 12:05:58 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [RFC 11/27] pnfs: per mount layout driver private data
References: <4DAF0DE1.6020609@panasas.com>	 <1303320461-21369-1-git-send-email-bhalevy@panasas.com> <1303331772.23206.47.camel@lade.trondhjem.org>
In-Reply-To: <1303331772.23206.47.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-20 23:36, Trond Myklebust wrote:
> On Wed, 2011-04-20 at 20:27 +0300, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  include/linux/nfs_fs_sb.h |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index 216cea5..c5b3fd0 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -142,6 +142,9 @@ struct nfs_server {
>>  						   filesystem */
>>  	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
>>  	struct rpc_wait_queue	roc_rpcwaitq;
>> +	void			       *pnfs_ld_data; /* Per-mount data */
>> +	unsigned int			ds_rsize;  /* Data server read size */
>> +	unsigned int			ds_wsize;  /* Data server write size */
> 
> Shouldn't the rsize and wsize be part of the layout driver private data?
> 

Oops, they're not used anymore (they were previously
used by the files layout). I'll just get rid of them.

Benny

>>  
>>  	/* the following fields are protected by nfs_client->cl_lock */
>>  	struct rb_root		state_owners;
> 

