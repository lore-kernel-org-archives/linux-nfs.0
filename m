Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522Ab1EDPIo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2011 11:08:44 -0400
Date: Wed, 4 May 2011 11:08:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Message-ID: <20110504110841.6e3e85e4@tlielax.poochiereds.net>
In-Reply-To: <1304386808-2733-2-git-send-email-andros@netapp.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	<1304386808-2733-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon,  2 May 2011 21:40:08 -0400
andros@netapp.com wrote:

> +	if (!test_and_clear_bit(XPRT_WRITE_SPACE, &xprt->state))
> +		return;

Also, I'm not sure that a single bit really conveys enough information
for this.

IIUC, sk_write_space gets called when a packet is TCP ACK'ed. It seems
possible that we would sometimes have buffer space available to queue
the packet without sk_write_space being called. With this, we'll
basically be serializing all dynamic slot allocations behind the
sk_write_space callbacks.

Consider the case of many small TCP frames being sent after a large one
just got ACK'ed. Only one would be allowed to be sent, even though
there might be enough send buffer space to allow for more.

Would it instead make more sense to base this on the amount of space
available in the actual socket rather than this bit?

-- 
Jeff Layton <jlayton@redhat.com>
