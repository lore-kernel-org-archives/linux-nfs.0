Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24429 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754676Ab0IMLG4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 07:06:56 -0400
Message-ID: <4C8E05CD.7090407@panasas.com>
Date: Mon, 13 Sep 2010 13:06:53 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>	 <1283450419-5648-8-git-send-email-iisaman@netapp.com> <1284146604.10062.68.camel@heimdal.trondhjem.org>
In-Reply-To: <1284146604.10062.68.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/10/2010 10:23 PM, Trond Myklebust wrote:
> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>>  
>>  /* Unitialize a mountpoint in a layout driver */
>>  void
>>  unset_pnfs_layoutdriver(struct nfs_server *nfss)
>>  {
>> +	if (nfss->pnfs_curr_ld)
>> +		nfss->pnfs_curr_ld->ld_io_ops->uninitialize_mountpoint(nfss->nfs_client);
> 
> That 'uninitialize_mountpoint' name doesn't make any sense. The
> nfs_client parameter isn't associated to a particular mountpoint.
> 

Me two BTW.
I will later need a per super-block resources, mainly slabs and work_q.
The above is used for two things: 
one - Per-client but after the layout-type is known which comes after first
      mount. (For the device cache)
Two - Per server (per mount) which will be used by objects later on.
      (I think that there is an if somewhere that make this call only
       once per client, right?)

I think we should just pass nfss to the LD and let it take care of accessing
nfss->nfs_client for the device cache. (It is done so later in the tree, right?)

Boaz
>>  	nfss->pnfs_curr_ld = NULL;
>>  }
>>  
>> @@ -68,6 +100,12 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
>>  			goto out_no_driver;
>>  		}
>>  	}
>> +	if (ld_type->ld_io_ops->initialize_mountpoint(server->nfs_client)) {
> 
> Ditto.
> 
