Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61314 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752033Ab0INNNR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 09:13:17 -0400
Message-ID: <4C8F74ED.5050701@panasas.com>
Date: Tue, 14 Sep 2010 15:13:17 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] pnfs: allow nfs4_proc_layoutget to sleep on invalid
 lsegs
References: <4C8F53FA.5060308@panasas.com>	<1284461616-4588-1-git-send-email-bhalevy@panasas.com>	<AANLkTimFyGbg_bfu1MwjarhRC63Osg8Depwn8E0dfimL@mail.gmail.com>	<4C8F6D23.5060204@panasas.com> <AANLkTi=cQiuDZ95p4hBX56FH1t1FnJnG5N0Dqvig8x0y@mail.gmail.com>
In-Reply-To: <AANLkTi=cQiuDZ95p4hBX56FH1t1FnJnG5N0Dqvig8x0y@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-14 14:47, Fred Isaman wrote:
> On Tue, Sep 14, 2010 at 5:40 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On 2010-09-14 14:00, Fred Isaman wrote:
>>> Note that this waits on any range that overlaps both an outstanding
>>> LAYOUTRETURN and a current layout.  Whereas what you really want is to
>>> wait on any range that overlaps an outstanding LAYOUTRETURN.  One way
>>> to get the desired behavior would be to have LAYOUTRETURN insert an
>>> "invalid" lseg covering its range.
>>
>> What do you mean by "current layout"?
> 
> Consider the case where the server asks for a LAYOUTRETURN of the
> range 0-1000, but the client currently only has lsegs covering 0-500.
> The client should wait for the LAYOUTRETURN to complete before sending
> any LAYOUTGET for the range 500-1000, but there is currently no
> mechanism to do this.
> 

Yes, this could be yet another optimization to avoid
getting NFS4ERR_RECALLCONFLICT.

Benny

> Fred
> 
>> The way it works now is that layout return does mark the layout segments
>> it's about to return as invalid (in pnfs_return_layout_barrier).
>> layout get inserts a valid layout segment only upon completion
>> (in pnfs_layout_process) and it does not yet insert an invalid one
>> before sending the RPC, something we may wan to consider in the future
>> to prevent superfluous parallel gets.
>>
>> Benny
>>
>>>
>>> Fred
>>>
>>>
>>> On Tue, Sep 14, 2010 at 3:53 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>> Introduce lo_rpcwaitq and sleep on it while there's an lseg marked invalid,
>>>> i.e. it is being returned (in the future, it could also be layoutget in progress).
>>>>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> ---
>>>>  fs/nfs/inode.c         |    1 +
>>>>  fs/nfs/nfs4proc.c      |   25 ++++++++++++++++++++++---
>>>>  fs/nfs/pnfs.c          |   37 ++++++++++++++++++-------------------
>>>>  fs/nfs/pnfs.h          |    3 +++
>>>>  include/linux/nfs_fs.h |    1 +
>>>>  5 files changed, 45 insertions(+), 22 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>>> index 7621cfc..059bdf7 100644
>>>> --- a/fs/nfs/inode.c
>>>> +++ b/fs/nfs/inode.c
>>>> @@ -1462,6 +1462,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
>>>>        init_rwsem(&nfsi->rwsem);
>>>>  #ifdef CONFIG_NFS_V4_1
>>>>        init_waitqueue_head(&nfsi->lo_waitq);
>>>> +       rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layout");
>>>>        nfsi->pnfs_layout_suspend = 0;
>>>>        nfsi->layout = NULL;
>>>>  #endif /* CONFIG_NFS_V4_1 */
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index 48a763e..f12568d 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -5442,13 +5442,32 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
>>>>  {
>>>>        struct nfs4_layoutget *lgp = calldata;
>>>>        struct inode *ino = lgp->args.inode;
>>>> +       struct nfs_inode *nfsi = NFS_I(ino);
>>>>        struct nfs_server *server = NFS_SERVER(ino);
>>>> +       struct pnfs_layout_segment *lseg;
>>>>
>>>>        dprintk("--> %s\n", __func__);
>>>> -       if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
>>>> -                               &lgp->res.seq_res, 0, task))
>>>> +       spin_lock(&ino->i_lock);
>>>> +       lseg = pnfs_has_layout(nfsi->layout, &lgp->args.range);
>>>> +       if (likely(!lseg)) {
>>>> +               spin_unlock(&ino->i_lock);
>>>> +               dprintk("%s: no lseg found, proceeding\n", __func__);
>>>> +               if (!nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
>>>> +                                        &lgp->res.seq_res, 0, task))
>>>> +                       rpc_call_start(task);
>>>>                return;
>>>> -       rpc_call_start(task);
>>>> +       }
>>>> +       if (!lseg->valid) {
>>>> +               put_lseg_locked(lseg);
>>>> +               spin_unlock(&ino->i_lock);
>>>> +               dprintk("%s: invalid lseg found, waiting\n", __func__);
>>>> +               rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
>>>> +               return;
>>>> +       }
>>>> +       *lgp->lsegpp = lseg;
>>>> +       spin_unlock(&ino->i_lock);
>>>> +       dprintk("%s: valid lseg found, no rpc required\n", __func__);
>>>> +       rpc_exit(task, NFS4_OK);
>>>>  }
>>>>
>>>>  static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>> index bc4f0c1..2450383 100644
>>>> --- a/fs/nfs/pnfs.c
>>>> +++ b/fs/nfs/pnfs.c
>>>> @@ -430,7 +430,7 @@ destroy_lseg(struct kref *kref)
>>>>        PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
>>>>  }
>>>>
>>>> -static void
>>>> +void
>>>>  put_lseg_locked(struct pnfs_layout_segment *lseg)
>>>>  {
>>>>        bool do_wake_up;
>>>> @@ -444,8 +444,10 @@ put_lseg_locked(struct pnfs_layout_segment *lseg)
>>>>        do_wake_up = !lseg->valid;
>>>>        nfsi = PNFS_NFS_INODE(lseg->layout);
>>>>        kref_put(&lseg->kref, destroy_lseg);
>>>> -       if (do_wake_up)
>>>> +       if (do_wake_up) {
>>>>                wake_up(&nfsi->lo_waitq);
>>>> +               rpc_wake_up(&nfsi->lo_rpcwaitq);
>>>> +       }
>>>>  }
>>>>
>>>>  void
>>>> @@ -999,7 +1001,7 @@ has_matching_lseg(struct pnfs_layout_segment *lseg,
>>>>  /*
>>>>  * lookup range in layout
>>>>  */
>>>> -static struct pnfs_layout_segment *
>>>> +struct pnfs_layout_segment *
>>>>  pnfs_has_layout(struct pnfs_layout_hdr *lo,
>>>>                struct pnfs_layout_range *range)
>>>>  {
>>>> @@ -1057,22 +1059,20 @@ _pnfs_update_layout(struct inode *ino,
>>>>
>>>>        /* Check to see if the layout for the given range already exists */
>>>>        lseg = pnfs_has_layout(lo, &arg);
>>>> -       if (lseg && !lseg->valid) {
>>>> -               put_lseg_locked(lseg);
>>>> -               /* someone is cleaning the layout */
>>>> -               lseg = NULL;
>>>> -               goto out_unlock;
>>>> -       }
>>>> -
>>>>        if (lseg) {
>>>> -               dprintk("%s: Using cached lseg %p for %llu@%llu iomode %d)\n",
>>>> -                       __func__,
>>>> -                       lseg,
>>>> -                       arg.length,
>>>> -                       arg.offset,
>>>> -                       arg.iomode);
>>>> +               if (lseg->valid) {
>>>> +                       dprintk("%s: Using cached lseg %p for %llu@%llu "
>>>> +                               "iomode %d)\n",
>>>> +                               __func__,
>>>> +                               lseg,
>>>> +                               arg.length,
>>>> +                               arg.offset,
>>>> +                               arg.iomode);
>>>>
>>>> -               goto out_unlock;
>>>> +                       goto out_unlock;
>>>> +               }
>>>> +               /* someone is cleaning the layout */
>>>> +               put_lseg_locked(lseg);
>>>>        }
>>>>
>>>>        /* if get layout already failed once goto out */
>>>> @@ -1097,8 +1097,7 @@ out:
>>>>                nfsi->layout->state, lseg);
>>>>        return;
>>>>  out_unlock:
>>>> -       if (lsegpp)
>>>> -               *lsegpp = lseg;
>>>> +       *lsegpp = lseg;
>>>>        spin_unlock(&ino->i_lock);
>>>>        goto out;
>>>>  }
>>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>>> index ea70385..f7f567e 100644
>>>> --- a/fs/nfs/pnfs.h
>>>> +++ b/fs/nfs/pnfs.h
>>>> @@ -34,6 +34,9 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
>>>>  /* pnfs.c */
>>>>  extern const nfs4_stateid zero_stateid;
>>>>
>>>> +void put_lseg_locked(struct pnfs_layout_segment *);
>>>> +struct pnfs_layout_segment *pnfs_has_layout(struct pnfs_layout_hdr *,
>>>> +                                           struct pnfs_layout_range *);
>>>>  void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>>>>        loff_t pos, u64 count, enum pnfs_iomode access_type,
>>>>        struct pnfs_layout_segment **lsegpp);
>>>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>>>> index 5bafa95..196c0c6 100644
>>>> --- a/include/linux/nfs_fs.h
>>>> +++ b/include/linux/nfs_fs.h
>>>> @@ -213,6 +213,7 @@ struct nfs_inode {
>>>>        /* pNFS layout information */
>>>>  #if defined(CONFIG_NFS_V4_1)
>>>>        wait_queue_head_t lo_waitq;
>>>> +       struct rpc_wait_queue lo_rpcwaitq;
>>>>        struct pnfs_layout_hdr *layout;
>>>>        time_t pnfs_layout_suspend;
>>>>  #endif /* CONFIG_NFS_V4_1 */
>>>> --
>>>> 1.7.2.2
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>
