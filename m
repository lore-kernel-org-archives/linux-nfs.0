Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48357 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbbIASIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2015 14:08:49 -0400
Date: Tue, 1 Sep 2015 14:08:49 -0400
To: Andrew W Elble <aweits@rit.edu>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        etmsys@rit.edu
Subject: Re: [PATCH] nfsd: deal with DELEGRETURN racing with CB_RECALL
Message-ID: <20150901180849.GB1948@fieldses.org>
References: <1441037201-78787-1-git-send-email-aweits@rit.edu>
 <20150901091842.7c40adf3@tlielax.poochiereds.net>
 <m2mvx6jlbj.fsf@discipline.rit.edu>
 <m27foajiv8.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m27foajiv8.fsf@discipline.rit.edu>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 01, 2015 at 10:48:27AM -0400, Andrew W Elble wrote:
> 
> I should probably state what I'm currently chasing:
> 
> 1.) Somehow, delegations wind up on the cl_revoked list at the server.
> 2.) The server continually asserts SEQ4_STATUS_RECALLABLE_STATE_REVOKED.
> 3.) The client for some reason doesn't have anything to give the server
>     to satisfy it.
> 
> I speculate that this patch will assist in making this go away - I'm
> just not 100% sure of all the conditions that result in making #1 possible.
> (Enough recalls backed up on the callback slot on the same filehandle
> stacking timeouts/retries and resultant path down errors to exceed lease
> time?).

Even in the worst case where the client never gets the recall, in theory
it should take the RECALLABLE_STATE_REVOKED as a sign that it's missed
one and return its delegations.  Is the client attempting any such
recovery when it sees that flag?

> Unfortunately this problem seems to always occur at ~1AM - and
> obtaining a network capture of the problem in action has been elusive.

Anyway, sounds interesting, let us know what you find....

--b.
