Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40565 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbcCJQkv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2016 11:40:51 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH v3 05/11] xprtrdma: Do not wait if ib_post_send() fails
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <56E14BA2.2050504@dev.mellanox.co.il>
Date: Thu, 10 Mar 2016 11:40:44 -0500
Cc: Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <54ECE0AF-A930-45E0-A03A-FB7CD789B538@oracle.com>
References: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org> <20160304162801.13590.89343.stgit@oracle120-ib.cthon.org> <56DF1186.3030303@dev.mellanox.co.il> <8696EFBA-B7DB-42AC-AB57-C656070F4ED3@oracle.com> <56E00483.2060304@dev.mellanox.co.il> <6B59B087-9CFA-458B-8848-B08B8E14E2C7@oracle.com> <56E14BA2.2050504@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>, anna.schumaker@netapp.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 10, 2016, at 5:25 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
> 
>>> Moving the QP into error state right after with rdma_disconnect
>>> you are not sure that none of the subset of the invalidations
>>> that _were_ posted completed and you get the corresponding MRs
>>> in a bogus state...
>> 
>> Moving the QP to error state and then draining the CQs means
>> that all LOCAL_INV WRs that managed to get posted will get
>> completed or flushed. That's already handled today.
>> 
>> It's the WRs that didn't get posted that I'm worried about
>> in this patch.
>> 
>> Are there RDMA consumers in the kernel that use that third
>> argument to recover when LOCAL_INV WRs cannot be posted?
> 
> None :)
> 
>>>> I suppose I could reset these MRs instead (that is,
>>>> pass them to ib_dereg_mr).
>>> 
>>> Or, just wait for a completion for those that were posted
>>> and then all the MRs are in a consistent state.
>> 
>> When a LOCAL_INV completes with IB_WC_SUCCESS, the associated
>> MR is in a known state (ie, invalid).
>> 
>> The WRs that flush mean the associated MRs are not in a known
>> state. Sometimes the MR state is different than the hardware
>> state, for example. Trying to do anything with one of these
>> inconsistent MRs results in IB_WC_BIND_MW_ERR until the thing
>> is deregistered.
> 
> Correct.
> 
>> The xprtrdma completion handlers mark the MR associated with
>> a flushed LOCAL_INV WR "stale". They all have to be reset with
>> ib_dereg_mr to guarantee they are usable again. Have a look at
>> __frwr_recovery_worker().
> 
> Yes, I'm aware of that.
> 
>> And, xprtrdma waits for only the last LOCAL_INV in the chain to
>> complete. If that one isn't posted, then fr_done is never woken
>> up. In that case, frwr_op_unmap_sync() would wait forever.
> 
> Ah.. so the (missing) completions is the problem, now I get
> it.
> 
>> If I understand you I think the correct solution is for
>> frwr_op_unmap_sync() to regroup and reset the MRs associated
>> with the LOCAL_INV WRs that were never posted, using the same
>> mechanism as __frwr_recovery_worker() .
> 
> Yea, I'd recycle all the MRs instead of having non-trivial logic
> to try and figure out MR states...

We have to keep that logic, since a spurious disconnect
will result in flushed LOCAL_INV requests too. In fact
that's the by far more likely source of inconsistent MRs.


>> It's already 4.5-rc7, a little late for a significant rework
>> of this patch, so maybe I should drop it?
> 
> Perhaps... Although you can make it incremental because the current
> patch doesn't seem to break anything, just not solving the complete
> problem...

I'm preparing to extend the frwr_queue_recovery mechanism
in v4.7 to deal with other cases, and that new code could
be used here to fence MRs, rather than forcing a disconnect.

I'd like to leave 05/11 in place for v4.6.

Anna, can you add Sagi's Reviewed-by tags to the other
patches in this series, as he posted earlier this week?


--
Chuck Lever



