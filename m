Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sith.mimuw.edu.pl ([193.0.96.4]:58665 "EHLO sith.mimuw.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932268Ab0I3Rkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 13:40:52 -0400
Date: Thu, 30 Sep 2010 19:40:50 +0200
From: Jan =?utf-8?Q?R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: ANNOUNCE: nfs-utils-1.2.3 released.
Message-ID: <20100930174050.GB12882@sith.mimuw.edu.pl>
References: <4CA1E5E4.1070404@RedHat.com> <20100930172842.GA12882@sith.mimuw.edu.pl> <B90557BC-EDC3-43E8-96E8-C507C4165A1F@oracle.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <B90557BC-EDC3-43E8-96E8-C507C4165A1F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 30 Sep 2010, Chuck Lever wrote:

> Hi Jan-
> 
> Can you file this on bugzilla.linux-nfs.org and assign it to me?  It's
> likely that this feature isn't working for statd either.  I'll try to
> get right to it.

Done.
https://bugzilla.linux-nfs.org/show_bug.cgi?id=190
 
> On Sep 30, 2010, at 1:28 PM, Jan Rękorajski wrote:
> 
> > On Tue, 28 Sep 2010, Steve Dickson wrote:
> > 
> >> New Features in this release:
> >> 
> >>   * Both Client and server IPv6 support is available with the 
> >>     --enable-ipv6 configuration flag (which is on by default)
> >> 
> >>   * NFSoverRDMA mount support.
> >> 
> >>   * A large number of bug fixes.
> > 
> > Unfortunately there is a new misfeature in rpc.mountd that crept in
> > with IPv6 support.
> > Option '-p <port>' is no longer working, mountd succesfully registers
> > MNT1 and then fails with -EADDRINUSE for MNT2 and MNT3 on ip4/tcp,udp and
> > ip6/tcp,udp transports.
> > 
> > [root@home ~]# rpc.mountd -d all -F -p 4444
> > rpc.mountd: svc_tli_create: could not bind to requested address
> > rpc.mountd: Failed to create listener xprt (mountd, 2, udp)
> > rpc.mountd: svc_tli_create: could not bind to requested address
> > rpc.mountd: Failed to create listener xprt (mountd, 2, tcp)
> > rpc.mountd: svc_tli_create: could not bind to requested address
> > rpc.mountd: Failed to create listener xprt (mountd, 2, udp6)
> > rpc.mountd: svc_tli_create: could not bind to requested address
> > rpc.mountd: Failed to create listener xprt (mountd, 2, tcp6)
> > rpc.mountd: svc_tli_create: could not bind to requested address
> > rpc.mountd: Failed to create listener xprt (mountd, 3, udp)
> > rpc.mountd: svc_tli_create: could not bind to requested address
> > rpc.mountd: Failed to create listener xprt (mountd, 3, tcp)
> > rpc.mountd: svc_tli_create: could not bind to requested address
> > rpc.mountd: Failed to create listener xprt (mountd, 3, udp6)
> > rpc.mountd: svc_tli_create: could not bind to requested address
> > rpc.mountd: Failed to create listener xprt (mountd, 3, tcp6)
> > rpc.mountd: Kernel does not have pseudo root support.
> > rpc.mountd: NFS v4 mounts will be disabled unless fsid=0
> > rpc.mountd: is specfied in /etc/exports file.
> > rpc.mountd: Version 1.2.3 starting
> > 
> > [root@home ~]# rpcinfo -t localhost 100005
> > program 100005 version 1 ready and waiting
> > 
> > If I start mountd without '-p' it succesfully registers all versions
> > on random ports.
> > 
> > [root@home ~]# rpc.mountd -d all -F 
> > rpc.mountd: Kernel does not have pseudo root support.
> > rpc.mountd: NFS v4 mounts will be disabled unless fsid=0
> > rpc.mountd: is specfied in /etc/exports file.
> > rpc.mountd: Version 1.2.3 starting
> > 
> > [root@home ~]# rpcinfo -t localhost 100005
> > program 100005 version 1 ready and waiting
> > program 100005 version 2 ready and waiting
> > program 100005 version 3 ready and waiting
> > 
> > Reverting b551b1fd0052de9b8c674b30c39d9f2a1e9d79cc cures the problem.
> > but I guess it's not the right thing to do.
> > 
> > -- 
> > Jan Rękorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
> > baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
> > BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio
> 
> -- 
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jan Rękorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio
