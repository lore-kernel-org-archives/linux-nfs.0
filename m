Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48186 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751921Ab1GOOCG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 10:02:06 -0400
Subject: Re: [PATCH 09/10] nfs: use sk fragment destructors to delay I/O
 completion until page is released by network stack.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 15 Jul 2011 10:01:29 -0400
In-Reply-To: <1310728031-19569-9-git-send-email-ian.campbell@citrix.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
	 <1310728031-19569-9-git-send-email-ian.campbell@citrix.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1310738489.4381.20.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-15 at 12:07 +0100, Ian Campbell wrote: 
> Thos prevents an issue where an ACK is delayed, a retransmit is queued (either
> at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> wire. If this happens then the write() system call and the userspace process
> can continue potentially modifying the data before the retransmission occurs.
> 
> NB: this only covers the O_DIRECT write() case. I expect other cases to need
> handling as well.

That is why this belongs entirely in the RPC layer, and really should
not touch the NFS layer.
If you move your callback to the RPC layer and have it notify the
rpc_task when the pages have been sent, then it should be possible to
achieve the same thing.

IOW: Add an extra state machine step after call_decode() which checks if
all the page data has been transmitted and if not, puts the rpc_task on
a wait queue, and has it wait for the fragment destructor callback
before calling rpc_exit_task().

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

