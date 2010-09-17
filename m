Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sith.mimuw.edu.pl ([193.0.96.4]:49386 "EHLO sith.mimuw.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755366Ab0IQTEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 15:04:14 -0400
Date: Fri, 17 Sep 2010 21:04:13 +0200
From: Jan =?utf-8?Q?R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Message-ID: <20100917190413.GB21111@sith.mimuw.edu.pl>
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 17 Sep 2010, Chuck Lever wrote:

> 
> On Sep 17, 2010, at 2:12 PM, Jan Rękorajski wrote:
> 
> > Hi,
> > rpcbind currently silently ignores any errors that occur during
> > init_transport, it also happily continues if bind(2) fails for
> > UDP socket - it's enough if just one UDP socket is bound.
> > 
> > This patch makes rpcbind fail if there are problems with
> > setting up any transport, so we don't end up with
> > semi/non functional running daemon.
> 
> Can you give us some details about why transport initialization was
> failing?  There are probably some cases where we do want rpcbind to
> soldier on in spite of such troubles.

An obvious example is when address given to '-h' option isn't there,
or daemon can't bind to it for some reason.
Bind fails, but rpcbind is running as if nothing happened.
And, besides, behavior for UDP and TCP sockets is curently inconsistent
as init_transport ignores any failed UDP bind and correctly
returns error for TCP.

The only legitimate reason for ignoring errors I may see here is when
IPv6 is configured in /etc/netconfig but it's not set up on net
interfaces, but as such case is administrative mistake it should be
fixed by the admin, not the daemon.

-- 
Jan Rękorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio
