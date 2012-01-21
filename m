Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41711 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356Ab2AURES (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Jan 2012 12:04:18 -0500
Received: by vbbfp1 with SMTP id fp1so1044194vbb.19
        for <linux-nfs@vger.kernel.org>; Sat, 21 Jan 2012 09:04:17 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 21 Jan 2012 18:04:17 +0100
Message-ID: <CAG+vHK+OUSdEc5L=_oeq4Y9iwseusspPTG=jwUvoOQd5587O9Q@mail.gmail.com>
Subject: NFSv4 - Linux server, FreeBSD client
From: "J. von Balzac" <jhm.balzac@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Linux (kernel 3.2) /etc/exports contains the following:

/exp  -ro,fsid=0,async,subtree_check,all_squash,crossmnt 192.168.1.0/24
/exp/freebsd  -ro,no_acl,async,subtree_check,all_squash 192.168.1.0/24
/exp/freebsd/extra -rw,no_acl,async,subtree_check,no_root_squash 192.168.1.0/24
/exp/freebsd/ports  -rw,no_acl,async,subtree_check,no_root_squash 192.168.1.0/24

I have also tested it without no_acl, and with the alternative
192.168.1.0/24(options).

The used mount command on FreeBSD and the resulting error:

# mount_nfs -o nfsv4 192.168.1.3:/freebsd/ports /usr/ports
mount_nfs: /usr/ports, : Operation not permitted

I am emailing this list and not FreeBSD, because of this next output
from tcpdump. Note that 192.168.1.3 is the server and 192.168.1.10 is
the client:

17:00:21.761418 IP (tos 0x0, ttl 64, id 62972, offset 0, flags [DF],
proto TCP (6), length 116)
    192.168.1.3.2049 > 192.168.1.10.1382070341: reply ok 60 getattr
ERROR: Operation not permitted

The entire output of the tcpdump can be found at the following url:
http://sprunge.us/OVbQ

Looking forward to resolving this.
Jan.
