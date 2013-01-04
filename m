Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:42404 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755040Ab3ADRLH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 12:11:07 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Tejun Heo <tj@kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Date: Fri, 4 Jan 2013 17:11:04 +0000
Message-ID: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221232609.GC29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221234530.GA30048@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
 <20130103201120.GA2096@fieldses.org> <20130103220814.GB2753@mtj.dyndns.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9119886EE@SACEXCMBX04-PRD.hq.netapp.com>
 <20130103222639.GE2753@mtj.dyndns.org>
 <1357254692.55285.33.camel@lade.trondhjem.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911988B37@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA911988B37@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 3, 2013, at 6:26 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-01-03 at 18:11 -0500, Trond Myklebust wrote:
>> On Thu, 2013-01-03 at 17:26 -0500, Tejun Heo wrote:
>>> Ooh, BTW, there was a bug where workqueue code created a false
>>> dependency between two work items.  Workqueue currently considers two
>>> work items to be the same if they're on the same address and won't
>>> execute them concurrently - ie. it makes a work item which is queued
>>> again while being executed wait for the previous execution to
>>> complete.
>>> 
>>> If a work function frees the work item, and then waits for an event
>>> which should be performed by another work item and *that* work item
>>> recycles the freed work item, it can create a false dependency loop.
>>> There really is no reliable way to detect this short of verifying
>>> every memory free.  A patch is queued to make such occurrences less
>>> likely (work functions should also match for two work items considered
>>> the same), but if you're seeing this, the best thing to do is freeing
>>> the work item at the end of the work function.
>> 
>> That's interesting... I wonder if we may have been hitting that issue.
>> 
>> From what I can see, we do actually free the write RPC task (and hence
>> the work_struct) before we call the asynchronous unlink completion...
>> 
>> Dros, can you see if reverting commit
>> 324d003b0cd82151adbaecefef57b73f7959a469 + commit 
>> 168e4b39d1afb79a7e3ea6c3bb246b4c82c6bdb9 and then applying the attached
>> patch also fixes the hang on a pristine 3.7.x kernel?
> 
> Actually, we probably also need to look at rpc_free_task, so the
> following patch, instead...

Yes, this patch fixes the hang!

Thank you for the explanation Tejun - that makes a lot of sense and explains the workqueue behavior that we were seeing.

-dros