Return-Path: linux-nfs-owner@vger.kernel.org
Received: from inspiron.ap.columbia.edu ([128.59.145.39]:48640 "EHLO
	inspiron.ap.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412Ab2CMNXr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2012 09:23:47 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
To: linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
References: <878vj7x6mj.fsf@vostro.rath.org>
	<87pqchn64e.fsf@inspiron.ap.columbia.edu>
	<20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org>
	<20120312201505.GC7203@fieldses.org>
	<87mx7lms1y.fsf@inspiron.ap.columbia.edu>
	<683A9678-14CF-4F27-8CC9-DD569722EE39@oracle.com>
	<4F5E6CBF.4080608@rath.org>
	<49F11491-C455-4592-804B-B7AFADB00F43@oracle.com>
	<1331589478.12005.13.camel@lade.trondhjem.org>
Date: Tue, 13 Mar 2012 09:23:46 -0400
In-Reply-To: <1331589478.12005.13.camel@lade.trondhjem.org> (Trond Myklebust's
	message of "Mon, 12 Mar 2012 21:57:59 +0000")
Message-ID: <87haxsocrh.fsf@inspiron.ap.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org> writes:
>> > Oh, so the clientaddr detection takes place only once at the beginning,
>> > and is not repeated if the mount attempts are repeated?
>> > 
>> > This would explain what's happening. The VPN is not yet up when the
>> > system first attempts to mount the share.
>> > 
>> > Is there a rationale behind this? It seems to me that if the mount is
>> > retried, it would be reasonable to expect that the clientaddr detection
>> > is retried as well.
>> 
>> There's no reason I can recall requiring that this is done only once, other than it's the simplest implementation for mount.nfs.  Historically, NFS is deployed on systems with static network configurations that are supposed to be set up before the NFS utilities come into play.  As Bruce suggested, perhaps this design assumption needs to be revisited.
>> 
>> I suppose I should file a bug.
>
> Consider the whole 'bg' option to be a bug at this point.
>
> Now that we have working autofs support for direct mounts, there is no
> reason to keep the 'bg' mount option on life support any more.

I'm not sure that this would be a solution. What happens if some
program accesses the autofs mountpoint before the VPN is up? Wouldn't
autofs try to mount the NFS share right away and thus with a broken
clientaddr?


Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
