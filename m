Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758934Ab3DBQ0T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 12:26:19 -0400
Subject: Re: [PATCH] Avoid PTR lookups when possible
From: Simo Sorce <simo@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
In-Reply-To: <20130402150049.GA526@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
	 <20130402150049.GA526@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 12:26:15 -0400
Message-ID: <1364919975.2660.1255.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 11:00 -0400, Jim Rees wrote:
> Simo Sorce wrote:
> 
>   The attached patch adds a new command line switch to rpc.gssd to avoid
>   PTR resolution when possible.
>   
>   The current code *depends* on PTR resolution for GSSAPI authentication
>   and this is *bad*.
>   It imposes an annoying, and unnecessary, constraint on the correctness
>   of DNS resolution, which prevents mounts from working in networks where
>   the PTR record cannot be easily controlled (for example networks where
>   the forward name is reasonable while the PTR is set to some artificial
>   name based on the IP address or so that is not the canonical name or
>   where no PTR exist at all).
>   
>   Depending on PTR resolution for GSSAPI is also very bad practice because
>   it opens up DNS spoofing attacks where an attacker can try to redirect a
>   user to the wrong server fooling mutual authentication, and induce a
>   user to trust improper data or disclose (by copying on the impostor
>   server) data that should be confidential.
> 
> What happens if it's a partially qualified domain name?

you use the "-N off" switch and rely on reverse resolution I guess.
(about to send patch that fixes -N as Jeff asked).

> Wouldn't it be better to use something like inet_pton?

I'll look.

> I agree that insisting on correct PTR records is a bad idea, but I don't
> understand your threat model. It shouldn't be possible for an attacker to do
> anything bad by redirecting the client to a spoof server. If it is possible,
> we've got bigger problems. How do you think that would work exactly?

It's a MITM setting.

Suppose you have 2 servers:

secure.server.name where you store confidential documents
public.server.name where everyone have access for reading (and you can
write)

If you mount -t nfs secure.server.name/export and rely on PTR records
and an attacker can spoof your PTR request to return public.server.name
you will end up acquiring a ticket for public.server.name from the KDC.
Then the attacker will redirect your mount to public.server.name all the
while you think you have mounted secure.server.name

Now anything you copy there goes to a public server instead of your
secure server.

Now imagine your secure server is a backup server which gets mounted by
a cron job every night for backups of sensitive information.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

