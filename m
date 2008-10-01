From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 10/10] svcrdma: Documentation update for the
  FastReg memory model
Date: Wed, 01 Oct 2008 15:18:58 -0400
Message-ID: <RTPCLUEXC2-PRDVjCRG000000bb@RTPMVEXC1-PRD.hq.netapp.com>
References: <1221564879-85046-8-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-9-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-10-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-11-git-send-email-tom@opengridcomputing.com>
 <20080924212102.GD10841@fieldses.org>
 <48DB939E.4090503@opengridcomputing.com>
 <20080926234006.GA9889@fieldses.org>
 <48E197ED.6080409@opengridcomputing.com>
 <20080930184433.GC12268@fieldses.org>
 <RTPCLUEXC2-PRDgFrYI00000094@RTPMVEXC1-PRD.hq.netapp.com>
 <20081001182654.GA9907@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53771 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573AbYJATTO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Oct 2008 15:19:14 -0400
In-Reply-To: <20081001182654.GA9907@fieldses.org>
References: <1221564879-85046-8-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-9-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-10-git-send-email-tom@opengridcomputing.com>
 <1221564879-85046-11-git-send-email-tom@opengridcomputing.com>
 <20080924212102.GD10841@fieldses.org>
 <48DB939E.4090503@opengridcomputing.com>
 <20080926234006.GA9889@fieldses.org>
 <48E197ED.6080409@opengridcomputing.com>
 <20080930184433.GC12268@fieldses.org>
 <RTPCLUEXC2-PRDgFrYI00000094-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <20081001182654.GA9907@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:26 PM 10/1/2008, J. Bruce Fields wrote:
>On Tue, Sep 30, 2008 at 03:04:26PM -0400, Talpey, Thomas wrote:
>> At 02:44 PM 9/30/2008, J. Bruce Fields wrote:
>> >On Mon, Sep 29, 2008 at 10:07:25PM -0500, Tom Tucker wrote:
>> >> What's your perspective on the lifetime of bounce buffers, memory  
>> >> windows, and the other strategies in client?
>> >
>> >I'm ignorant.  Pointer to something else I should read?
>> >
>> >I assume there are similar issues on the client?
>> 
>> Tom's asking about the client memory registration options and
>> whether they should all remain in the client code going forward.
>> There are different strategies in there, depending on what the
>> hardware supports, how well it supports it, and how you want
>> to run it all.
>
>Do any of them allow reading or writing memory other than that holding
>rpc data?

Some of them, and the memory exposure varies. The only modes which
expose additional memory are FMR's, which expose data on the same
page as RPC data, and ALLPHYSICAL, which, well, exposes everything.

The BOUNCEBUFFERS and REGISTER modes protect memory fiercely,
but are relatively expensive. MEMWINDOWS are safe but not very fast,
and only supported by obsolete devices. FRMR's are both safe and fast
 but a) still have a cost and b) are only supported by one device at present.

Long term, we all hope FRMRs will be the default, logical, and only choice.

I still owe feedback on Tom's new text... it's coming soon.

Tom.
 
>
>--b.
>
>> 
>> The multiple strategies stem from the early days when no two
>> adapters did quite the same thing. That said, at least one of
>> them is no longer useful - no adapters support windows today,
>> since the demise of Ammasso, although the kernel API to drive
>> them is still there in the OFA stack below.
>> 
>> I think it's possible that some of the other modes can collapse, but
>> not just now. There's a lot of older hardware out there, and newer
>> hardware may appear to use the old stuff too. 
>> 
>> Another concern I have, frankly, is interoperability. If we collapse
>> the modes, then the temptation to assume both ends have such-
>> and-such a capability increase. If one side tries some RDMA operation
>> that is only supported properly by a certain adapter, it's hard to detect
>> that in a monoculture. Having the option to switch modes can help avert
>> this, by testing for it.
>> 
>> In any case, if the current code doesn't work, it's a bug. Certainly
>> bouncebuffers (non-RDMA mode) should work perfectly and I plan to
>> check it asap.

