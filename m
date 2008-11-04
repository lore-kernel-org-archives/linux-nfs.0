From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] lockd: convert reclaimer thread to kthread interface
Date: Tue, 04 Nov 2008 14:26:21 -0500
Message-ID: <1225826781.30407.11.camel@heimdal.trondhjem.org>
References: <1225278945-15407-1-git-send-email-jlayton@redhat.com>
	 <20081103131215.75a83236.akpm@linux-foundation.org>
	 <20081103191924.16528bfd@tleilax.poochiereds.net>
	 <1225802508.19864.2.camel@heimdal.trondhjem.org>
	 <20081104134235.0382c873@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	hch@infradead.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:38079 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbYKDT0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2008 14:26:30 -0500
In-Reply-To: <20081104134235.0382c873-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-11-04 at 13:42 -0500, Jeff Layton wrote:
> While we're on the subject of signals...
> 
> Do you have any thoughts/objections to just making the reclaimer thread
> ignore them altogether? That would simplify the code a bit.

How does the administrator then get out of the situation where the
server dies (permanently) in the middle of a reclaim?

Forced unmounts won't help here, since they only signal the NFS
requests, and are in any case per-filesystem, not per-server.

I suppose one could use soft RPC calls, but what should the retry policy
be for that case?

Trond

