Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.citrix.com ([66.165.176.89]:59964 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754638Ab1KPOvF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 09:51:05 -0500
Message-ID: <4EC3CDD7.801@citrix.com>
Date: Wed, 16 Nov 2011 14:51:03 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: unexpected NFS timeouts, related to sync/async soft mounts over
 TCP
References: <4EBAC88D.40902@citrix.com>		 <BEF32B02-0D19-4D97-8E93-C1797DF02CFE@oracle.com>		 <4EBBB247.40805@citrix.com>		 <2E3D3F87-479E-4096-B086-C8F83A0147B5@oracle.com>		 <4EBBF35B.5000606@citrix.com>	 <1320957784.11956.16.camel@lade.trondhjem.org>	 <4EBCF98E.6050101@citrix.com> <1321051132.4810.16.camel@lade.trondhjem.org> <4EC114BD.1010600@citrix.com> <4EC2790A.80706@citrix.com>
In-Reply-To: <4EC2790A.80706@citrix.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Further debugging shows that the FINs are being inserted because of a
call to xs_tcp_release_xprt(), where req->rq_bytes_sent !=
req->rq_snd_buf.len

Some of the time, the netapp server FIN+ACKs and the TCP connection goes
down and back up without adversely affecting the NFS session.  However,
some of the time, the server does not FIN+ACK the clients FIN, causing a
15 second timeout before the client RSTs the TCP connection, causing the
visible problems to the NFS session.

I would say that the netapp not FIN+ACKing is a bug in itself, but I
would also say that it is a bug for the client to not be able to send
all of its send buffer.

Are there cases where not sending its send buffer is expected, or is it
a state which should be avoided?

~Andrew

On 15/11/11 14:36, Andrew Cooper wrote:
> Sorry for a slow reply - this is unfortunately not the only bug I am
> working on.
>
> After further testing, this problem does actually reproduce with
> synchronous mounts as well as asynchronous mounts.  It just takes some
> extreme stress testing to reproduce with synchronous mounts.
>
> After some debugging in xs_tcp_shutdown()  (a cheeky dump_stack()), it
> appears that periodically xprt_autoclose() is closing the TCP connection.
>
> It appears that some of the time, the server correctly FIN+ACKs the
> first FIN, at which point the TCP connection is torn down and set back
> up, with no interruption to the NFS session.  However, some of the time,
> the server does not FIN+ACK the clients FIN, at which point the client
> waits 15 seconds and RST's the TCP connection, leading to the errors seen.
>
> What is the purpose of xprt_autoclose() ? I assume it is to
> automatically close idle connections.  Am I correct in assuming that it
> should not be attempting to close an active connection?
>
> Thanks,
>

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com

