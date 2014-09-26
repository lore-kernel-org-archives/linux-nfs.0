Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754259AbaIZUpv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 16:45:51 -0400
Date: Fri, 26 Sep 2014 16:45:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] nfsd: support for lifting grace period early
Message-ID: <20140926204549.GF27412@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
 <20140926183949.GC27412@fieldses.org>
 <20140926145446.21a99698@tlielax.poochiereds.net>
 <20140926194616.GE27412@fieldses.org>
 <CAABAsM664Ce0JhBa=uK9+srsNB4_Ww4LLTymfOvcr1aM3g2X=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAABAsM664Ce0JhBa=uK9+srsNB4_Ww4LLTymfOvcr1aM3g2X=g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 04:37:23PM -0400, Trond Myklebust wrote:
> On Fri, Sep 26, 2014 at 3:46 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > As I understand it, the rule for the client is: you're allowed to
> > reclaim only the set locks that you held previously, where "the set of
> > locks you held previously" is "the set of locks held by the clientid
> > which last managed to send a reclaim OPEN or OPEN_CONFIRM".  So for
> > example once client1 sends that unrelated OPEN reclaim it's giving up on
> > anything else it doesn't manage to reclaim this time around.
> 
> The rule for the client is very simple: "You may attempt to reclaim
> any locks that were held immediately prior to the reboot of the
> server."
> It doesn't matter how those locks were established (ordinary OPEN,
> delegated open, reclaim open, LOCK, reclaim lock...).
> 
> However if the server reboots and the client did not manage to
> re-establish a lease (SETCLIENTID+SETCLIENTID_CONFIRM and/or
> EXCHANGE_ID+CREATE_SESSION) before the second reboot, then it is the
> server's responsibility to block that client from reclaiming any
> locks, since the client has no way to know how many times the server
> has rebooted.
> Ditto, of course, if the client tries to reclaim any locks outside the
> grace period and the server isn't tracking whether or not those locks
> have been handed out to another client.

Agreed with everything except:

	(SETCLIENTID+SETCLIENTID_CONFIRM and/or
	EXCHANGE_ID+CREATE_SESSION)

If I remember correctly: RFC 5661 says the point where this happens is
actually RECLAIM_COMPLETE.  RFC 3530 was more vague but suggested first
OPEN reclaim or OPEN_CONFIRM, and 3530bis makes that explicit.

But the client can choose an earlier point without violating the
protocol--it means it will decline reclaiming some things it could have,
but that's safer than the reverse mistake.

--b.
