From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC 0/10] nfsd41 server backchannel for 2.6.31
Date: Sun, 3 May 2009 16:53:43 -0400
Message-ID: <20090503205343.GD22306@fieldses.org>
References: <49FA2D86.8060402@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38786 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466AbZECUxo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 16:53:44 -0400
In-Reply-To: <49FA2D86.8060402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2009 at 02:00:22AM +0300, Benny Halevy wrote:
> Bruce,
> 
> After squashing and merging Ricardo's latest patchset
> please review the following patchset and consider for 2.6.31.

Note this will conflict with the pending changes I have to make the
current callbacks use asynchronous rpc tasks instead of
kthreads--apologies.  I'll try to get those into for-2.6.31 tomorrow,
and then I hope you won't mind working on top of that?

--b.

> 
> Thanks,
> 
> Benny
> 
> [RFC 01/10] nfsd: cleanup nfs4.0 callback encode routines
> [RFC 02/10] nfsd: minorversion support for the back channel
> [RFC 03/10] nfsd41: sunrpc: Added rpc server-side backchannel handling
> [RFC 04/10] nfsd41: Remember the auth flavor to use for callbacks
> [RFC 05/10] nfsd41: callback infrastructure
> [RFC 06/10] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
> [RFC 07/10] nfsd41: Backchannel: Server backchannel RPC wait queue
> [RFC 08/10] nfsd41: Backchannel: Setup sequence information
> [RFC 09/10] nfsd41: cb_sequence callback
> [RFC 10/10] nfsd41: cb_recall callback
