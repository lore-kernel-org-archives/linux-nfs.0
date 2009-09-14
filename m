Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:36042 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757496AbZINXlx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 19:41:53 -0400
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: Tue, 15 Sep 2009 09:42:56 +1000
Content-Type: text/plain; charset=us-ascii
Message-ID: <19118.54528.73058.553169@notabene.brown>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS/RPC: fix problems with reestablish_timeout and
 related code.
In-Reply-To: message from Trond Myklebust on Monday September 14
References: <19114.56564.845241.525591@notabene.brown>
	<1252956700.6866.85.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Monday September 14, trond.myklebust@fys.uio.no wrote:
> On Sat, 2009-09-12 at 09:27 +1000, Neil Brown wrote:
> > [[resending with correct cc:  - "vfs.kernel.org" just isn't right!]]
> > 
> > xprt->reestablish_timeout is used to cause TCP connection attempts to
> > back off if the connection fails so as not to hammer the network,
> > but to still allow immediate connections when there is no reason to
> > believe there is a problem.
> > 
> > It is not used for the first connection (when transport->sock is NULL)
> > but only on reconnects.
> > 
> > It is currently set:
> > 
> >  a/ to 0 when xs_tcp_state_change finds a state of TCP_FIN_WAIT1
> >     on the assumption that the client has closed the connection
> >     so the reconnect should be immediate when needed.
> >  b/ to at least XS_TCP_INIT_REEST_TO when xs_tcp_state_change
> >     detects TCP_CLOSING or TCP_CLOSE_WAIT on the assumption that the
> >     server closed the connection so a small delay at least is
> >     required.
> >  c/ as above when xs_tcp_state_change detects TCP_SYN_SENT, so that
> >     it is never 0 while a connection has been attempted, else
> >     the doubling will produce 0 and there will be no backoff.
> >  d/ to double is value (up to a limit) when delaying a connection,
> >     thus providing exponential backoff and
> >  e/ to XS_TCP_INIT_REEST_TO in xs_setup_tcp as simple initialisation.
> > 
> > So you can see it is highly dependant on xs_tcp_state_change being
> > called as expected.  However experimental evidence shows that
> > xs_tcp_state_change does not see all state changes.
> > ("rpcdebug -m rpc trans" can help show what actually happens).
> > 
> > Results show:
> >  TCP_ESTABLISHED is reported when a connection is made.  TCP_SYN_SENT
> >  is never reported, so rule 'c' above is never effective.
> 
> This is disconcerting. Do we know why we're never being called back on
> TCP_SYN_SENT? To me that would be a bug that wants to be fixed in the
> TCP layer.

I had a bit of a look but I didn't spend enough time to really
understand what was going on.
It did occur to me to wonder if ->state_change can be guaranteed to
report every different state.  It isn't passed the new state as an arg
but rather has to pull it out of the sock structure.  So there would
need to be some sort of lock in place to ensure it doesn't change
before ->state_change has looked at it.  And I'm not sure that there
is.

So I'm not convinced that ->state_change is even meant to be a robust
mechanism to report every individual state transition.  Rather it lets
you know if something has happened recently, and you need to act based
on the current state, not on any particular transition.

That was my justification for moving away from depending on
->state_change.  We would need to talk to net-dev to see if the
justification is valid or flawed.

> 
> >  When the server closes the connection, TCP_CLOSE_WAIT and
> >  TCP_LAST_ACK *might* be reported, and TCP_CLOSE is always
> >  reported.  This rule 'b' above will sometimes be effective, but
> >  not reliably.
> 
> Right. CLOSE_WAIT and LAST_ACK are only supposed to be reported if the
> server closed the connection (see the state transition diagram
> http://www4.informatik.uni-erlangen.de/Projects/JX/Projects/TCP/tcpstate.html
> ). This is one case where we want to be careful about immediately
> reconnecting.

True.  But my point was that sometimes they are not reported, even
though the server has closed the connection and the state machine must
have gone through those states.
If I remember correctly:
   If the server closes the connection while the client is idle, we
   normally see those states.
   If the server closed the connection while the client is generating
   a steady stream of writes (via O_SYNC, so I can watch them easily),
   then we are more likely not to see those states.
so we cannot rely on them.

> 
> The other case is when we're in CLOSING, since that mean both the client
> and the server attempted to close the connection at the same time.
> 
> >  When the client closes the connection, it used to result in
> >  TCP_FIN_WAIT1, TCP_FIN_WAIT2, TCP_CLOSE.  However since commit
> >  f75e674 (SUNRPC: Fix the problem of EADDRNOTAVAIL syslog floods on
> >  reconnect) we don't see *any* events on client-close.  I think this
> >  is because xs_restore_old_callbacks is called to disconnect
> >  xs_tcp_state_change before the socket is closed.
> >  In any case, rule 'a' no longer applies.
> 
> What about in the case where we need to disconnect and reconnect in
> order to resend a NFSv4 request? That should normally result in
> xs_tcp_shutdown() being called, and thus rule (a) being invoked.

I wasn't aware of that case and didn't look into it.  Possibly it
still causes TCP_FIND_WAIT1 to be seen so the current code already
does the right thing(?).

> 
> > So all that is left are rule d, which successfully doubles the
> > timeout which is never rest, and rule e which initialises the timeout.
> > 
> > Even if the rules worked as expected, there would be a problem because
> > a successful connection does not reset the timeout, so a sequence
> > of events where the server closes the connection (e.g. during failover
> > testing) will cause longer and longer timeouts with no good reason.
> > 
> > This patch:
> > 
> >  - sets reestablish_timeout to 0 in xs_close thus effecting rule 'a'
> 
> That's OK, but I can't see that it is sufficient to replace (a). See
> above.

As I didn't remove the rule 'a' code, that may still be sufficient.
Or maybe it would be safest to set reestablish_timeout to 0 in xs_tcp_shutdown??
I admit that don't understand the fine distinction between the various
close/shutdown/destroy etc routines.

> 
> >  - sets it to 0 in xs_tcp_data_ready to ensure that a successful
> >    connection resets the timeout
> 
> That's equivalent to setting it to zero always on a change to
> TCP_ESTABLISHED, right?

Not quite.  When I brought this up a month or so ago you had anecdotal
evidence that some servers would accept a connection and then
immediate drop it, and suggested that we would want to have a timeout
before retrying such a connection.  I agree that we want to handle
that situation and it seemed easiest to treat a connection a
'successful' not when it is ESTABLISHED, but only when the first real
data arrives from the server.  Hence the setting in xs_tcp_data_ready.

> 
> >  - sets it to at least XS_TCP_INIT_REEST_TO after it is doubled,
> >    thus effecting rule c
> > 
> > I have not reimplemented rule b and the new version of rule c
> > seems sufficient.
> > 
> > I suspect other code in xs_tcp_data_ready needs to be revised as well.
> > For example I don't think connect_cookie is being incremented as often
> > as it should be.
> 
> Why should we be doing this in the data_ready callback instead of in the
> state_change callback?

I mis-typed.  That should have read "... other code in xs_tcp_state_change ...".
It appears that this callback does not robustly report every state,
but the code currently depends on it doing that for more than just
reestablish_timeout.  I am pessimistic about making it more robust, so
suggested the code might need to be revised.

NeilBrown
