Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41968 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014Ab1JaObm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 10:31:42 -0400
Received: by vcge1 with SMTP id e1so4805639vcg.19
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2011 07:31:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7515@SACMVEXC2-PRD.hq.netapp.com>
References: <1319426747-2179-1-git-send-email-bergwolf@gmail.com>
 <4EAE9B60.9040903@tonian.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7515@SACMVEXC2-PRD.hq.netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Mon, 31 Oct 2011 22:31:20 +0800
Message-ID: <CA+a=Yy5MzunUci462WBJ1JmVbJ70Oo95YzmnvU6qz01E-yM0tA@mail.gmail.com>
Subject: Re: [PATCH-RFC] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Trond,

On Mon, Oct 31, 2011 at 9:54 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>
>
>> -----Original Message-----
>> From: Benny Halevy [mailto:bhalevy@tonian.com]
>> Sent: Monday, October 31, 2011 8:58 AM
>> To: Peng Tao
>> Cc: linux-nfs@vger.kernel.org; Myklebust, Trond; Peng Tao
>> Subject: Re: [PATCH-RFC] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
>>
>> On 2011-10-24 05:25, Peng Tao wrote:
>> > Hi, Trond and Benny,
>> >
>> > The patch depends on the pnfs private workqueue for now. So I want
> to
>> > consult you about where to put the work. Is pnfs private workqueue
>> > dropped? If yes, where should I put this kind of work?
>>
>> I'll defer this to Trond.
>> I'm OK with having a workqueue for pnfs.
>
> I've already commented on this: I see no justification whatsoever for a
> private pnfs workqueue.
OK. Thanks a lot for confirming it. I think I can just change this one
to use the system wq. Will send an updated patch.


-- 
Thanks,
Tao
