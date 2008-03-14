From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 2.6.24: RPC: bad TCP reclen 0x00020090 (large)
Date: Fri, 14 Mar 2008 21:57:00 +0300
Message-ID: <47DACA7C.8020807@msgid.tls.msk.ru>
References: <C4001FE3.3BDB9%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:22407 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529AbYCNS5F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Mar 2008 14:57:05 -0400
In-Reply-To: <C4001FE3.3BDB9%tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Tucker wrote:
> Michael:
> 
>>>>>> On Wed, 13 Feb 2008 17:02:53 +0300 Michael Tokarev <mjt@tls.msk.ru> wrote:
>>>>>>
>>>>>>> Hello!
>>>>>>>
>>>>>>> After upgrading to 2.6.24 (from .23), we're seeing ALOT
>>>>>>> of messages like in $subj in dmesg:
>>>>>>>
>>>>>>> Feb 13 13:21:39 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
>>>>>>> Feb 13 13:21:46 paltus kernel: printk: 3586 messages suppressed.
>>>>>>> Feb 13 13:21:46 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
>>>>>>> Feb 13 13:21:49 paltus kernel: printk: 371 messages suppressed.
>>>>>>> Feb 13 13:21:49 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
>>>>>>> Feb 13 13:21:55 paltus kernel: printk: 2979 messages suppressed.
>>>>>>> ...
>>>>>>>
> 
> Are you seeing this with the latest bits?  I just want to make sure that
> this particular close path issue is fixed.

Err.  I completely forgot about that issue, due to many many other
issues popped up last few weeks...

Ok.

I tried to reproduce it here.  It happened only once here, when I changed
the kernel on the NFS server from 2.6.23-i686 to 2.6.24-x86-64, without
rebooting/remounting clients.  The messages shown above were on the server.
After remounting the filesystem on clients, the message disappeared.

After that, I tried the same thing with other machines (that one was
our main production server so no experiments there) -- same clients but
another server.  I did many reboots with different kernels while the
clients had filesystems mounted - but wasn't able to reproduce the same
messages again.

So I don't really know what happened, and even if whatever happened
was due to single client or not - I wasn't thought about tcpdump at
the time when I were remounting the clients.  Maybe it was a random
glitch, maybe it IS a bug - I don't really know by now.

There was another issue before, when after upgrading the server,
clients were needed to remount stuff or else "ESTALE" were always
returned.  I think it was around 2.6.21=>2.6.22.  Again, I can't
reproduce it anymore (with current kernels).

So I think the case can be closed now - esp. since noone (it seems)
reported similar issues.

Thank you!

/mjt
