Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sith.mimuw.edu.pl ([193.0.96.4]:47764 "EHLO sith.mimuw.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855Ab0ITPb6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 11:31:58 -0400
Date: Mon, 20 Sep 2010 17:31:57 +0200
From: Jan =?utf-8?Q?R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Message-ID: <20100920153157.GA20589@sith.mimuw.edu.pl>
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl> <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com> <20100917222227.GA22144@sith.mimuw.edu.pl> <DC671AB7-F3AF-4E70-B42E-4FF991D16E43@oracle.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <DC671AB7-F3AF-4E70-B42E-4FF991D16E43@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 20 Sep 2010, Chuck Lever wrote:

> 
> On Sep 17, 2010, at 6:22 PM, Jan Rękorajski wrote:
> 
[snip]
> > 
> > What about TCP then?  My patch was a by-product of trying to make '-h <IP>'
> > also work for tcp sockets, so if we skip unbindable addresses for UDP,
> > then will it be ok to do the same for TCP?
> 
> Interesting.  Now that I've actually looked at the documentation >>
> blush << rpcbind(8) explicitly says that "-h" is only for UDP.  I seem
> to recall that the legacy portmapper had a problem on multi-homed
> hosts where a request was received on one interface, and the reply was
> sent out another.
> 
> This is certainly a problem for datagram transports, but shouldn't be
> an issue for connection-oriented transports: the reply is always sent
> on the same connection as the request was received.
> 
> Can you say a little more about why do you need "-h" to work for
> connection-oriented sockets?

I have a multihomed nfs server, and I don't want the portmapper to even
listen on an outside interface. Second thing is a host for vservers
(http://linux-vserver.org), I need to run portmapper in guests but
rpcbind listening on INADDR_ANY is not letting me. And finally it's good
to be consistent, it's strange to me that someone may want to limit only
the UDP part of portmapper (modulo network issues you mentioned).

-- 
Jan Rękorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio
