Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f180.google.com ([74.125.82.180]:41810 "EHLO
	mail-wy0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab1IUHE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 03:04:58 -0400
Received: by wyj26 with SMTP id 26so2091846wyj.11
        for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 00:04:57 -0700 (PDT)
Message-ID: <4E798C93.40409@tonian.com>
Date: Wed, 21 Sep 2011 10:04:51 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: tao.peng@emc.com
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        honey@citi.umich.edu, rees@umich.edu
Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
References: <1316488728-24912-1-git-send-email-rees@umich.edu> <1316488728-24912-3-git-send-email-rees@umich.edu> <1316558461.15093.4.camel@lade.trondhjem.org> <20110921002917.GA30770@merit.edu> <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480226@SACMVEXC2-PRD.hq.netapp.com> <F19688880B763E40B28B2B462677FBF805C495295A@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C495295A@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-09-21 08:16, tao.peng@emc.com wrote:
>> -----Original Message-----
>> From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com]
>> Sent: Wednesday, September 21, 2011 12:20 PM
>> To: Peng, Tao
>> Cc: bhalevy@tonian.com; linux-nfs@vger.kernel.org; honey@citi.umich.edu;
>> rees@umich.edu
>> Subject: RE: [PATCH 2/3] pnfs: introduce pnfs private workqueue
>>
>>> -----Original Message-----
>>> From: tao.peng@emc.com [mailto:tao.peng@emc.com]
>>> Sent: Tuesday, September 20, 2011 10:44 PM
>>> To: Myklebust, Trond
>>> Cc: bhalevy@tonian.com; linux-nfs@vger.kernel.org;
>> honey@citi.umich.edu;
>>> rees@umich.edu
>>> Subject: RE: [PATCH 2/3] pnfs: introduce pnfs private workqueue
>>>
>>>
>>>> -----Original Message-----
>>>> From: linux-nfs-owner@vger.kernel.org
>>>> [mailto:linux-nfs-owner@vger.kernel.org]
>>>> On Behalf Of Jim Rees
>>>> Sent: Wednesday, September 21, 2011 8:29 AM
>>>> To: Trond Myklebust
>>>> Cc: Benny Halevy; linux-nfs@vger.kernel.org; peter honeyman
>>>> Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
>>>>
>>>> Trond Myklebust wrote:
>>>>
>>>>   On Mon, 2011-09-19 at 23:18 -0400, Jim Rees wrote:
>>>>   > From: Peng Tao <bergwolf@gmail.com>
>>>>   >
>>>>   > For layoutdriver io done functions, default workqueue is not a
>> good
>>> place as
>>>>   > the code is executed in IO path. So add a pnfs private workqueue
>> to
>>> handle
>>>>   > them.
>>>>   >
>>>>   > Also change block and object layout code to make use of this
>> private
>>>>   > workqueue.
>>>>   >
>>>>
>>>>   Wait, what????
>>>>
>>>>   Why is the I/O path (i.e. the nfsiod queue) inappropriate for
>>>>   layoutdriver io_done functions?
>>> The current code uses the system_wq to handle io_done functions. If
>> any
>>> function allocates memory in system_wq and causes dirty writeback in
>> nfs
>>> path, the io_done function can never be called because it is after the
>> original
>>> function in the system_wq. And you said that the rpciod/nfsiod is not
>> the
>>> ideal place because of memory allocation. So I suggested pnfs private
>>> workqueue and Benny agreed on it.
>>
>> You appear to be optimizing for a corner case. Why?
> Current code uses system_wq for io_done and it can cause deadlock. So this is more than just an optimization.
> 
>>
>> IOW: why do we need a whole new workqueue for something which is
>> supposed to be extremely rare? Why can't we just use standard keventd or
>> allocate a perfectly normal thread (e.g. the state recovery thread)?
> Unlike nfsiod and rpciod, keventd (aka, system_wq) is not created with WQ_MEM_RECLAIM, indicating that it should not be used for IO path which can be invoked during memory reclaim. And I agree that a normal kthread can solve it.
> 
> However, the blocklayout write end_io function still needs a context where it can allocate memory to convert extent state (for every IO that touches new extents). If you look into the patch, we are not just using the pnfs private workqueue to handle pnfs_ld_read/write_done, but also calling mark_extents_written() inside the workqueue.

Can this memory be preallocated before the I/O for the common case?

Benny

> If we don't create a pnfs private workqueue for pnfs_ld_read/write_done (i.e., by just creating a normal kthread in error case), we would still have to create a workqueue inside blocklayout driver to handle write end_io. And if blocklayout has a private workqueue, it no longer needs the normal kthread for read/write_done error handling, which leaves the kthread only specific to object layout (if it doesn't need a workqueue like blocklayout does).
> 
> So I think a generic pnfs workqueue is better because it simplifies things and solve both problems.
> 
> Best,
> Tao
> 
>>
>> Trond
> 
