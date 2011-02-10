Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:51284 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab1BJA7o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 19:59:44 -0500
Received: by gxk9 with SMTP id 9so358345gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Feb 2011 16:59:43 -0800 (PST)
Date: Wed, 9 Feb 2011 20:59:43 -0400
Message-ID: <AANLkTik_Y4_UpBx-OMaedXz34qc+zuVzN1B5A5qnzW5y@mail.gmail.com>
Subject: NFS only mount with -o udp option
From: Edgar Almonte <samudhio@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

hello list

like the subject say after some upgrade of my distro ( i have 2
machine with the same distro and only in one happne the problem ) i
can only mount nfs share using the option -o udp , without it i get
this error
mount.nfs: mount system call failed

i am using avahi-dns ( mdns ) for hostname resolve

command used:
mount heaven.local:/STORAGE /nfs/STORAGE/
check dns is work right :

 ping heaven.local
PING heaven.local (192.168.1.102) 56(84) bytes of data.
64 bytes from heaven.local (192.168.1.102): icmp_seq=1 ttl=64 time=0.153 ms
64 bytes from heaven.local (192.168.1.102): icmp_seq=2 ttl=64 time=0.160 ms
^C
--- heaven.local ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.153/0.156/0.160/0.013 ms


anyidea what i need check for solve this issue ?

thanks
