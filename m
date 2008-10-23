From: Jim Rees <rees@umich.edu>
Subject: Re: why set send and receive buffers in svc_sock_setbufsize()?
Date: Thu, 23 Oct 2008 15:05:33 -0400
Message-ID: <20081023190533.GA11478@citi.umich.edu>
References: <20081023144844.610e294d@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, smfrench@gmail.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.93.160]:34553 "EHLO
	skycaptain.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756895AbYJWTFt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2008 15:05:49 -0400
In-Reply-To: <20081023144844.610e294d-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:

  I've been reviewing a patch for CIFS, and out of the discussions over
  that patch, there's been the recommendation to not set sk_sndbuf and
  sk_rcvbuf. Apparently, setting these to a value will place a hard limit
  on the buffer sizes for the socket, so there's not much need to set
  these unless we want to limit memory usage to this value for some
  reason.

There are two issues to be aware of.  One is that the socket buffers have to
be big enough for the tcp congestion window.  In the old days, the
application would have to know ahead of time how big this is, and call
setsockopt(), which sets these numbers.

Now however, the tcp stack "autotunes" the buffer sizes to the correct
amount.  If you call setsockopt() to set a buffer size, or set sk_*buf, or
set the SOCK_*BUF_LOCK bits in sk_userlocks, you defeat this autotuning.
This is almost always a bad idea.

The other issue is that at least for NFS, the receive buffer must be big
enough to hold the biggest possible rpc.  If not, a partial rpc will get
stuck in the buffer and no progress will be made.

Issue one is easy to deal with, just don't muck with the socket internal
data structure.  The second one is harder.  What's really needed is a new
api into the tcp layer that will reserve a minimum amount of memory in the
socket buffer so that receives won't stall.  For now, our patch sets the
sk_*buf values without setting the lock flags.
