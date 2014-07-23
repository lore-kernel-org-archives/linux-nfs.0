Return-Path: linux-nfs-owner@vger.kernel.org
Received: from master.debian.org ([82.195.75.110]:34192 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbaGWBN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 21:13:56 -0400
Date: Wed, 23 Jul 2014 10:47:21 +1000
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: linux-nfs@vger.kernel.org
Cc: John Hughes <john@calva.com>, 755703@bugs.debian.org
Subject: Re: libtirpc1 0.2.4-1 causes rpc.gssd to crash on nfs4 sec=krb5 mount
Message-ID: <20140723004721.GA10142@master.debian.org>
References: <20140722144831.2069.50552.reportbug@celtic.calvaedi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20140722144831.2069.50552.reportbug@celtic.calvaedi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-07-22 16:48:31 +0200, John Hughes wrote:
> Package: libtirpc1
> Version: 0.2.3-2
> Severity: important
> 
> Dear Maintainer,
> 
>    * What led up to the situation?
> 
> Upgraded to libtirpc1_0.2.4-1_amd64.deb
> 
>    * What was the outcome of this action?
> 
> nfs4 sec=krb5 mounts stopped working, rpc.gssd segfaults in libgssapi_krb5
> 
> Jul 22 16:22:22 celtic kernel: [  285.086078] rpc.gssd[1611]: segfault at 6c ip 00007f24c8f9e72f sp 00007fff60b1df10 error 4 in libgssapi_krb5.so.2.2[7f24c8f8b000+45000
> 
> Downgrading to 0.2.3-2 "fixes" the problem.
> 
> Note that some non-Debian people seem to have the same problem, e.g.
> 
> http://forums.opensuse.org/showthread.php/494292-segmentation-fault-OpenSUSE-13-1-when-mounting-nfs4-with-kerberos
> 
> or:
> 
> https://bugs.archlinux.org/task/39217
> 
> -- System Information:
> Debian Release: jessie/sid
>   APT prefers unstable
>   APT policy: (500, 'unstable'), (1, 'experimental')
> Architecture: amd64 (x86_64)
> Foreign Architectures: i386
> 
> Kernel: Linux 3.14-1-amd64 (SMP w/4 CPU cores)
> Locale: LANG=en_US.UTF-8, LC_CTYPE=en_US.UTF-8 (charmap=UTF-8)
> Shell: /bin/sh linked to /bin/dash
> 
> Versions of packages libtirpc1 depends on:
> ii  libc6              2.19-7
> ii  libgssglue1        0.4-2
> ii  multiarch-support  2.19-7
> 
> libtirpc1 recommends no packages.
> 
> libtirpc1 suggests no packages.
> 
> -- no debconf information

https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=755703

How can I fix this bug in Debian?
