Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:35566 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755967Ab0I0MYd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 08:24:33 -0400
Subject: Re: when will we be able to use LIPKEY on NFS4 on Linux?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Zhang Weiwu <zhangweiwu@realss.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4CA05749.8070502@realss.com>
References: <4CA05749.8070502@realss.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 27 Sep 2010 08:24:26 -0400
Message-ID: <1285590266.19362.37.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-09-27 at 16:35 +0800, Zhang Weiwu wrote:
> Hello.
> 
> Quote from 2006 article:
> http://www.ibm.com/developerworks/systems/library/es-nfs-security/index.html#N100AF
> 
>     In /a few years/, NFS Version 4 implementations will start claiming
>     support for the public key-based security mechanism (SPKM and LIPKEY).
> 
> 
> My question:
> 
>    1. Is LIPKEY already implemented in some NFS4 implementation?
>       Particularly, I am interested using it on Debian Linux.
>    2. I could not manage to find a how-to on using LIPKEY, e.g. where to
>       store the public key and certificates, where to configure
>       username/password for client authentication. Is there one existing?
> 
> Thanks in advance!

We're likely to drop the requirement that SPKM3/LIPKEY be a mandatory
security mechanism for NFSv4 in the revised RFC3530 (a.k.a. RFC3530bis)
that is being drafted.

The reason is that the SPKM3 mechanism (on which LIPKEY relies) appears
to contain inherent security flaws that are difficult to fix. The IETF
security group have therefore pretty much killed it as an option.
Other alternatives to SPKM3 are being discussed, but I'm not aware of
anything that replaces LIPKEY.

Cheers
  Trond

