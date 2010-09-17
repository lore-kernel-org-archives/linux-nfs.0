Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27453 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab0IQTaO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 15:30:14 -0400
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100917190413.GB21111@sith.mimuw.edu.pl>
Date: Fri, 17 Sep 2010 15:27:46 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com>
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl>
To: =?utf-8?Q?Jan_R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 17, 2010, at 3:04 PM, Jan Rękorajski wrote:

> On Fri, 17 Sep 2010, Chuck Lever wrote:
> 
>> 
>> On Sep 17, 2010, at 2:12 PM, Jan Rękorajski wrote:
>> 
>>> Hi,
>>> rpcbind currently silently ignores any errors that occur during
>>> init_transport, it also happily continues if bind(2) fails for
>>> UDP socket - it's enough if just one UDP socket is bound.
>>> 
>>> This patch makes rpcbind fail if there are problems with
>>> setting up any transport, so we don't end up with
>>> semi/non functional running daemon.
>> 
>> Can you give us some details about why transport initialization was
>> failing?  There are probably some cases where we do want rpcbind to
>> soldier on in spite of such troubles.
> 
> An obvious example is when address given to '-h' option isn't there,
> or daemon can't bind to it for some reason.
> Bind fails, but rpcbind is running as if nothing happened.

The usual practice is to allow an RPC daemon to run if at least one transport can be started.  That is a little more robust than failing if any one transport can't be started.

If such a failure is completely silent, then it's probably reasonable to post a notice about this in the log.  But we generally like things to work automatically, if at all possible.

If rpcbind couldn't use _any_ of the specified bind addresses, I guess that is when it should fail to start.  A host's networking configuration can be quite variable, especially with DHCP-configured interfaces, so these daemons have to be somewhat flexible.

> And, besides, behavior for UDP and TCP sockets is currently inconsistent
> as init_transport ignores any failed UDP bind and correctly
> returns error for TCP.

That _may_ be intentional.  UDP semantics are "unreliable," so an error may be expected even at bind time.  Who knows, it doesn't look very well documented.

> The only legitimate reason for ignoring errors I may see here is when
> IPv6 is configured in /etc/netconfig but it's not set up on net
> interfaces, but as such case is administrative mistake it should be
> fixed by the admin, not the daemon.

Not necessarily.  ipv6.ko can be blacklisted.  Should the administrator also remember to adjust /etc/netconfig in that case, or should the rpc-related daemons simply adjust automatically?

-- 
chuck[dot]lever[at]oracle[dot]com




