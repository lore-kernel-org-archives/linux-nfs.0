Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout0.mh.bbc.co.uk ([132.185.144.151]:59685 "EHLO
	mailout0.mh.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208Ab1JXKkk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 06:40:40 -0400
Date: Mon, 24 Oct 2011 10:16:59 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org
Subject: Re: NFS4 client blocked (kernel 3.0.4)
Message-ID: <20111024101659.GC32587@rd.bbc.co.uk>
References: <20111022082838.GB32587@rd.bbc.co.uk>
 <1319449185.2785.6.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319449185.2785.6.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> > [105121.204200] INFO: task bash:4457 blocked for more than 120 seconds.
> > [105121.247424] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> Does 'echo 0 >/proc/sys/sunrpc/rpc_debug' show anything being stuck in
> the RPC layer?

Unfortunately that system had to be rebooted.  If it occurs again, i
shall perform the check.

Kind regards,

..david
