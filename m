Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:40799 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751072AbdF3S5F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 14:57:05 -0400
Subject: Re: [PATCH 1/1] PNFS fix EACCESS on commit to DS handling
To: Olga Kornievskaia <kolga@netapp.com>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
References: <20170623142659.81480-1-kolga@netapp.com>
 <bbe23013-1a27-e159-2035-c9a2d10bd376@Netapp.com>
 <CDE619E3-1AE4-4727-9E65-FB10A56313F4@netapp.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <10fede79-fa5e-7a90-4056-873b1329efa4@Netapp.com>
Date: Fri, 30 Jun 2017 14:56:57 -0400
MIME-Version: 1.0
In-Reply-To: <CDE619E3-1AE4-4727-9E65-FB10A56313F4@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/30/2017 02:47 PM, Olga Kornievskaia wrote:
> 
>> On Jun 30, 2017, at 2:43 PM, Anna Schumaker <Anna.Schumaker@Netapp.com> wrote:
>>
>> Hi Olga,
>>
>> On 06/23/2017 10:26 AM, Olga Kornievskaia wrote:
>>> Commit fabbbee0eb0f "PNFS fix fallback to MDS if got error on
>>> commit to DS" moved the pnfs_set_lo_fail() to unhandled errors
>>> which was not correct and lead to a kernel oops on umount.
>>>
>>> Instead, fix the original EACCESS on commit to DS error by
>>> getting the new layout and re-doing the IO.
>>>
>>> Fixes: fabbbee0eb0f ("PNFS fix fallback to MDS if got error on commit to DS")
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>> fs/nfs/filelayout/filelayout.c | 3 ++-
>>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
>>> index 61dcb4b..8075efe 100644
>>> --- a/fs/nfs/filelayout/filelayout.c
>>> +++ b/fs/nfs/filelayout/filelayout.c
>>> @@ -153,6 +153,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>>> 	case -NFS4ERR_RETRY_UNCACHED_REP:
>>> 		break;
>>> 	/* Invalidate Layout errors */
>>> +	case -NFS4ERR_ACCESS:
>>
>> Should this be -EACCES instead?  The fields right below this are using mapped errors based on the nfs_errtbl in nfs4xdr.c, so NFS4ERR_ACCESS might not ever get passed to this function.
> 
> NFS4ERR_ACCESS and EACCES are numerically the same: 13.

You're right, and I should have double checked that.  Thanks for pointing that out to me!

Anna

> 
>>
>> Thanks,
>> Anna
>>
>>> 	case -NFS4ERR_PNFS_NO_LAYOUT:
>>> 	case -ESTALE:           /* mapped NFS4ERR_STALE */
>>> 	case -EBADHANDLE:       /* mapped NFS4ERR_BADHANDLE */
>>> @@ -183,10 +184,10 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>>> 			task->tk_status);
>>> 		nfs4_mark_deviceid_unavailable(devid);
>>> 		pnfs_error_mark_layout_for_return(inode, lseg);
>>> +		pnfs_set_lo_fail(lseg);
>>> 		rpc_wake_up(&tbl->slot_tbl_waitq);
>>> 		/* fall through */
>>> 	default:
>>> -		pnfs_set_lo_fail(lseg);
>>> reset:
>>> 		dprintk("%s Retry through MDS. Error %d\n", __func__,
>>> 			task->tk_status);
>>>
> 
