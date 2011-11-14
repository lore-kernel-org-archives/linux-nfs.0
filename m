Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx0.aculab.com ([213.249.233.131]:54067 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751326Ab1KNNd0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 08:33:26 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23698-01 for <linux-nfs@vger.kernel.org>;
 Mon, 14 Nov 2011 13:26:42 +0000 (GMT)
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 4/4] sunrpc: use SKB fragment destructors to delay completion until page is released by network stack.
Date: Mon, 14 Nov 2011 13:25:01 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEC1@saturn3.aculab.com>
In-Reply-To: <1321276055.3664.67.camel@zakaz.uk.xensource.com>
From: "David Laight" <David.Laight@ACULAB.COM>
To: "Ian Campbell" <Ian.Campbell@citrix.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        "Neil Brown" <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 
> This prevents an issue where an ACK is delayed, a retransmit is queued
(either
> at the RPC or TCP level) and the ACK arrives before the retransmission
hits the
> wire. If this happens to an NFS WRITE RPC then the write() system call
> completes and the userspace process can continue, potentially
modifying data
> referenced by the retransmission before the retransmission occurs.

The only problem I see is that the source address might get
invalidated (assuming it is a user address mapped into kernel).
Not sure what effect the fault would have...

If it is an RPC retransmittion the NFS write won't be
terminated by the RPC ACK (because it is a stale ACK)
and the destination will see two copies of the NFS write.
(This is quite common with NFS/UDP.)

If it is a TCP retransmittion, then the receiving TCP stack
will see it as duplicate data and discard the contents
without passing them to RPC.

Interrupting an NFS write with a signal is problematic
anyway - I'm sure I've seen systems (SYSV?) when NFS
writes were uninterruptable. NFI how Linux handles this.

	David


