Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:50487 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753784Ab2CLVyc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 17:54:32 -0400
Message-ID: <4F5E7098.9080607@rath.org>
Date: Mon, 12 Mar 2012 17:54:32 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
References: <878vj7x6mj.fsf@vostro.rath.org> <87pqchn64e.fsf@inspiron.ap.columbia.edu> <20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org> <20120312201505.GC7203@fieldses.org> <87mx7lms1y.fsf@inspiron.ap.columbia.edu> <683A9678-14CF-4F27-8CC9-DD569722EE39@oracle.com> <4F5E6CBF.4080608@rath.org> <49F11491-C455-4592-804B-B7AFADB00F43@oracle.com>
In-Reply-To: <49F11491-C455-4592-804B-B7AFADB00F43@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2012 05:46 PM, Chuck Lever wrote:
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

Thanks! Let me know if you need someone for testing.


Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
