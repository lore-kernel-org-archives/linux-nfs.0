Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:50586 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751503AbaEAQeU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 12:34:20 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Craig Yoshioka'" <craigyk@me.com>, <linux-nfs@vger.kernel.org>
References: <2541339C-AF61-4ED7-8F50-E4B3CA2C924F@me.com>
In-Reply-To: <2541339C-AF61-4ED7-8F50-E4B3CA2C924F@me.com>
Subject: RE: idmap problems with chown as root
Date: Thu, 1 May 2014 09:34:18 -0700
Message-ID: <03f201cf655b$33390d40$99ab27c0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a difference between your working and non-working idmapd.conf:

The working does not have:

[Translation]
Method = nsswitch

That may be what's catching you up.

Frank

> This is a followup to a previous post I made.
> 
> With Frank Filz's helpful suggestions I was able to gather better data.
> 
> problem: when using chown as root on a nfs4 filesystem on newer linux
> releases file owners get sets to nobody.
>          the user type doesn't seem to matter (/etc/passwd, LDAP, Samba4)
> 
> setup: Server is FreeBSD 10 system with NFSv4 share.
>        Server and clients are all configured with the same idmap domain
>        Network users have consistent uid/gid on server and clients
>        clients with older linux releases work OK (Ubuntu 12.04, CentOS 5
and 6)
>        clients with newer linux releases do not work ( Fedora 20, Ubuntu
14.04,
> Mint 16 )
> 
> clues:
> 
> 1. working and non-working systems get to the same fchownat() system call
> with the same arguments (via strace).
> 
> example (identical on working and non-working client):
> ...
> fchownat(AT_FDCWD, "/mnt/test", 11111, 4294967295, 0) = 0
> close(1)                                = 0
> close(2)                                = 0
> close(4)                                = 0
> exit_group(0)                           = ?
> +++ exited with 0 +++
> 
> 2. working system sends NFSV4 SETATTR request with owner set to:
> matlab@nimgs.com and non-working as 11111 (via wireshark)


