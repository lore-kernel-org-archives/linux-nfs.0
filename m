Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tuna.sandelman.ca ([209.87.252.184]:58549 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738Ab3JaOp6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 10:45:58 -0400
From: Michael Richardson <mcr@sandelman.ca>
To: linux-nfs@vger.kernel.org
cc: Shyam Kaushik <shyamnfs1@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Need help with NFS Server SUNRPC performance issue
In-Reply-To: <20131031141538.GA621@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com> <20131031141538.GA621@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Date: Thu, 31 Oct 2013 10:45:46 -0400
Message-ID: <29447.1383230746@obiwan.sandelman.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=


    >> I am chasing a NFS server performance issue on Ubuntu
    >> 3.8.13-030813-generic kernel. We setup 32 NFSD threads on our NFS
    >> server.

I have been also trying to figure out NFS performance issues at my home
office.  Server is ubuntu precise (3.2.0-55, old, true) kernel, and clients
are mostly a mix of Debian versions (mostly virtualized XEN).
GbE over a VLAN is setup just for storage, and mostly IPv6 connections.

J. Bruce Fields <bfields@fieldses.org> wrote:
    > Would you be willing to test an upstream kernel and/or some patches?
    > Sounds like you're using only NFSv4?

I'm also willing to; my preference would be to build a generic 3.10 or 3.11
kernel with NFS as a module, and then update the NFS code, but I
haven't gotten around to scheduling some time to reboot a bunch.

What I observe is huge TCP send queues on the server and what appears to be
head of queue blocking on the client.  This looks like a client issue to me,
and for at least one client (my mpd/shoutcast server), I'm happy to reboot
it regularly... I notice the NFS delays because the music stops :-)

There are some potential instabilities in frequency of IPv6 Router
Advertisements due to a bug in the CeroWRT, which initially I was blaming,
but I'm no longer convinced, since it happens over IPv4 on the storage VLAN
too.

Shyam, please share with me your testing strategy.

--
]               Never tell me the odds!                 | ipv6 mesh networks [
]   Michael Richardson, Sandelman Software Works        | network architect  [
]     mcr@sandelman.ca  http://www.sandelman.ca/        |   ruby on rails    [






--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQCVAwUBUnJtF4qHRg3pndX9AQIHBwQA4+FPBZq0By6SiFfsZ9CnFKcvt0DJep08
tbSlkSw8cRQxngvQAUBS42Am1DhyBWjegJE9/gBDkY9FVWWpa2hHvh5/IfdKfBTN
l33hZsDU+7nZ6oXvXU1b9Titymk+tYRGqN38PIalBANJ+S6tN7Kd9OyD1eR/ey6D
cM9tKFny1PY=
=qnAi
-----END PGP SIGNATURE-----
--=-=-=--
