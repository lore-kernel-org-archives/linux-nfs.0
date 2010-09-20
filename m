Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:62381 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755124Ab0ITOac convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 10:30:32 -0400
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100917222227.GA22144@sith.mimuw.edu.pl>
Date: Mon, 20 Sep 2010 10:29:08 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <DC671AB7-F3AF-4E70-B42E-4FF991D16E43@oracle.com>
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl> <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com> <20100917222227.GA22144@sith.mimuw.edu.pl>
To: =?utf-8?Q?Jan_R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 17, 2010, at 6:22 PM, Jan Rękorajski wrote:

> On Fri, 17 Sep 2010, Chuck Lever wrote:
> 
>> On Sep 17, 2010, at 3:04 PM, Jan Rękorajski wrote:
>> 
>>> On Fri, 17 Sep 2010, Chuck Lever wrote:
>>> 
>>>> 
>>>> On Sep 17, 2010, at 2:12 PM, Jan Rękorajski wrote:

[ ... snipped ... ]

> 
>>> And, besides, behavior for UDP and TCP sockets is currently inconsistent
>>> as init_transport ignores any failed UDP bind and correctly
>>> returns error for TCP.
>> 
>> That _may_ be intentional.  UDP semantics are "unreliable," so an
>> error may be expected even at bind time.  Who knows, it doesn't look
>> very well documented.
> 
> What about TCP then?  My patch was a by-product of trying to make '-h <IP>'
> also work for tcp sockets, so if we skip unbindable addresses for UDP,
> then will it be ok to do the same for TCP?

Interesting.  Now that I've actually looked at the documentation >> blush << rpcbind(8) explicitly says that "-h" is only for UDP.  I seem to recall that the legacy portmapper had a problem on multi-homed hosts where a request was received on one interface, and the reply was sent out another.

This is certainly a problem for datagram transports, but shouldn't be an issue for connection-oriented transports: the reply is always sent on the same connection as the request was received.

Can you say a little more about why do you need "-h" to work for connection-oriented sockets?

-- 
chuck[dot]lever[at]oracle[dot]com




