Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:4343 "EHLO
	mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754045Ab0EPNhq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 09:37:46 -0400
Message-ID: <4BEFF525.9090400@inria.fr>
Date: Sun, 16 May 2010 15:37:41 +0200
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
To: linux-nfs@vger.kernel.org
Subject: Re: Disable NFS client cache.
References: <20100516025055.GC3872@gmail.com>
In-Reply-To: <20100516025055.GC3872@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Le 16/05/2010 04:50, jupiter.hce@gmail.com a écrit :
> Hi,
> 
> Could you please advice how to disable NFS client cache in mount
> command?
> 
> I have an application to use NFS over FUSE, if I keep typing "ls" in
> the same directory, the client NFS only sent GETATT, no more READDIR,
> all directory contents displayed on screen came from NFS cache. That
> caused many problems and I'd like to disable NFS client cache. But it
> did not work when I add "-o noac" option to mount. Also I don't want
> NFS GETATT retransmission during file copy. Appreciate your advice and
> sample examples to mount.
If you're speaking of the new fs-cache feature of 2.6.30 kernel, and not
of builtin caching of NFS (the one managed by -o noac option), the only
way to disable it AFAIK is to prevent fs-cache module loading in
modutils configuration, using either of:
- blacklist fs-cache
- install fs-cache /bin/true
- alias fs-cache null

-- 
BOFH excuse #302:

microelectronic Riemannian curved-space fault in write-only file system
