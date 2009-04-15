From: "Hans-Peter Jansen" <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Subject: Re: klibc's nfsmount failure with 2.6.27.21, while 2.6.25.20 was fine
Date: Wed, 15 Apr 2009 15:48:11 +0200
Message-ID: <200904151548.12291.hpj@urpla.net>
References: <200904151250.49372.hpj@urpla.net> <1239799114.5177.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:57331 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbZDONsc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 09:48:32 -0400
In-Reply-To: <1239799114.5177.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Mittwoch, 15. April 2009 schrieb Trond Myklebust:
> On Wed, 2009-04-15 at 12:50 +0200, Hans-Peter Jansen wrote:
> > Hi,
> >
> > I suffer from a problem, where my diskless environment doesn't work
> > anymore after upgrading the server from openSUSE 11.0 (2.6.25.20) to
> > openSUSE 11.1 (2.6.27.21).
> >
> > The diskless environment gets set up with an customized initrd via
> > pxelinux. The initrd uses klibc's nfsmount, and I've tried both
> > protocols: udp and tcp. It's not an iptables issue, since I can mount
> > these directories from other (fully booted) systems just fine.
> >
> > Using the debug version of klibc's nfsmount prints these messages:
> > short read: 0 < 28
> > Port for 100003/3[udp]: 0
> > short read: 0 < 28
> > Port for 100005/3[udp]: 0
> > NFS params:
> >   server = xxx.xx.xx.xx, path = "/roroot", version = 3, proto = udp,
> >   mount_port = 627, nfs_port = 2049, flags = 00010282,
>
>     ^^^^^^^^^^^^^^^^
>
> >   rsize = 0, wsize = 0, timeo = 7, retrans = 3,
> >   acreg (min,max) = (3,60), acdir (min,max) = (30,60),
> >   soft = 0, intr = 1, posix = 0, nocto = 0, noac = 0
> >
> > tcpdumping the communication shows, that for whatever reason, the
> > client sends the mount request from source port 798 to destination port
> > 627, but the server doesn't listen on 627:
>
> The question is why is klibc specifying mount port = 627?

Well, this is exactly my problem. That's the mount port, but this one cannot 
be set to a manual value, thus the rpc stuff infront of it must have gone 
wrong.

[Update]
Issue solved. It was that silly rpcbind package (0.1.6+git20080930-5.2), 
that has gone wrong. Replacing it with portmap (6.0+git20070716-31.37) did 
it. Looks like this deserves a new bugzilla record.

Sorry for the churn and thanks for your care, Trond.

Pete
