Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23686 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbcCJPfP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2016 10:35:15 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH v3 05/11] xprtrdma: Do not wait if ib_post_send() fails
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <7b2101d17ae1$f88597b0$e990c710$@opengridcomputing.com>
Date: Thu, 10 Mar 2016 10:35:06 -0500
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>, anna.schumaker@netapp.com,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BB3E1E71-E3B0-48D2-BADE-120152BE42D3@oracle.com>
References: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org> <20160304162801.13590.89343.stgit@oracle120-ib.cthon.org> <56DF1186.3030303@dev.mellanox.co.il> <8696EFBA-B7DB-42AC-AB57-C656070F4ED3@oracle.com> <56E00483.2060304@dev.mellanox.co.il> <6B59B087-9CFA-458B-8848-B08B8E14E2C7@oracle.com> <56E14BA2.2050504@dev.mellanox.co.il> <7abb01d17ade$1faf0ff0$5f0d2fd0$@opengridcomputing.com> <AC62FAB3-5569-4FA3-93AF-35CD2A1869EF@oracle.com> <7b2101d17ae1$f88597b0$e990c710$@opengridcomputing.com>
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 10, 2016, at 10:31 AM, Steve Wise <swise@opengridcomputing.com> wrote:
> 
>>> On Mar 10, 2016, at 10:04 AM, Steve Wise <swise@opengridcomputing.com>
>> wrote:
>>> 
>>>>>> Moving the QP into error state right after with rdma_disconnect
>>>>>> you are not sure that none of the subset of the invalidations
>>>>>> that _were_ posted completed and you get the corresponding MRs
>>>>>> in a bogus state...
>>>>> 
>>>>> Moving the QP to error state and then draining the CQs means
>>>>> that all LOCAL_INV WRs that managed to get posted will get
>>>>> completed or flushed. That's already handled today.
>>>>> 
>>>>> It's the WRs that didn't get posted that I'm worried about
>>>>> in this patch.
>>>>> 
>>>>> Are there RDMA consumers in the kernel that use that third
>>>>> argument to recover when LOCAL_INV WRs cannot be posted?
>>>> 
>>>> None :)
>>>> 
>>>>>>> I suppose I could reset these MRs instead (that is,
>>>>>>> pass them to ib_dereg_mr).
>>>>>> 
>>>>>> Or, just wait for a completion for those that were posted
>>>>>> and then all the MRs are in a consistent state.
>>>>> 
>>>>> When a LOCAL_INV completes with IB_WC_SUCCESS, the associated
>>>>> MR is in a known state (ie, invalid).
>>>>> 
>>>>> The WRs that flush mean the associated MRs are not in a known
>>>>> state. Sometimes the MR state is different than the hardware
>>>>> state, for example. Trying to do anything with one of these
>>>>> inconsistent MRs results in IB_WC_BIND_MW_ERR until the thing
>>>>> is deregistered.
>>>> 
>>>> Correct.
>>>> 
>>> 
>>> It is legal to invalidate an MR that is not in the valid state.  So you
> don't
>>> have to deregister it, you can assume it is valid and post another LINV WR.
>> 
>> I've tried that. Once the MR is inconsistent, even LOCAL_INV
>> does not work.
>> 
> 
> Maybe IB Verbs don't mandate that invalidating an invalid MR must be allowed?
> (looking at the verbs spec now).

If the MR is truly invalid, then there is no issue, and
the second LOCAL_INV completes successfully.

The problem is after a flushed LOCAL_INV, the MR state
sometimes does not match the hardware state. The MR is
neither registered or invalid.

A flushed LOCAL_INV tells you nothing more than that the
LOCAL_INV didn't complete. The MR state at that point is
unknown.


--
Chuck Lever



