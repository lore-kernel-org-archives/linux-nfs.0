From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: Huge race in lockd for async lock requests?
Date: Tue, 19 May 2009 17:33:44 -0400
Message-ID: <4a1325c5.09025a0a.1fbd.7aaf@mx.google.com>
References: <4A0D80B6.4070101@redhat.com>
 <4A0D9D63.1090102@hp.com>
 <4A11657B.4070002@redhat.com>
 <4A1168E0.3090409@hp.com>
 <4A1319F9.90304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:36079 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbZESVd4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2009 17:33:56 -0400
Received: by gxk10 with SMTP id 10so120468gxk.13
        for <linux-nfs@vger.kernel.org>; Tue, 19 May 2009 14:33:57 -0700 (PDT)
In-Reply-To: <4A1319F9.90304@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 04:43 PM 5/19/2009, Rob Gardner wrote:
>I've got a question about lockd in conjunction with a filesystem that 
>provides its own (async) locking.
>
>After nlmsvc_lock() calls vfs_lock_file(), it seems to be that we might 
>get the async callback (nlmsvc_grant_deferred) at any time. What's to 
>stop it from arriving before we even put the block on the nlm_block 
>list? If this happens, then nlmsvc_grant_deferred() will print "grant 
>for unknown block" and then we'll wait forever for a grant that will 
>never come.

Yes, there's a race but the client will retry every 30 seconds, so it won't
wait forever. Depending on the kernel client version, there are some
improvements we've tried over time to close the raciness a little. What
exact client version are you working with?

>
>Seems like we ought to do nlmsvc_insert_block() before vfs_lock_file() 
>at the very least; But this still leaves problems where the lock is 
>granted via the callback while we're still in nlmsvc_lock(), and we 
>ignore it and tell the client that the lock is blocked; Now they'll have 
>to retry before getting the lock.

It's a little worse than that. It's also possible for the client to hold a lock,
but a stray or retried server callback can cause the client to reject it,
releasing the lock at the server. This causes the server to grant the lock
to another client even though the first client still thinks it holds it. It's an
NLM protocol issue, frankly, due to the fact that the server callback is a
completely separate channel.

>
>Any thoughts on this besides "give up on using lockd"?

Use NFSv4? ;-)

Tom.

>
>Rob Gardner
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

