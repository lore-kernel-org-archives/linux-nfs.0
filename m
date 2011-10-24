Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout0.thls.bbc.co.uk ([132.185.240.35]:34405 "EHLO
	mailout0.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309Ab1JXNSJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 09:18:09 -0400
Date: Mon, 24 Oct 2011 13:17:34 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org
Subject: Re: NFS4 BAD_STATEID loop (kernel 3.0)
Message-ID: <20111024131734.GE32587@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
 <1319455367.8505.3.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319455367.8505.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> We should in principle be able to recover a BAD_STATEID error by running
> the state recovery thread. It's a shame that the machine was rebooted,
> but does your syslog trace perhaps show any state recovery thread
> errors?

There were no other nfs related messages reported between the initial
blocked task and rebooting the machine later.  Additionally, there were
no nfs related messages from bootup of the machine until the blocked
task.

One thing that may be of interest is that the user in question with the
blocked task had hit their quota hard limit.  (It was the same user that
had the issue i reported earlier too on the same filesystem).

Kind regards,
..david
