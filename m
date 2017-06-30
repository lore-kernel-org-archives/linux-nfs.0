Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:2227 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752313AbdF3SsB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 14:48:01 -0400
Content-Type: text/plain; charset=us-ascii
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/1] PNFS fix EACCESS on commit to DS handling
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <bbe23013-1a27-e159-2035-c9a2d10bd376@Netapp.com>
Date: Fri, 30 Jun 2017 14:47:47 -0400
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Message-ID: <CDE619E3-1AE4-4727-9E65-FB10A56313F4@netapp.com>
References: <20170623142659.81480-1-kolga@netapp.com>
 <bbe23013-1a27-e159-2035-c9a2d10bd376@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 30, 2017, at 2:43 PM, Anna Schumaker =
<Anna.Schumaker@Netapp.com> wrote:
>=20
> Hi Olga,
>=20
> On 06/23/2017 10:26 AM, Olga Kornievskaia wrote:
>> Commit fabbbee0eb0f "PNFS fix fallback to MDS if got error on
>> commit to DS" moved the pnfs_set_lo_fail() to unhandled errors
>> which was not correct and lead to a kernel oops on umount.
>>=20
>> Instead, fix the original EACCESS on commit to DS error by
>> getting the new layout and re-doing the IO.
>>=20
>> Fixes: fabbbee0eb0f ("PNFS fix fallback to MDS if got error on commit =
to DS")
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> fs/nfs/filelayout/filelayout.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/fs/nfs/filelayout/filelayout.c =
b/fs/nfs/filelayout/filelayout.c
>> index 61dcb4b..8075efe 100644
>> --- a/fs/nfs/filelayout/filelayout.c
>> +++ b/fs/nfs/filelayout/filelayout.c
>> @@ -153,6 +153,7 @@ static int filelayout_async_handle_error(struct =
rpc_task *task,
>> 	case -NFS4ERR_RETRY_UNCACHED_REP:
>> 		break;
>> 	/* Invalidate Layout errors */
>> +	case -NFS4ERR_ACCESS:
>=20
> Should this be -EACCES instead?  The fields right below this are using =
mapped errors based on the nfs_errtbl in nfs4xdr.c, so NFS4ERR_ACCESS =
might not ever get passed to this function.

NFS4ERR_ACCESS and EACCES are numerically the same: 13.

>=20
> Thanks,
> Anna
>=20
>> 	case -NFS4ERR_PNFS_NO_LAYOUT:
>> 	case -ESTALE:           /* mapped NFS4ERR_STALE */
>> 	case -EBADHANDLE:       /* mapped NFS4ERR_BADHANDLE */
>> @@ -183,10 +184,10 @@ static int filelayout_async_handle_error(struct =
rpc_task *task,
>> 			task->tk_status);
>> 		nfs4_mark_deviceid_unavailable(devid);
>> 		pnfs_error_mark_layout_for_return(inode, lseg);
>> +		pnfs_set_lo_fail(lseg);
>> 		rpc_wake_up(&tbl->slot_tbl_waitq);
>> 		/* fall through */
>> 	default:
>> -		pnfs_set_lo_fail(lseg);
>> reset:
>> 		dprintk("%s Retry through MDS. Error %d\n", __func__,
>> 			task->tk_status);
>>=20

