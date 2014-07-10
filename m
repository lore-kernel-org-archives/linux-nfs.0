Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:3014 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224AbaGJURa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 16:17:30 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: rpciod/1: page allocation failure. order:2, mode:0x20'
Date: Thu, 10 Jul 2014 20:17:28 +0000
Message-ID: <69B70372-AC71-46EE-B555-E418124A3348@netapp.com>
References: <1FAA3C78-BBFA-4186-A25A-0D4E97609934@netapp.com>
 <CAHQdGtReiO9yzXG3_WKk9YJJBAmbT+YO+WtuWXabkCtDm76o-Q@mail.gmail.com>
In-Reply-To: <CAHQdGtReiO9yzXG3_WKk9YJJBAmbT+YO+WtuWXabkCtDm76o-Q@mail.gmail.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 10, 2014, at 4:08 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, Jul 10, 2014 at 4:01 PM, Adamson, Andy
> <William.Adamson@netapp.com> wrote:
>> Hi
>> 
>> A customer of ours, running a 2.6.32-431.5.1.el6.x86_64 kernel NFS client, is hittng the "rpciod/1: page allocation failure. order:2, mode:0x20", but only with NFSv3 hard mounts (not soft mounts), and not with NFSv4 (same application, same client hardware). Has anyone hit this issue with RHEL6.5?  Any ideas on why NFSv3 would trigger this error and not NFSv4?
>> 
>> I see in Red Hat Bugzilla 767127 - swapper: page allocation failure. order:1, mode:0x20 (edit) that a similar issue was solved by setting vm.zone_reclaim_mode = 1 which used to be the default.  Adjusting the vm.min_free_kbytes higher may also help.  Any side effects or issues with these settings?
>> 
>> Any info appreciated
> 
> Where are we doing an order 2 allocation in the NFS/RPC code? Our aim
> has always been to do nothing larger than an order 0 allocation.

I don’t yet have the Call trace triggered by the allocation failure, but I think it’s in the tcp layer. I’ll confirm.

—>Andy

> 
> -- 
> Trond Myklebust
> 
> Linux NFS client maintainer, PrimaryData
> 
> trond.myklebust@primarydata.com

