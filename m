From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: Huge race in lockd for async lock requests?
Date: Wed, 20 May 2009 00:55:47 -0600
Message-ID: <4A13A973.4050703@hp.com>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com> <4A1168E0.3090409@hp.com> <4A1319F9.90304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:13718 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269AbZETGyW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 02:54:22 -0400
Received: from g5t0012.atlanta.hp.com (g5t0012.atlanta.hp.com [15.192.0.49])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g4t0016.houston.hp.com (Postfix) with ESMTPS id 1559B14773
	for <linux-nfs@vger.kernel.org>; Wed, 20 May 2009 06:54:19 +0000 (UTC)
Received: from [192.168.4.14] (unknown [76.76.75.3])
	by g5t0012.atlanta.hp.com (Postfix) with ESMTPSA id 9CB311001F
	for <linux-nfs@vger.kernel.org>; Wed, 20 May 2009 06:54:18 +0000 (UTC)
In-Reply-To: <4A1319F9.90304@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote:
> At 04:43 PM 5/19/2009, Rob Gardner wrote:
> >I've got a question about lockd in conjunction with a filesystem that 
> >provides its own (async) locking.
> >
> >After nlmsvc_lock() calls vfs_lock_file(), it seems to be that we might 
> >get the async callback (nlmsvc_grant_deferred) at any time. What's to 
> >stop it from arriving before we even put the block on the nlm_block 
> >list? If this happens, then nlmsvc_grant_deferred() will print "grant 
> >for unknown block" and then we'll wait forever for a grant that will 
> >never come.
>
> Yes, there's a race but the client will retry every 30 seconds, so it won't
> wait forever.
OK, a blocking lock request will get retried in 30 seconds and work out 
"ok". But a non-blocking request will get in big trouble. Let's say the 
callback is invoked immediately after the vfs_lock_file call returns 
FILE_LOCK_DEFERRED. At this point, the block is not on the nlm_block 
list, so the callback routine will not be able to find it and mark it as 
granted. Then nlmsvc_lock() will call nlmsvc_defer_lock_rqst(), put the 
block on the nlm_block list, and eventually the request will timeout and 
the client will get lck_denied. Meanwhile, the lock has actually been 
granted, but nobody knows about it.

>  Depending on the kernel client version, there are some
> improvements we've tried over time to close the raciness a little. What
> exact client version are you working with?
>   

I maintain nfs/nlm server code for a NAS product, and so there is no 
"exact client" but rather a multitude of clients that I have no control 
over. All I can do is hack the server. We have been working around this 
by using a semaphore to cover the vfs_lock_file() to 
nlmsvc_insert_block() sequence in nlmsvc_lock() and also 
nlmsvc_grant_deferred(). So if the callback arrives at a bad time, it 
has to wait until the lock actually makes it onto the nlm_block list, 
and so the status of the lock gets updated properly.

> Use NFSv4? ;-)
>   

I had a feeling you were going to say that. ;-)  Unfortunately that 
doesn't make NFSv3 and lockd go away.


Rob Gardner





