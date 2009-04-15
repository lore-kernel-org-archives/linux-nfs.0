From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: klibc's nfsmount failure with 2.6.27.21, while 2.6.25.20 was
 fine
Date: Wed, 15 Apr 2009 08:38:34 -0400
Message-ID: <1239799114.5177.4.camel@heimdal.trondhjem.org>
References: <200904151250.49372.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Hans-Peter Jansen <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:38304 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286AbZDOMij (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2009 08:38:39 -0400
In-Reply-To: <200904151250.49372.hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-04-15 at 12:50 +0200, Hans-Peter Jansen wrote:
> Hi,
> 
> I suffer from a problem, where my diskless environment doesn't work anymore 
> after upgrading the server from openSUSE 11.0 (2.6.25.20) to openSUSE 11.1 
> (2.6.27.21).
> 
> The diskless environment gets set up with an customized initrd via pxelinux.
> The initrd uses klibc's nfsmount, and I've tried both protocols: udp and 
> tcp. It's not an iptables issue, since I can mount these directories from 
> other (fully booted) systems just fine. 
> 
> Using the debug version of klibc's nfsmount prints these messages:
> short read: 0 < 28
> Port for 100003/3[udp]: 0
> short read: 0 < 28
> Port for 100005/3[udp]: 0
> NFS params:
>   server = xxx.xx.xx.xx, path = "/roroot", version = 3, proto = udp,
>   mount_port = 627, nfs_port = 2049, flags = 00010282,
    ^^^^^^^^^^^^^^^^

>   rsize = 0, wsize = 0, timeo = 7, retrans = 3,
>   acreg (min,max) = (3,60), acdir (min,max) = (30,60),
>   soft = 0, intr = 1, posix = 0, nocto = 0, noac = 0
> 
> tcpdumping the communication shows, that for whatever reason, the client 
> sends the mount request from source port 798 to destination port 627, but 
> the server doesn't listen on 627:

The question is why is klibc specifying mount port = 627?

Trond

