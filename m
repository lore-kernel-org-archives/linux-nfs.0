From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering
  rpcbind registrations.
Date: Thu, 11 Jun 2009 14:49:10 +1000
Message-ID: <18992.36038.267957.467326@notabene.brown>
References: <20090528062730.15937.70579.stgit@notabene.brown>
	<20090528063303.15937.62423.stgit@notabene.brown>
	<4a1e8c9e.48c3f10a.6d51.4c33@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58713 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754817AbZFKEsj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jun 2009 00:48:39 -0400
In-Reply-To: message from Tom Talpey on Thursday May 28
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday May 28, tmtalpey@gmail.com wrote:
> At 02:33 AM 5/28/2009, NeilBrown wrote:
> >Unregistering an RPC service is not essential - but it is tidy.
> >So it is unpleasant to wait a long time for it to complete.
> >
> >As unregistering is always directed to localhost, the most likely
> >reason for any delay is the portmap (or rpcbind) is not running.
> >In that case, waiting it totally pointless.  In any case, we should
> >expect a quick response, and zero packet loss.
> >
> >So reduce the timeouts to a total of half a second.
> 
> Why wait for the response at all in this case? With zero retries
> and nothing to do with the result, it seems pointless to even wait
> for half a second.

That's a fair point, thanks.  I'll keep that in mind if I revisit
these patches.

Thanks,
NeilBrown
