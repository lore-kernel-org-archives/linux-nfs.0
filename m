Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:24528 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbaGJUT1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 16:19:27 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: rpciod/1: page allocation failure. order:2, mode:0x20'
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <69B70372-AC71-46EE-B555-E418124A3348@netapp.com>
Date: Thu, 10 Jul 2014 16:19:21 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F678054E-DF3E-433C-AB86-CFF61A715E49@oracle.com>
References: <1FAA3C78-BBFA-4186-A25A-0D4E97609934@netapp.com> <CAHQdGtReiO9yzXG3_WKk9YJJBAmbT+YO+WtuWXabkCtDm76o-Q@mail.gmail.com> <69B70372-AC71-46EE-B555-E418124A3348@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 10, 2014, at 4:17 PM, Adamson, Andy <William.Adamson@netapp.com> wrote:

> 
> On Jul 10, 2014, at 4:08 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> On Thu, Jul 10, 2014 at 4:01 PM, Adamson, Andy
>> <William.Adamson@netapp.com> wrote:
>>> Hi
>>> 
>>> A customer of ours, running a 2.6.32-431.5.1.el6.x86_64 kernel NFS client, is hittng the "rpciod/1: page allocation failure. order:2, mode:0x20", but only with NFSv3 hard mounts (not soft mounts), and not with NFSv4 (same application, same client hardware). Has anyone hit this issue with RHEL6.5?  Any ideas on why NFSv3 would trigger this error and not NFSv4?
>>> 
>>> I see in Red Hat Bugzilla 767127 - swapper: page allocation failure. order:1, mode:0x20 (edit) that a similar issue was solved by setting vm.zone_reclaim_mode = 1 which used to be the default.  Adjusting the vm.min_free_kbytes higher may also help.  Any side effects or issues with these settings?
>>> 
>>> Any info appreciated
>> 
>> Where are we doing an order 2 allocation in the NFS/RPC code? Our aim
>> has always been to do nothing larger than an order 0 allocation.
> 
> I don’t yet have the Call trace triggered by the allocation failure, but I think it’s in the tcp layer. I’ll confirm.

If the underlying network doesn’t support ->sendpages(), the TCP layer
would have to allocate a large buffer and copy the RPC payload into
the buffer.

IPoIB has this issue, for example.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



