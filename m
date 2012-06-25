Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:50052 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143Ab2FYWww (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2012 18:52:52 -0400
Received: by weyu7 with SMTP id u7so3161074wey.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2012 15:52:51 -0700 (PDT)
MIME-Version: 1.0
From: Thomas Spear <speeddymon@gmail.com>
Date: Mon, 25 Jun 2012 17:52:19 -0500
Message-ID: <CAEAsNvQ_eTdsvBfUjuXLxv_thitpnHcgz4UXxG7BR=7n7=bO3A@mail.gmail.com>
Subject: lockd/PF_INET6 question
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I've just subscribed, so please forgive me if I am in the wrong place.

I run a file server at home which is really just a mid-range desktop
motherboard/proc/memory stuck inside a server chassis, with a couple
of raid cards. It runs CentOS 6.2.

I wanted to disable IPv6, and so I followed instructions on the
internet which were to use sysctl to do so. After restarting nfs,
nfslock, and rpcbind, I found that some NFS services were still using
IPv6, so a bit of further googling revealed that I needed to comment a
couple of lines in /etc/netconfig which I've done.

Now restarted nfs, nfslock, and rpcbind again, and still one thing uses IPv6.

[root@fileserver ~]# netstat -plnt |grep ::
tcp        0      0 :::1101                     :::*
     LISTEN      -
[root@fileserver ~]# grep 1101 /etc/sysconfig/nfs
LOCKD_TCPPORT=1101
LOCKD_UDPPORT=1101
[root@fileserver ~]# ps waufx |grep '\[[l]ockd'
root      7806  0.0  0.0      0     0 ?        S    16:04   0:00  \_ [lockd]

I did see other pages that said to force the IPv6 module to not load,
but then I saw a redhat bugzilla saying that that was not the
recommended way.

So again after some more googling, I found the following commit:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=eb16e907781a9da7f272a3e8284c26bc4e4aeb9d

I believe this does exactly what I want, but it appears to only do so
if the ipv6 module isn't loaded, which seems improper to me, if the
recommended and preferred way to disable IPv6 is with sysctl.

Would it be possible to have lockd remove its tcp support also when
the sysctl values indicate that IPv6 is not in use:

[root@fileserver ~]# grep ipv6 /etc/sysctl.conf
# Disable ipv6
net.ipv6.conf.all.disable_ipv6 = 1



Thank you,

Thomas
