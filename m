Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esrismtp2.esri.com ([198.102.62.103]:51111 "EHLO Vail.esri.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296Ab1GUQvv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 12:51:51 -0400
Received: from leoray.esri.com (leoray.esri.com [10.27.102.12])
	by Vail.esri.com (8.13.7+Sun/8.13.7) with ESMTP id p6LGppi8006067
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 09:51:51 -0700 (PDT)
Received: from leoray.esri.com (leoray.esri.com [127.0.0.1])
	by leoray.esri.com (8.14.4/8.14.3) with ESMTP id p6LGpplo018519
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 09:51:51 -0700
Received: (from ray5147@localhost)
	by leoray.esri.com (8.14.4/8.14.3/Submit) id p6LGpprN018518
	for linux-nfs@vger.kernel.org; Thu, 21 Jul 2011 09:51:51 -0700
Date: Thu, 21 Jul 2011 09:51:51 -0700
From: Ray Van Dolson <rvandolson@esri.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS server responds to SYN with ACK only
Message-ID: <20110721165150.GA18456@esri.com>
References: <20110720192341.GA18167@esri.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110720192341.GA18167@esri.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 20, 2011 at 12:23:42PM -0700, Ray Van Dolson wrote:
> We have a couple legacy CentOS (RHEL)-based appliances with slightly
> dated NFS implementations.
> 
> Server (CentOS 4 based):
> 
>     nfs-utils-1.0.6-70.EL4
>     Kernel 2.6.9-42.0.10.plus.c4smp
> 
> Client (CentOS 5 based):
> 
>     nfs-utils-1.0.9-42.el5.x86_64
>     Kernel 2.6.18-164.15.1.el5
> 
> The client has a long-lived NFSv3 mount to the server that sometimes
> stops responding (blocks).  We can lazy unmount it, but subsequent
> mount requests hang and the following is observed via tcpdump:
> 
>     1. Client GETPORT for NFS service succeeds.
>     2. Client GETPORT for MOUNT succeeds
>     3. Client MNT call succeeds (server gives valid response including
>        file handle)
>     4. Client sends a SYN packet to NFS port on server
>     5. Server responds with ACK *only*
> 
> When we bounce the NFS daemon on the server, everything starts working
> and in step 5 above, we get a SYN,ACK as expected in response to #4,
> and everything proceeds along nicely.
> 
> Does this jog anybody on a long-ago fixed bug?  I'm thinking updating
> the kernel and nfs-utils on the server will likely help, but would love
> to find where behavior like the above is referenced as a "bug".
> 
> Thanks,
> Ray

After thinking on this a bit more, I'm wondering if perhaps the server
side had a connection still "open" (didn't check with netstat) and thus
sent back only the ACK.

Maybe in this case the client should respond with a RST or something
else to indicate we need to start from scratch?

Is there a way, on the server side to kill an ESTABLISHED TCP
connection (specifically an NFS connection?)?  Probably setting a
connection timeout value via /proc ...

I'm thinking on the client side I could inject a RST packet to the
server to clean things up?

Ray
