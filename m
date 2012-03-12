Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:36427 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784Ab2CLVyq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 17:54:46 -0400
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <49F11491-C455-4592-804B-B7AFADB00F43@oracle.com>
Date: Mon, 12 Mar 2012 17:54:20 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <EE1AA95B-B16B-4934-B0C3-9A727EA95D73@oracle.com>
References: <878vj7x6mj.fsf@vostro.rath.org> <87pqchn64e.fsf@inspiron.ap.columbia.edu> <20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org> <20120312201505.GC7203@fieldses.org> <87mx7lms1y.fsf@inspiron.ap.columbia.edu> <683A9678-14CF-4F27-8CC9-DD569722EE39@oracle.com> <4F5E6CBF.4080608@rath.org> <49F11491-C455-4592-804B-B7AFADB00F43@oracle.com>
To: Nikolaus Rath <Nikolaus@rath.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 12, 2012, at 5:46 PM, Chuck Lever wrote:

> 
> On Mar 12, 2012, at 5:38 PM, Nikolaus Rath wrote:
> 
>> On 03/12/2012 05:27 PM, Chuck Lever wrote:
>>> 
>>> On Mar 12, 2012, at 5:24 PM, Nikolaus Rath wrote:
>>> 
>>>> Alright, it seems that this was the problem. With correct clientaddr, I
>>>> haven't been able to produce any freezes for the last 15 minutes
>>>> (usually it happens in ~20 seconds).
>>>> 
>>>> The weird thing is that I cannot reproduce the wrong clientaddr
>>>> autodetection when I mount the NFS volumes from the command line. It
>>>> seems to happen only when the mounting is done by mountall during the
>>>> boot sequence.
>>>> 
>>>> In other words, this fstab entry results in freezes and a clientaddr of 0.0.0.0:
>>>> 
>>>> spitzer:/opt /opt        nfs4    bg 0  0
>>>> 
>>>> While this one, followed by a "mount /opt" on the console as soon as I'm
>>>> able to log in, works just fine (and has a correct clientaddr):
>>>> 
>>>> spitzer:/opt /opt        nfs4    noauto 0  0
>>> 
>>> That's almost certainly because networking isn't up during boot.  The "bg" option keeps trying the mount until it succeeds, but the system started the mount process before there was a source address on the system.
>> 
>> Oh, so the clientaddr detection takes place only once at the beginning,
>> and is not repeated if the mount attempts are repeated?
>> 
>> This would explain what's happening. The VPN is not yet up when the
>> system first attempts to mount the share.
>> 
>> Is there a rationale behind this? It seems to me that if the mount is
>> retried, it would be reasonable to expect that the clientaddr detection
>> is retried as well.
> 
> There's no reason I can recall requiring that this is done only once, other than it's the simplest implementation for mount.nfs.  Historically, NFS is deployed on systems with static network configurations that are supposed to be set up before the NFS utilities come into play.  As Bruce suggested, perhaps this design assumption needs to be revisited.
> 
> I suppose I should file a bug.

See https://bugzilla.linux-nfs.org/show_bug.cgi?id=225

Nikolaus, since your clients' network environment is so volatile, you might consider using autofs for these mounts.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




