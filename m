Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:50409 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751510Ab2CLViJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 17:38:09 -0400
Message-ID: <4F5E6CBF.4080608@rath.org>
Date: Mon, 12 Mar 2012 17:38:07 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
References: <878vj7x6mj.fsf@vostro.rath.org> <87pqchn64e.fsf@inspiron.ap.columbia.edu> <20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org> <20120312201505.GC7203@fieldses.org> <87mx7lms1y.fsf@inspiron.ap.columbia.edu> <683A9678-14CF-4F27-8CC9-DD569722EE39@oracle.com>
In-Reply-To: <683A9678-14CF-4F27-8CC9-DD569722EE39@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2012 05:27 PM, Chuck Lever wrote:
> 
> On Mar 12, 2012, at 5:24 PM, Nikolaus Rath wrote:
> 
>> Alright, it seems that this was the problem. With correct clientaddr, I
>> haven't been able to produce any freezes for the last 15 minutes
>> (usually it happens in ~20 seconds).
>>
>> The weird thing is that I cannot reproduce the wrong clientaddr
>> autodetection when I mount the NFS volumes from the command line. It
>> seems to happen only when the mounting is done by mountall during the
>> boot sequence.
>>
>> In other words, this fstab entry results in freezes and a clientaddr of 0.0.0.0:
>>
>> spitzer:/opt /opt        nfs4    bg 0  0
>>
>> While this one, followed by a "mount /opt" on the console as soon as I'm
>> able to log in, works just fine (and has a correct clientaddr):
>>
>> spitzer:/opt /opt        nfs4    noauto 0  0
> 
> That's almost certainly because networking isn't up during boot.  The "bg" option keeps trying the mount until it succeeds, but the system started the mount process before there was a source address on the system.

Oh, so the clientaddr detection takes place only once at the beginning,
and is not repeated if the mount attempts are repeated?

This would explain what's happening. The VPN is not yet up when the
system first attempts to mount the share.

Is there a rationale behind this? It seems to me that if the mount is
retried, it would be reasonable to expect that the clientaddr detection
is retried as well.


Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
