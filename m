Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:34245 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752192Ab0K2TuL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 14:50:11 -0500
Date: Mon, 29 Nov 2010 11:50:10 -0800
From: Simon Kirby <sim@hostway.ca>
To: Spelic <spelic@shiftmail.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users
Message-ID: <20101129195010.GA6423@hostway.ca>
References: <4CF3E3AD.2040502@shiftmail.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CF3E3AD.2040502@shiftmail.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 29, 2010 at 06:32:29PM +0100, Spelic wrote:

> Hello all
> we recently moved to nfsv4 from v3.
>
> I'm currently using idmapd and not kerberos.
>
> I noticed that now, with idmapd (and with idmapd is the only way I know  
> for configuring nfsv4 for now), users that are not known at server side  
> are squashed to nobody / nogroup  (65534 / 65534).
> And a chown by root from the client fails if the user is not known at  
> server side.
>
> That's a problem... now we need ldap everywhere...

Hello!

We also have a few environments using libnss-mysql currently on NFSv3,
and in this case, idmapping is pointless and just adds useless work,
since all of the clients already have exactly the same user mappings, by
design.  In fact, the NFS servers don't even know about the users for the
files they serve, and this is fine.  We'd have to set up libnss-mysql
on them for NFSv4 to work, all just so NFSv4 can have names on the wire.

This came up before; e.g. http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-09/msg01071.html
(I hijacked the thread about the credcache hash bucket size, which is
also an issue we ran into as well, but which also affects NFSv3.)

I tried to write the NFSv4 spec people, but didn't get any reply.  I can
see maybe why they would want to do this by default, but it's not like
people don't already have years of experience with how NFSv3 and earlier
worked, and I still think should at least be a way to request that
behaviour.

Simon-
