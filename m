Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:11674 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382Ab1GOPVU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 11:21:20 -0400
Subject: Re: [PATCH 09/10] nfs: use sk fragment destructors to delay I/O
 completion until page is released by network stack.
From: Ian Campbell <Ian.Campbell@eu.citrix.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1310738489.4381.20.camel@lade.trondhjem.org>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
	 <1310728031-19569-9-git-send-email-ian.campbell@citrix.com>
	 <1310738489.4381.20.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 15 Jul 2011 16:21:18 +0100
Message-ID: <1310743278.20648.11.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-15 at 15:01 +0100, Trond Myklebust wrote:
> On Fri, 2011-07-15 at 12:07 +0100, Ian Campbell wrote: 
> > Thos prevents an issue where an ACK is delayed, a retransmit is queued (either
> > at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> > wire. If this happens then the write() system call and the userspace process
> > can continue potentially modifying the data before the retransmission occurs.
> > 
> > NB: this only covers the O_DIRECT write() case. I expect other cases to need
> > handling as well.
> 
> That is why this belongs entirely in the RPC layer, and really should
> not touch the NFS layer.
> If you move your callback to the RPC layer and have it notify the
> rpc_task when the pages have been sent, then it should be possible to
> achieve the same thing.
> 
> IOW: Add an extra state machine step after call_decode() which checks if
> all the page data has been transmitted and if not, puts the rpc_task on
> a wait queue, and has it wait for the fragment destructor callback
> before calling rpc_exit_task().

Make sense, I'll do that.

Thanks,
Ian.


