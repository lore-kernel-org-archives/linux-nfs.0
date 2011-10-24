Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25348 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932535Ab1JXNdD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2011 09:33:03 -0400
Subject: Re: NFS4 BAD_STATEID loop (kernel 3.0)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Flynn <davidf@rd.bbc.co.uk>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 24 Oct 2011 15:32:45 +0200
In-Reply-To: <20111024131734.GE32587@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
	 <1319455367.8505.3.camel@lade.trondhjem.org>
	 <20111024131734.GE32587@rd.bbc.co.uk>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319463165.2734.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-24 at 13:17 +0000, David Flynn wrote: 
> * Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> > We should in principle be able to recover a BAD_STATEID error by running
> > the state recovery thread. It's a shame that the machine was rebooted,
> > but does your syslog trace perhaps show any state recovery thread
> > errors?
> 
> There were no other nfs related messages reported between the initial
> blocked task and rebooting the machine later.  Additionally, there were
> no nfs related messages from bootup of the machine until the blocked
> task.
> 
> One thing that may be of interest is that the user in question with the
> blocked task had hit their quota hard limit.  (It was the same user that
> had the issue i reported earlier too on the same filesystem).
> 
> Kind regards,
> ..david

I'm assuming then that your network trace showed no sign of any OPEN
calls of that particular file, just retries of the WRITE?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

