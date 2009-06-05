From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [round2 PATCH 0/7] nfs-utils: add support for authenticated callbacks
Date: Fri, 05 Jun 2009 14:57:25 -0400
Message-ID: <4A296A95.3070208@RedHat.com>
References: <20090520151651.2986.29621.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53419 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016AbZFETA1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 15:00:27 -0400
In-Reply-To: <20090520151651.2986.29621.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Coffman wrote:
> Hi Steve,
> 
> This series adds support to gssd and svcgssd to support
> authenticated callbacks.
> 
> 1) adds the name the client used when authenticating to the
> svcgssd downcall information.  This is used by nfsd to determine
> the target name when initiating the callback.
> 
> 2) splits out the processing of update_client_list() to accomodate
> a new upcall pipe added in the next patch.
> 
> 3) changes gssd to process all rpc_pipefs directories (this patch is
> changed from the first round to process all directories rather than
> special-casing directories)
> 
> 4) a debugging aid to distinquish which upcall is being processed
> 
> 6) adds support for handling the "target=" attribute in the new upcall
> 
> 7) adds support for handling the "service=" attribute in the new upcall
> 
> NOTE:  For authenticated callbacks to work, an NFS client or an
> NFS server must be running both rpcgssd _and_ rpcsvcgssd.
> This will require a configuration change.

Question, How are authenticated callbacks are not configured?
Also do both daemons have to be running if authenticated 
callbacks are not configured?

steved.
