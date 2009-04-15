From: "Hans-Peter Jansen" <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Subject: Re: klibc's nfsmount failure with 2.6.27.21, while 2.6.25.20 was fine
Date: Thu, 16 Apr 2009 00:48:46 +0200
Message-ID: <200904160048.46625.hpj@urpla.net>
References: <200904152117.41367.hpj@urpla.net> <889BAE90-0719-4560-B4D3-34376B0FFC4C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:51614 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648AbZDOWsy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 18:48:54 -0400
In-Reply-To: <889BAE90-0719-4560-B4D3-34376B0FFC4C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Mittwoch, 15. April 2009 schrieb Chuck Lever:
> On Apr 15, 2009, at 3:17 PM, Hans-Peter Jansen wrote:
> >
> > =C4hem, Chuck, may I ask you to look into the initial mail again. T=
he
> > failing
> > case is attached there. Here I've attached the good one. Since I
> > couldn't
> > locate any mount attempt in the dump, I've left a few more nfs
> > transactions.
>
> The client makes a PMAP_GETPORT request via TCP.  The server's rpcbin=
d
> drops the connection without replying after receiving the request.  I
> didn't see anything immediately wrong with the request, although
> wireshark didn't like it either.  I had to decode it by hand.

	8[

> Restarting rpcbind usually means you lose all your rpc service
> registrations until you restart those services, but it would be worth
> trying this: stop the server's rpcbind service, then run rpcbind in a
> terminal session with "-d" to see what it thinks the problem is when
> it drops the connection.
>
> Please attach a copy of your /etc/netconfig to reply.

Okay, but since it requires yet another portmap <-> rpcbind swap, pleas=
e=20
give me a few days to find a appropriate slot.

Pete
