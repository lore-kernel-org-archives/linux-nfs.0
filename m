Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp02.citrix.com ([66.165.176.63]:45639 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716Ab1KOOhA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Nov 2011 09:37:00 -0500
Message-ID: <4EC2790A.80706@citrix.com>
Date: Tue, 15 Nov 2011 14:36:58 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: unexpected NFS timeouts, related to sync/async soft mounts over
 TCP
References: <4EBAC88D.40902@citrix.com>		 <BEF32B02-0D19-4D97-8E93-C1797DF02CFE@oracle.com>		 <4EBBB247.40805@citrix.com>		 <2E3D3F87-479E-4096-B086-C8F83A0147B5@oracle.com>		 <4EBBF35B.5000606@citrix.com>	 <1320957784.11956.16.camel@lade.trondhjem.org>	 <4EBCF98E.6050101@citrix.com> <1321051132.4810.16.camel@lade.trondhjem.org> <4EC114BD.1010600@citrix.com>
In-Reply-To: <4EC114BD.1010600@citrix.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for a slow reply - this is unfortunately not the only bug I am
working on.

After further testing, this problem does actually reproduce with
synchronous mounts as well as asynchronous mounts.  It just takes some
extreme stress testing to reproduce with synchronous mounts.

After some debugging in xs_tcp_shutdown()  (a cheeky dump_stack()), it
appears that periodically xprt_autoclose() is closing the TCP connection.

It appears that some of the time, the server correctly FIN+ACKs the
first FIN, at which point the TCP connection is torn down and set back
up, with no interruption to the NFS session.  However, some of the time,
the server does not FIN+ACK the clients FIN, at which point the client
waits 15 seconds and RST's the TCP connection, leading to the errors seen.

What is the purpose of xprt_autoclose() ? I assume it is to
automatically close idle connections.  Am I correct in assuming that it
should not be attempting to close an active connection?

Thanks,

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com

