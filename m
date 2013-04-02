Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15435 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761033Ab3DBRD2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 13:03:28 -0400
Subject: Re: [PATCH] Avoid PTR lookups when possible
From: Simo Sorce <simo@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
In-Reply-To: <20130402164631.GA23840@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
	 <20130402150049.GA526@umich.edu>
	 <1364919975.2660.1255.camel@willson.li.ssimo.org>
	 <20130402164631.GA23840@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 13:03:23 -0400
Message-ID: <1364922203.2660.1265.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 12:46 -0400, Jim Rees wrote:
> Simo Sorce wrote:
> 
>   It's a MITM setting.
>   
>   Suppose you have 2 servers:
>   
>   secure.server.name where you store confidential documents
>   public.server.name where everyone have access for reading (and you can
>   write)
>   
>   If you mount -t nfs secure.server.name/export and rely on PTR records
>   and an attacker can spoof your PTR request to return public.server.name
>   you will end up acquiring a ticket for public.server.name from the KDC.
>   Then the attacker will redirect your mount to public.server.name all the
>   while you think you have mounted secure.server.name
>   
>   Now anything you copy there goes to a public server instead of your
>   secure server.
>   
>   Now imagine your secure server is a backup server which gets mounted by
>   a cron job every night for backups of sensitive information.
> 
> I guess what you're saying is that the client might not know the full name
> of the secure server, and could be tricked into thinking it's
> public.server.name. That's not what I'd call mitm; kerberos is pretty much
> immune to mitm. It's not really a dns mitm either, it's a spoofed reply.

No this is not what I am saying.
The client uses the fully qualified name at the mount command but due to
the use of a PTR lookup it is fooled into acquiring a ticket for the
wrong server which will then happily allow you to connect.

Currently:
The mount command tells the kernel both the server name
'secure.server.name' and it's IP address 1.2.3.4 however rpc.gssd
currently completely ignored the server name passed in by the mount
command (see the 'dummy' variable) and instead uses the ip address to do
a reverse lookup.

PTR lookup of 1.2.3.4 --- MITM ---> public.server.com

Then it uses the retrieved name (public..) to construct the GSSAPI name
it wants to connect to, the result is that the name
nfs@public.server.name is constructed instead of the requested
nfs@secure.server.com that should be requested.

So the client does ask for the right server but can be easily tricked
into connecting to another one.

Kerberos itself *is* correctly identifying the server, it's rpc.gssd
that opened it'sself to being fooled before involving Kerberos.

> I would be in favor of requiring kerberized nfs clients to know the full
> name of the server they're trying to connect to.

Yes, this would be my preference too.

>  Kerberized nfs clients
> should not be relying on dns for any part of their security. But I guess we
> haven't been doing that, and to make that a requirement now would be a
> compatibility problem.

Yes which is why I am adding a switch, I strongly suggest distribution
to use -N on in newer releases and allow -N off only for existing setups
for compatibility reasons.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

