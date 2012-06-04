Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53763 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169Ab2FDNtW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2012 09:49:22 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFSv4.1 fence all layouts with file layout data
 server connection errors
Date: Mon, 4 Jun 2012 13:49:05 +0000
Message-ID: <2D678724-1ED3-433F-AE4D-BCBC93D01783@netapp.com>
References: <1338571178-2096-1-git-send-email-andros@netapp.com>
 <1338571178-2096-3-git-send-email-andros@netapp.com>
 <4FCA94A6.3070105@panasas.com>
In-Reply-To: <4FCA94A6.3070105@panasas.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2012, at 6:33 PM, Boaz Harrosh wrote:

> On 06/01/2012 08:19 PM, andros@netapp.com wrote:
> 
>> From: Andy Adamson <andros@netapp.com>
>> 
> 
> 
> The tittle does not match at all the message text nor the patch.
> 
> More like: Don't send LAYOUTCOMMIT if data is rewritten through MDS 

Well, the meat of this patch is the LAYOUTRETURN for fencing.

-->Andy

> 
> I think.
> Boaz
> 
>> Clear the inode LAYOUTCOMMIT flag as we will resend writes through the MDS.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/nfs4filelayout.c |    4 ++--
>> 1 files changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index e134029..96a75d1 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -205,8 +205,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>> 	case -EPIPE:
>> 		dprintk("%s DS connection error %d\n", __func__,
>> 			task->tk_status);
>> -		if (!filelayout_test_devid_invalid(devid))
>> -			_pnfs_return_layout(inode);
>> +		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
>> +		_pnfs_return_layout(inode);
>> 		filelayout_mark_devid_invalid(devid);
>> 		rpc_wake_up(&tbl->slot_tbl_waitq);
>> 		nfs4_ds_disconnect(clp);
> 
> 

