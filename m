Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:37950 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbaGJUah convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 16:30:37 -0400
Received: by mail-vc0-f182.google.com with SMTP id hq11so246287vcb.41
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 13:30:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <F678054E-DF3E-433C-AB86-CFF61A715E49@oracle.com>
References: <1FAA3C78-BBFA-4186-A25A-0D4E97609934@netapp.com>
	<CAHQdGtReiO9yzXG3_WKk9YJJBAmbT+YO+WtuWXabkCtDm76o-Q@mail.gmail.com>
	<69B70372-AC71-46EE-B555-E418124A3348@netapp.com>
	<F678054E-DF3E-433C-AB86-CFF61A715E49@oracle.com>
Date: Thu, 10 Jul 2014 16:30:36 -0400
Message-ID: <CAHQdGtS6ZvfTe87dz1jGYbQqsfnLFeXt9Ed7RnF=r+QhytwJvw@mail.gmail.com>
Subject: Re: rpciod/1: page allocation failure. order:2, mode:0x20'
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 4:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Jul 10, 2014, at 4:17 PM, Adamson, Andy <William.Adamson@netapp.com> wrote:
>
>>
>> On Jul 10, 2014, at 4:08 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>>> On Thu, Jul 10, 2014 at 4:01 PM, Adamson, Andy
>>> <William.Adamson@netapp.com> wrote:
>>>> Hi
>>>>
>>>> A customer of ours, running a 2.6.32-431.5.1.el6.x86_64 kernel NFS client, is hittng the "rpciod/1: page allocation failure. order:2, mode:0x20", but only with NFSv3 hard mounts (not soft mounts), and not with NFSv4 (same application, same client hardware). Has anyone hit this issue with RHEL6.5?  Any ideas on why NFSv3 would trigger this error and not NFSv4?
>>>>
>>>> I see in Red Hat Bugzilla 767127 - swapper: page allocation failure. order:1, mode:0x20 (edit) that a similar issue was solved by setting vm.zone_reclaim_mode = 1 which used to be the default.  Adjusting the vm.min_free_kbytes higher may also help.  Any side effects or issues with these settings?
>>>>
>>>> Any info appreciated
>>>
>>> Where are we doing an order 2 allocation in the NFS/RPC code? Our aim
>>> has always been to do nothing larger than an order 0 allocation.
>>
>> I don’t yet have the Call trace triggered by the allocation failure, but I think it’s in the tcp layer. I’ll confirm.
>
> If the underlying network doesn’t support ->sendpages(), the TCP layer
> would have to allocate a large buffer and copy the RPC payload into
> the buffer.
>
> IPoIB has this issue, for example.
>

That might explain an order 1 allocation, but should not explain an
order 2 on ordinary 1500 MTU ethernet. Are they perhaps trying to use
jumbo frames with this kind of non-scatter-gather compatible hardware?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
