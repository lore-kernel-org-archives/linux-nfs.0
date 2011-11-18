Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp02.citrix.com ([66.165.176.63]:25143 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab1KRSkE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 13:40:04 -0500
Message-ID: <4EC6A681.30902@citrix.com>
Date: Fri, 18 Nov 2011 18:40:01 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>
Subject: NFS TCP race condition with SOCK_ASYNC_NOSPACE
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

As described originally in
http://www.spinics.net/lists/linux-nfs/msg25314.html, we were
encountering a bug whereby the NFS session was unexpectedly timing out.

I believe I have found the source of the race condition causing the timeout.

Brief overview of setup:
  10GiB network, NFS mounted using TCP.  Problem reproduces with
multiple different NICs, with synchronous or asynchronous mounts, and
with soft and hard mounts.  Reproduces on 2.6.32 and I am currently
trying to reproduce with mainline. (I don't have physical access to the
servers so installing stuff is not fantastically easy)



In net/sunrpc/xprtsock.c:xs_tcp_send_request(), we try to write data to
the sock buffer using xs_sendpages()

When the sock buffer is nearly fully, we get an EAGAIN from
xs_sendpages() which causes a break out of the loop.  Lower down the
function, we switch on status which cases us to call xs_nospace() with
the task.

In xs_nospace(), we test the SOCK_ASYNC_NOSPACE bit from the socket, and
in the rare case where that bit is clear, we return 0 instead of
EAGAIN.  This promptly overwrites status in xs_tcp_send_request().

The result is that xs_tcp_release_xprt() finds a request which has no
error, but has not sent all of the bytes in its send buffer.  It cleans
up by setting XPRT_CLOSE_WAIT which causes xprt_clear_locked() to queue
xprt->task_cleanup, which closes the TCP connection.


Under normal operation, the TCP connection goes down and back up without
interruption to the NFS layer.  However, when the NFS server hangs in a
half closed state, the client forces a RST of the TCP connection,
leading to the timeout.

I have tried a few naive fixes such as changing the default return value
in xs_nospace() from 0 to -EAGAIN (meaning that 0 will never be
returned) but this causes a kernel memory leak.  Can someone who a
better understanding of these interactions than me have a look?  It
seems that the if (test_bit()) test in xs_nospace() should have an else
clause.

Thanks in advance,

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com

