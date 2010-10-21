Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60181 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab0JUTr2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 15:47:28 -0400
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3
 mounts.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Neil Brown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20101021154012.48f92cfc@corrin.poochiereds.net>
References: <20101020181701.232dbeea@notabene>
	 <20101020135525.22977d8d@tlielax.poochiereds.net>
	 <20101020151657.42bc53f7@tlielax.poochiereds.net>
	 <20101021074028.44bca336@notabene>
	 <20101020204532.2019eb93@corrin.poochiereds.net>
	 <20101021142518.3934ae17@notabene>
	 <1287669939.3645.12.camel@heimdal.trondhjem.org>
	 <5CF8C718-2D02-481E-9200-8CAA724D9C8C@oracle.com>
	 <1287672124.3645.19.camel@heimdal.trondhjem.org>
	 <20101021154012.48f92cfc@corrin.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Oct 2010 15:47:24 -0400
Message-ID: <1287690444.9144.88.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-10-21 at 15:40 -0400, Jeff Layton wrote:
> On Thu, 21 Oct 2010 10:42:04 -0400
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Thu, 2010-10-21 at 10:31 -0400, Chuck Lever wrote:
> > > On Oct 21, 2010, at 10:05 AM, Trond Myklebust wrote:
> > > > It seems to me that the problem is basically that RPC_IS_SOFTCONN is
> > > > poorly defined. IMO, the definition should really be that
> > > > 'RPC_IS_SOFTCONN' tasks MUST exit with an error if they ever have to run
> > > > call_bind or a call_connect more than once (i.e. if they ever have to
> > > > loop back).
> > > 
> > > I think you are suggesting that we define the places where RPC_IS_SOFTCONN should be tested as exactly those places that might want to restart the RPC call via rpc_force_rebind, tk_action = call_refresh, and so on.  Yes?
> > 
> > Yes.
> > 
> > > > With that in mind, I really don't see why the RPC_IS_SOFTCONN case is
> > > > being handled in call_transmit_status() instead of in call_status().
> > > 
> > > I tried it in call_status(), but it didn't work as expected.  My notes aren't specific about the problem.  One thing is for sure, there seems to be some redundant error handling logic in both of those states.  Unraveling it might be more than Neil bargained for, but would help "future generations."
> > 
> > call_transmit_status() is there basically in order to call
> > xprt_end_transmit() in the cases where we want to free up the socket
> > write lock (and then possibly sleep).
> > 
> > Actual state error handling is supposed occur in call_status().
> > 
> 
> This is terribly confusing. So the connect handling is done in
> call_transmit?

No. Connection-related _error conditions_ that result from trying to
send stuff through a socket that is not connected, are handled in
call_status(). Usually, by sending the process back to call_connect().

> It seems like it would make more sense to have the connect handling
> mostly done in call_connect and call_connect_status, and only allow the
> tasks to proceed to the call_transmit phase after the connect has
> succeeded.

That is the case. However sockets can and do get closed by the _server_
in unpredictable ways. This is what may need to be handled after the
task has passed the call_connect state.

   Trond

