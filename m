Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tur.go2.pl ([193.17.41.50]:34121 "EHLO tur.go2.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932891Ab1AMLiS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 06:38:18 -0500
Received: from moh2-ve3.go2.pl (moh2-ve3.go2.pl [193.17.41.208])
	by tur.go2.pl (o2.pl Mailer 2.0.1) with ESMTP id 4C1962302C2
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 12:38:17 +0100 (CET)
Received: from moh2-ve3.go2.pl (unknown [10.0.0.208])
	by moh2-ve3.go2.pl (Postfix) with ESMTP id 4E3F93701A0
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 12:37:35 +0100 (CET)
Received: from o2.pl (unknown [10.0.0.120])
	by moh2-ve3.go2.pl (Postfix) with SMTP
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 12:37:35 +0100 (CET)
Subject: =?UTF-8?Q?failover_problem?=
From: =?UTF-8?Q?motyllo8?= <motyllo8@tlen.pl>
To: linux-nfs@vger.kernel.org
Message-ID: <64f18899.1305ee97.4d2ee3fe.430ca@tlen.pl>
Date: Thu, 13 Jan 2011 12:37:34 +0100
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I am currently testing NFS in HA configuration using Heartbeat.

I am performing following test:

My client is coping file (about 2GB). During this coping I am rebooting primary node. After it secondary node switches to active mode. Unfortunately my client is not resuming coping. After failback action, this process is being resumed.

I've noticed after failover on my secondary node following message in dmesg:

RPC: fragment too large: 0x0008009c

This message occurs a few times - I am wondering what does it mean? Maybe this is the reason of this strange behavior?

A few words about my configuration:
- Debian based system.
- kernel 2.6.27-39,
- nfsutils in version 1.0.10,
- client mount option:
mount -t nfs 192.168.0.220:/share /mnt/share

- server side /etc/exports:
"/share"    *(rw,no_root_squash,async,subtree_check)

Let me know if you need more details connected to my configuration.

Cheers
Marcus



