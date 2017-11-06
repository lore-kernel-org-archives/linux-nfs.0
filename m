Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46308 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932473AbdKFTf2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 14:35:28 -0500
Date: Mon, 6 Nov 2017 14:35:28 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] nfsd: deal with revoked delegations appropriately
Message-ID: <20171106193528.GA13456@fieldses.org>
References: <20171103180631.76071-1-aweits@rit.edu>
 <1509734212.21477.16.camel@primarydata.com>
 <20171106151531.GB599@fieldses.org>
 <m2fu9rqpqo.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2fu9rqpqo.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 06, 2017 at 12:30:23PM -0500, Andrew W Elble wrote:
> Prior thread (roughly) here: http://www.spinics.net/lists/linux-nfs/msg55260.html
> 
> This is the one patch I'm still carrying from the lost delegation work a
> while back. Testing showed that there is a path still open to lost
> delegations via delegreturn.
> 
> running with:
> echo "error != 0" | sudo tee /sys/kernel/debug/tracing/events/nfs4/nfs4_delegreturn_exit/filter
> 
> gave us this at one point with an interim version of this patch:
> 
> kworker/0:0H-3990  [000] .... 5899655.609266: nfs4_delegreturn_exit: 
>                error=-10087 (DELEG_REVOKED) dev=00:30 fhandle=0xe43d9d3a
> kworker/0:2H-12665 [000] .... 5900011.719468: nfs4_delegreturn_exit: 
>                error=-10087 (DELEG_REVOKED) dev=00:30 fhandle=0x16e37c0a
> 
> The Linux client prior to 26d36301bd653df6481fd38f3e1435a1f15e56d1 would
> just drop delegations that suffered from a nfserr_bad_stateid during
> delegreturn. Now it will do test/free if the return error is
> nfserr_deleg_revoked.
> 
> If the client drops a delegation while the server has it on the revoked
> list, we stay stuck in endless state manager looping for that client.
> 
> It might be a good idea for a stable backport of aforementioned commit,
> or some kind of other workaround? Possibly interpreting
> nfserr_bad_stateid an analogue of nfserr_deleg_revoked clientside
> when dealing with a >4.0 mount? (also seems like an error on the putfh
> might need to be caught as well?)

I'm just looking for a concise explanation of why your patch is
important.  And I probably haven't dug enough, but I'm still not quite
following.

If I understand right, the only visible change from your patch will be
returning DELEG_REVOKED instead of BAD_STATEID to 4.1 clients in some
cases.  I'm not clear what the result was (for old or new clients)--a
client left believing it held a delegation when it didn't, or a client
entering an infinite state manager loop?

--b.
