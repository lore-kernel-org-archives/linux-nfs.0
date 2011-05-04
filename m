Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46568 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299Ab1EDBqU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 21:46:20 -0400
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: andros@netapp.com, Jeff Layton <jlayton@redhat.com>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20110504111825.6f26f75a@notabene.brown>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	 <1304386808-2733-2-git-send-email-andros@netapp.com>
	 <20110503202023.699435f4@corrin.poochiereds.net>
	 <1304469890.26184.16.camel@lade.trondhjem.org>
	 <20110504111825.6f26f75a@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 May 2011 21:46:03 -0400
Message-ID: <1304473563.26184.28.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-05-04 at 11:18 +1000, NeilBrown wrote:
> For rpc slots, I doubt you need mempools at all.
> Mempools are only needed if failure is not an option and you would rather
> wait, but you cannot wait for regular writeback because you are on the
> writeback path.  So you use a mempool which waits for a previous request to
> complete.  I don't think that describes rpc slots at all.
> For rpc slots, you can afford to wait when setting up the transport, as you
> are not on the writeout path yet, and later you can always cope with failure.
> So just use kmalloc.

Errr.... No. By the time you get to allocating an RPC slot, you may be
bang smack in the middle of the writeout path.

The scenario would be that something triggers a writeback (kswapd,
direct reclaim,...) which triggers an RPC call, which requires you to
allocate at least one rpc slot before you can put the write on the wire.

I agree with your assertion that we only need one successful slot
allocation in order to make overall forward progress, but we definitely
do need that one...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

