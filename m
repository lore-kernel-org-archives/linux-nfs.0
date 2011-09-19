Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42484 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340Ab1ISDB2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Sep 2011 23:01:28 -0400
Received: by bkbzt4 with SMTP id zt4so4955627bkb.19
        for <linux-nfs@vger.kernel.org>; Sun, 18 Sep 2011 20:01:27 -0700 (PDT)
Message-ID: <4E76B082.6000500@tonian.com>
Date: Mon, 19 Sep 2011 06:01:22 +0300
From: Benny Halevy <benny@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
References: <1315945452-1575-1-git-send-email-rees@umich.edu> <4E707FC1.2020607@tonian.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B356025@SACMVEXC2-PRD.hq.netapp.com> <20110919020431.GA18269@merit.edu> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B35602C@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B35602C@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-09-19 05:06, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: Jim Rees [mailto:rees@umich.edu]
>> Sent: Sunday, September 18, 2011 10:05 PM
>> To: Myklebust, Trond
>> Cc: Benny Halevy; Peng Tao; linux-nfs@vger.kernel.org; peter honeyman
>> Subject: Re: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
>>
>> Myklebust, Trond wrote:
>>
>>   > -----Original Message-----
>>   > From: Benny Halevy [mailto:bhalevy@tonian.com]
>>   > Sent: Wednesday, September 14, 2011 6:20 AM
>>   > To: Jim Rees; Peng Tao; Myklebust, Trond
>>   > Cc: linux-nfs@vger.kernel.org; peter honeyman
>>   > Subject: Re: [PATCH] pnfsblock: add missing rpc_put_mount and
> path_put
>>   >
>>   > We need to decide on a process here :)
>>   > If we would like to maintain a staging tree in front of Trond's
> then
>>   to simplify
>>   > merging and rebasing, fixes to code that's already upstream, i.e.
> in
>>   linux-2.6
>>   > or already queued in nfs-2.6, that we decide to send to Trond
> ahead of
>>   > queue need to be queued in front of stuff in the staging tree and
> the
>>   latter
>>   > should be rebased on top of them.
>>
>>   Unless we're talking about a large merge, I tend to prefer patches.
> They
>>   are much easier to review...
>>
>> I guess the problem is that we now have a patch in Trond's tree that
> conflicts
>> with the workqueue patch that's staged for later in Benny's tree.
>> I think what I need to do is send Benny a set of patches that starts
> with the
>> same patch I sent Trond, and follows with one that adds the workqueue.
> 
> Yes. That's the other good feature of patches: the onus of fixing up
> conflicts is on you and not on me... :-)
> 

Right. If the required rebase is not trivial I prefer you do it
for many reasons, including familiarity with the change and testing
the end result.  Then, either send the patchset to the list and/or
point me to a branch in your tree for me to get the series from

Benny

> Trond
