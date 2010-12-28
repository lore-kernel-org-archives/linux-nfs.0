Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:42696 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752465Ab0L1AMy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Dec 2010 19:12:54 -0500
Subject: Re: NFS and firewalls
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Hanson <jhansonxi@gmail.com>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
In-Reply-To: <AANLkTi=67a4C7Wx1zhoB-gAV_uXyzizenLmaEnbruy9i@mail.gmail.com>
References: <AANLkTi=67a4C7Wx1zhoB-gAV_uXyzizenLmaEnbruy9i@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 27 Dec 2010 19:12:50 -0500
Message-ID: <1293495170.9774.7.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-12-27 at 18:32 -0500, Jeff Hanson wrote:
> The random port usage of NFS makes it difficult to use with NAT/firewalls.
> 
> The common workaround is to configure statd, mountd, lockd, and quotad
> to static ports. Since there isn't any standard (IANA registered) port
> assignments this breaks on many networks that use dynamic or different
> static ports.
> 
> This makes it difficult to use the "standard" network file sharing
> protocol with mobile devices which often use firewalls.
> 
> Saned, Samba (netbios), and FTP all have conntrack modules to handle
> dynamic port usage.  Has there been any attempt to write one for NFS?
> 
> I filed a bug with Ubuntu about it (#688446), mostly for psychological
> benefit as it's probably something they're not going to get involved
> with.

Neither am I.

NFSv4.1 fully solves this problem. All connections to the server are
initiated by the client, including for callback paths. The only port
that needs to be accessible on the server side is port 2049.

NFSv4 also solves the problem, with the one caveat that callbacks won't
work behind a NAT (which basically means you won't get delegations).

NFSv3 is the only protocol that actually has the problem you describe
above. We're working to deprecate it...

Cheers
  Trond

