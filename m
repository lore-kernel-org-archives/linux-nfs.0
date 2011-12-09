Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153Ab1LITK6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Dec 2011 14:10:58 -0500
Date: Fri, 9 Dec 2011 14:10:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: linux-image: on nfs4 server: RPC: AUTH_GSS upcall timed out
 Please check user daemon is running
Message-ID: <20111209191057.GA10089@fieldses.org>
References: <8762hrozdl.fsf@fifthhorseman.net>
 <20111208174501.GA30088@fieldses.org>
 <4EE253EC.2040609@fifthhorseman.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EE253EC.2040609@fifthhorseman.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 09, 2011 at 01:31:08PM -0500, Daniel Kahn Gillmor wrote:
> On 12/08/2011 12:45 PM, J. Bruce Fields wrote:
> > Yes, if you're using NFSv4 then the client and server should each run
> > both daemons.
> 
> ah, thanks.
> 
> >> If so, what functionality am i losing out on by not running it?
> > 
> > You lose NFSv4.0 delegations, which depend on the ability for the server
> > to contact the client to send delegation recalls.  Delegations are
> > optional, so you won't lose correctness, but you may lose some
> > performance.
> 
> Thanks, that's useful.  Do the clients need to run cachefilesd as well
> to take advantage of delegation?

No.

> Is there a document where i could find
> this sort of information without adding noise to the list?

Hm, it should probably be in the FAQ.  I think we want to make

	http://wiki.linux-nfs.org/

the place to go for Linux NFS information, so if you can't find this
under there somewhere, let's think about where to put it.  Suggestions
welcomed.

> > If you're using only v2, v3, or v4.1, that doesn't matter.  (v2 and v3
> > lack delegations, and v4.1 sends callbacks over existing
> > client-established connections).
> 
> OK, gotcha.  Is it possible to use 4.1 with linux kernel 3.1 and
> nfs-utils 1.2.5, or would i need to pull a more recent version?

It should be possible.  4.1 is somewhat new, though.

--b.
