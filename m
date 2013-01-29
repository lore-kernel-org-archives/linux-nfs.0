Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753475Ab3A2Tr3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2013 14:47:29 -0500
Date: Tue, 29 Jan 2013 14:47:29 -0500
To: Thierry Moreau <thierry.moreau@connotech.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel message when no support for NFSv4 compiled into it
Message-ID: <20130129194729.GC4209@fieldses.org>
References: <510812C0.1070307@connotech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <510812C0.1070307@connotech.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29, 2013 at 01:19:44PM -0500, Thierry Moreau wrote:
> Dear nfs developers,
> 
> I just SOLVED my operational problem. Maybe the symptom vs solution
> is of interest to you.
> 
> Kernel 3.5.4, nfs-utils 1.2.7
> 
>     ./configure --prefix=/usr \
>                 --mandir=/usr/man \
>                 --sysconfdir=/etc \
>                 --with-statedir=/var/lib/nfs \
>                 --disable-gss \
>                 --with-tcp-wrappers \
>                 --enable-libmount-mount
> 
> starting script:
> 
>         /sbin/rpcbind -h 192.168.1.17
>         /bin/mount -t nfsd nfsd $NFSD
>         /bin/mount -t rpc_pipefs rpc_pipefs $PIPEFS
>         /usr/sbin/rpc.idmapd
>         /usr/sbin/exportfs -a
>         /usr/sbin/rpc.mountd
>         /usr/sbin/rpc.statd --no-notify
>         /usr/sbin/rpc.nfsd --syslog 8A <==== this is where the
> kernel would report an error
>         /usr/sbin/sm-notify
> 
> kernel configuration changes
> 
> bash-4.2# diff config_02 config_04
> d2437c2447,2448
> < # CONFIG_NFSD_V4 is not set
> ---
> > CONFIG_NFSD_V4=y
> > # CONFIG_NFSD_FAULT_INJECTION is not set
> 2441a2453
> > CONFIG_SUNRPC_GSS=m
> d2622c2639,2641
> < # CONFIG_KEYS is not set
> ---
> > CONFIG_KEYS=y
> > CONFIG_ENCRYPTED_KEYS=m
> > CONFIG_KEYS_DEBUG_PROC_KEYS=y
> 2625a2645
> > # CONFIG_DEFAULT_SECURITY_SELINUX is not set
> 2646a2667
> > CONFIG_CRYPTO_RNG=m
> 2700c2721
> < # CONFIG_CRYPTO_SHA256 is not set
> ---
> > CONFIG_CRYPTO_SHA256=m
> 
> With config_02 kernel, nfsd would not work (no big deal so far). But
> it did work fine prior to a controlled system reboot where prior
> live system had experienced extensive playing with nfsd installation
> (not much help for you since I can not tell what made it work).
> 
> What may be of interest to you is that with config_02 kernel, it is
> the *kernel* that reports an error message on the system console,
> right upon nfsd startup. It is only by (painful) trial and error
> that the cause for the kernel message was found. The kernel message
> message occurred even with the --disable-nfsv4/nfsv41 configure
> options.
> 
> I don't have the exact kernel messages at hand (circa memory mapping
> then circa NULL pointer dereferencing during the trial-and-error
> chase).
> 
> I might be able to provide additional information if you ask
> politely. Maybe I owe it to this great free software contribution
> anyway.

Most useful would probably be the exact kernel messages if you have a
way to find them or regenerate them again.

--b.
