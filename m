Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:54602 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758274Ab2FOWah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jun 2012 18:30:37 -0400
Received: from anubis.ics.muni.cz (igw1.zrnko.net [94.112.253.31])
	(authenticated user=xhejtman@IS.MUNI.CZ bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id q5FMUXNc011107
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Sat, 16 Jun 2012 00:30:35 +0200
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.80)
	(envelope-from <xhejtman@ics.muni.cz>)
	id 1Sff2C-0008Na-6V
	for linux-nfs@vger.kernel.org; Sat, 16 Jun 2012 00:30:28 +0200
Date: Sat, 16 Jun 2012 00:30:28 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 and Kerberos problem in svcgssd
Message-ID: <20120615223028.GS20917@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

it seems that -n option for rpc.svcgssd produces file descriptor leaks. It
looks like this:

ls -l /proc/25920/fd/
total 0
lrwx------ 1 root root 64 Jun 16 00:13 0 -> /dev/pts/0
lrwx------ 1 root root 64 Jun 16 00:13 1 -> /dev/pts/0
lrwx------ 1 root root 64 Jun 16 00:13 10 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 11 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 12 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 13 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 14 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 15 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 16 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 17 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 18 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 19 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 2 -> /dev/pts/0
lrwx------ 1 root root 64 Jun 16 00:13 20 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 21 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 22 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 23 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 24 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 25 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 26 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 27 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 28 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 16 00:13 29 -> /var/tmp/nfs_0
lr-x------ 1 root root 64 Jun 16 00:13 3 -> pipe:[24457591]
lrwx------ 1 root root 64 Jun 16 00:13 30 -> /var/tmp/nfs_0
l-wx------ 1 root root 64 Jun 16 00:13 4 -> pipe:[24457591]
lr-x------ 1 root root 64 Jun 16 00:13 5 -> pipe:[24457592]
l-wx------ 1 root root 64 Jun 16 00:13 6 -> pipe:[24457592]
lr-x------ 1 root root 64 Jun 16 00:13 7 -> /etc/gssapi_mech.conf
lr-x------ 1 root root 64 Jun 16 00:13 8 ->
/proc/25920/net/rpc/auth.rpcsec.init/channel
lrwx------ 1 root root 64 Jun 16 00:13 9 -> /var/tmp/nfs_0

Is there any known fix for this? It runs quickly from max open files..

There is some gabage collecting that results in this:
s -l
total 0
lrwx------ 1 root root 64 Jun 15 23:45 0 -> /dev/pts/0
lrwx------ 1 root root 64 Jun 15 23:45 1 -> /dev/pts/0
lrwx------ 1 root root 64 Jun 15 23:46 10 -> /var/tmp/nfs_0 (deleted)
lrwx------ 1 root root 64 Jun 15 23:47 11 -> /var/tmp/nfs_0 (deleted)
lrwx------ 1 root root 64 Jun 15 23:47 12 -> /var/tmp/nfs_0
lrwx------ 1 root root 64 Jun 15 23:45 2 -> /dev/pts/0
lr-x------ 1 root root 64 Jun 15 23:45 3 -> pipe:[24450369]
l-wx------ 1 root root 64 Jun 15 23:45 4 -> pipe:[24450369]
lr-x------ 1 root root 64 Jun 15 23:45 5 -> pipe:[24450370]
l-wx------ 1 root root 64 Jun 15 23:45 6 -> pipe:[24450370]
lr-x------ 1 root root 64 Jun 15 23:45 7 -> /etc/gssapi_mech.conf
lr-x------ 1 root root 64 Jun 15 23:45 8 ->
/proc/24184/net/rpc/auth.rpcsec.init/channel
lrwx------ 1 root root 64 Jun 15 23:45 9 -> /var/tmp/nfs_0 (deleted)


-- 
Luká¹ Hejtmánek
