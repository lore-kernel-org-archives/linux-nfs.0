Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sith.mimuw.edu.pl ([193.0.96.4]:18256 "EHLO sith.mimuw.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753912Ab0IQWW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 18:22:29 -0400
Date: Sat, 18 Sep 2010 00:22:27 +0200
From: Jan =?utf-8?Q?R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Message-ID: <20100917222227.GA22144@sith.mimuw.edu.pl>
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl> <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 17 Sep 2010, Chuck Lever wrote:

> On Sep 17, 2010, at 3:04 PM, Jan Rękorajski wrote:
> 
> > On Fri, 17 Sep 2010, Chuck Lever wrote:
> > 
> >> 
> >> On Sep 17, 2010, at 2:12 PM, Jan Rękorajski wrote:
> >> 
> >>> Hi,
> >>> rpcbind currently silently ignores any errors that occur during
> >>> init_transport, it also happily continues if bind(2) fails for
> >>> UDP socket - it's enough if just one UDP socket is bound.
> >>> 
> >>> This patch makes rpcbind fail if there are problems with
> >>> setting up any transport, so we don't end up with
> >>> semi/non functional running daemon.
> >> 
> >> Can you give us some details about why transport initialization was
> >> failing?  There are probably some cases where we do want rpcbind to
> >> soldier on in spite of such troubles.
> > 
> > An obvious example is when address given to '-h' option isn't there,
> > or daemon can't bind to it for some reason.
> > Bind fails, but rpcbind is running as if nothing happened.
> 
> The usual practice is to allow an RPC daemon to run if at least one
> transport can be started.  That is a little more robust than failing
> if any one transport can't be started.
> 
> If such a failure is completely silent, then it's probably reasonable
> to post a notice about this in the log.  But we generally like things
> to work automatically, if at all possible.

It does syslog all problems with creating sockets.

> If rpcbind couldn't use _any_ of the specified bind addresses, I guess
> that is when it should fail to start.  A host's networking
> configuration can be quite variable, especially with DHCP-configured
> interfaces, so these daemons have to be somewhat flexible.

Ok, I can live with that, it just seemed bad to me that those errors got
ignored.

> > And, besides, behavior for UDP and TCP sockets is currently inconsistent
> > as init_transport ignores any failed UDP bind and correctly
> > returns error for TCP.
> 
> That _may_ be intentional.  UDP semantics are "unreliable," so an
> error may be expected even at bind time.  Who knows, it doesn't look
> very well documented.

What about TCP then?  My patch was a by-product of trying to make '-h <IP>'
also work for tcp sockets, so if we skip unbindable addresses for UDP,
then will it be ok to do the same for TCP?

-- 
Jan Rękorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio
