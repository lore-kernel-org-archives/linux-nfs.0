From: Jeff Layton <jlayton@redhat.com>
Subject: why set send and receive buffers in svc_sock_setbufsize()?
Date: Thu, 23 Oct 2008 14:48:44 -0400
Message-ID: <20081023144844.610e294d@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: smfrench@gmail.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58964 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753132AbYJWSst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 14:48:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been reviewing a patch for CIFS, and out of the discussions over
that patch, there's been the recommendation to not set sk_sndbuf and
sk_rcvbuf. Apparently, setting these to a value will place a hard limit
on the buffer sizes for the socket, so there's not much need to set
these unless we want to limit memory usage to this value for some
reason.

One question is that the sunrpc code sets these values in
svc_sock_setbufsize(). What is the reasoning behind this?

If we're doing it to limit memory consumption then that's certainly
valid, but if we're doing this to attempt to make sure that we have
"enough" buffer space for the expected load then this may be
counter-productive.

-- 
Jeff Layton <jlayton@redhat.com>
