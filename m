Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:58709 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757425Ab2BMSu7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 13:50:59 -0500
Date: Mon, 13 Feb 2012 19:50:53 +0100
From: <whats_up@gmx.net>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
Message-ID: <20120213195053.0db35dd9@little-poseidon>
In-Reply-To: <jhaq04$pev$1@ultimate100.geggus.net>
References: <20120210154526.7b504146@little-poseidon>
	<4F35512A.9050500@steve-ss.com>
	<20120210184154.03fb6907@little-poseidon>
	<jhaq04$pev$1@ultimate100.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> > What's your suggestion to improve/secure my configuration?
> 
> I already told you that you need a backport of the latest version of
> libtirpc. The Version included in squeeze is broken.

You recommended to use backports. As you now say the lib is broken
things are different and I finally solved my problem.

For those who face similar issues I sum up my last steps:

- include squeeze-backports and upgrade nfs-common, nfs-kernel-server
  to version 1.2.4 and Linux kernel to 3.2
- replace portmap by rpcbind
- install version 0.2.2 of libtirpc from unstable (forced new libc6)
- remove pseudo root from /etc/exports
- use AES keys for Kerberos

Thanks to all for your helpful hints! :)

regards
  knut


------

# dpkg -l ...
ii  libnfsidmap2                                0.23-2                                      An nfs idmapping library
ii  nfs-common                                  1:1.2.4-1~bpo60+1                           NFS support files common to client and server
ii  nfs-kernel-server                           1:1.2.4-1~bpo60+1                           support for NFS kernel server

ii  libgssrpc4                                  1.8.3+dfsg-4squeeze5                        MIT Kerberos runtime libraries - GSS enabled ONCRPC
ii  librpcsecgss3                               0.19-2                                      allows secure rpc communication using the rpcsec_gss protocol
ii  libtirpc1                                   0.2.2-5                                     transport-independent RPC library
ii  rpcbind                                     0.2.0-4.1                                   converts RPC program numbers into universal addresses

ii  linux-image-3.2.0-0.bpo.1-686-pae           3.2.4-1~bpo60+1                             Linux 3.2 for modern PCs
