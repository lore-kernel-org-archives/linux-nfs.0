Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36355 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755810Ab0IQRoo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 13:44:44 -0400
Date: Fri, 17 Sep 2010 13:43:28 -0400
To: George Mamalakis <mamalos@eng.auth.gr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv3 gssapi client?
Message-ID: <20100917174328.GC25515@fieldses.org>
References: <4C938F3B.4030604@eng.auth.gr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C938F3B.4030604@eng.auth.gr>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 17, 2010 at 06:54:35PM +0300, George Mamalakis wrote:
>   Hi all,
> 
> I have a FreeBSD nfsv3 server that exports a filesystem with
> sec=krb5. Mounting the share with sec=krb5 under a fbsd client works
> fine. I now try to mount it under linux (archlinux, upgraded today)
> using nfs-utils. Heimdal is configured on the linux-box, kinit -k
> linuxclient works fine. I am also able to kinit to my user
> principals from it. When I try to mount the nvsv3 sec=krb5 share, I
> get the following error:
> 
> # mount -t nfs -o sec=krb5 fbsdserver:/exports /mnt
> 

Was there supposed to be some error output there?  Or did the mount just
hang?

> # tail /var/log/messages
> Sep 17 16:05:31 linuxclient rpc.statd[27683]: Version 1.2.2 starting
> Sep 17 16:05:31 linuxclient sm-notify[27684]: Version 1.2.2 starting
> Sep 17 16:05:31 linuxclient sm-notify[27684]: Already notifying
> clients; Exiting!
> Sep 17 16:05:31 linuxclient rpc.statd[27683]: Running as root.
> chown /var/lib/nfs to choose different user
> Sep 17 16:05:31 linuxclient sm-notify[27687]: Version 1.2.2 starting
> Sep 17 16:05:31 linuxclient sm-notify[27687]: Already notifying
> clients; Exiting!
> Sep 17 16:05:53 linuxclient kernel: svc: failed to register lockdv1
> RPC service (errno 111).
> Sep 17 16:05:53 linuxclient kernel: lockd_up: makesock failed, error=-111
> Sep 17 16:05:54 linuxclient kernel: svc: failed to register lockdv1
> RPC service (errno 111).
> Sep 17 16:05:57 linuxclient kernel: svc: failed to register lockdv1
> RPC service (errno 111).
> Sep 17 16:06:01 linuxclient kernel: svc: failed to register lockdv1
> RPC service (errno 111).

111 is ECONNREFUSED.  I'm not sure why that's failing.  (Should failure
to register lockd fail the whole mount?  I thought it would at worst
result in ENOLCK on lock requests?) Do you get better results if you
mount with nolock?

> and it keeps on like this.
> 
> My nfs-common.conf reads:
> 
> [root@linuxclient ~]# cat /etc/conf.d/nfs-common.conf
> # Parameters to be passed to nfs-common (nfs clients & server) init script.
> #
> 
> # If you do not set values for the NEED_ options, they will be attempted
> # autodetected; this should be sufficient for most people. Valid
> alternatives
> # for the NEED_ options are "yes" and "no".
> 
> # Do you want to start the statd daemon? It is not needed for NFSv4.
> NEED_STATD=""
> 
> # Options to pass to rpc.statd.
> # See rpc.statd(8) for more details.
> # N.B. statd normally runs on both client and server, and run-time
> # options should be specified accordingly.
> # STATD_OPTS="-p 32765 -o 32766"
> STATD_OPTS=""
> 
> # Options to pass to sm-notify
> # e.g. SMNOTIFY_OPTS="-p 32764"
> SMNOTIFY_OPTS=""
> 
> # Do you want to start the idmapd daemon? It is only needed for NFSv4.
> NEED_IDMAPD=""
> 
> # Options to pass to rpc.idmapd.
> # See rpc.idmapd(8) for more details.
> IDMAPD_OPTS="-vvv"
> 
> # Do you want to start the gssd daemon? It is required for Kerberos mounts.
> NEED_GSSD="yes"
> 
> # Options to pass to rpc.gssd.
> # See rpc.gssd(8) for more details.
> GSSD_OPTS="-vvv"
> #RPCGSSDOPTS="-vvv"
> # Where to mount rpc_pipefs filesystem; the default is
> "/var/lib/nfs/rpc_pipefs".
> PIPEFS_MOUNTPOINT=""
> 
> # Options used to mount rpc_pipefs filesystem; the default is "defaults".
> PIPEFS_MOUNTOPTS=""
> 
> my rpc processes are:
> [root@linuxclient ~]# ps axuww  | grep -i rpc
> root      1228  0.0  0.0      0     0 ?        S    14:47   0:00 [rpciod/0]
> root     27670  0.0  0.0   6232   908 ?        Ss   16:05   0:00
> /usr/bin/rpcbind
> root     27683  0.0  0.1   6332  1236 ?        Ss   16:05   0:00
> /usr/sbin/rpc.statd
> root     27699  0.0  0.1   6264  1180 ?        Ss   16:05   0:00
> /usr/sbin/rpc.gssd -vvv
> root     27720  0.0  0.0   3776   476 pts/0    S+   17:01   0:00
> grep -i rpc
> 
> And rpcinfo shows:
> root@linuxclient ~]# rpcinfo
>    program version netid     address                service    owner
>     100000    4    tcp6      ::.0.111               portmapper superuser
>     100000    3    tcp6      ::.0.111               portmapper superuser
>     100000    4    udp6      ::.0.111               portmapper superuser
>     100000    3    udp6      ::.0.111               portmapper superuser
>     100000    4    udp       0.0.0.0.0.111          portmapper superuser
>     100000    3    udp       0.0.0.0.0.111          portmapper superuser
>     100000    2    udp       0.0.0.0.0.111          portmapper superuser
>     100000    4    local     /var/run/rpcbind.sock  portmapper superuser
>     100000    3    local     /var/run/rpcbind.sock  portmapper superuser
>     100024    1    udp       0.0.0.0.228.144        status     superuser
>     100024    1    tcp       0.0.0.0.198.8          status     superuser
> [root@linuxclient ~]# rpcinfo -s
>    program version(s) netid(s)                         service     owner
>     100000  2,3,4     local,udp,udp6,tcp6              portmapper
> superuser
>     100024  1         tcp,udp                          status
> superuser
> 
> whereas on the fbsd box I have:
> [root@fbsdserver ~]# rpcinfo -s
>    program version(s) netid(s)                         service     owner
>     100000  2,3,4     local,udp6,tcp6,udp,tcp          rpcbind
> superuser
>     100024  1         tcp,udp,tcp6,udp6                status
> superuser
>     100021  4,3,1,0   tcp,udp,tcp6,udp6                nlockmgr
> superuser
>     100003  3,2       tcp6,tcp,udp6,udp                nfs
> superuser
>     100005  3,1       tcp,udp,tcp6,udp6                mountd
> superuser
> 
> 
> The versions I use are:
> rpcbind-0.2.0-2
> nfs-utils-1.2.2-3
> 
> And uname -a shows:
> 
> [root@linuxclient ~]# uname -a
> Linux linuxclient 2.6.35-ARCH #1 SMP PREEMPT Fri Aug 27 16:22:18 UTC
> 2010 i686 Intel(R) Xeon(R) CPU E5310 @ 1.60GHz GenuineIntel
> GNU/Linux
> 
> Does linux support RPCSEC_GSS security flavors over nvsv3?

Yes, and this is something I test regularly.

> And if
> so, could somebody direct me on how to establish mounting the remote
> share?

Looks like the server advertises ipv6.  I wonder if anyone's tested gss
in that case?

--b.

> 
> Thank you all for your time and attention in advance,
> 
> regards,
> 
> mamalos
> 
> -- 
> George Mamalakis
> 
> IT Officer
> Electrical and Computer Engineer (Aristotle Un. of Thessaloniki),
> MSc (Imperial College of London)
> 
> Department of Electrical and Computer Engineering
> Faculty of Engineering
> Aristotle University of Thessaloniki
> 
> phone number : +30 (2310) 994379
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
