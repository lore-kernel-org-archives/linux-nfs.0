Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:3941 "EHLO mail.aixigo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361AbbHFGrZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2015 02:47:25 -0400
Received: from srvvm01.ac.aixigo.de (mail.ac.aixigo.de [172.19.96.11]);
	by gate5a.ac.aixigo.de (OpenSMTPD) with ESMTPS id 488f7b7f;
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO;
	for <linux-nfs@vger.kernel.org>;
	Thu, 6 Aug 2015 08:40:43 +0200 (CEST)
From: Harald Dunkel <harald.dunkel@aixigo.de>
Subject: Debian kernel: "Server nfs-home reports our clientid is in use"
To: linux-nfs@vger.kernel.org
Message-ID: <55C3016A.9000509@aixigo.de>
Date: Thu, 6 Aug 2015 08:40:42 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I have to admit I am running Wheezy and a Debian backport kernel
(3.16.7-ckt11-1~bpo70+1) on my NFServer and the clients, but maybe
somebody on this list can help.

Problem: Since the kernel upgrade it happens that a client looses
the NFS connection sometimes. The error message in kern.log on the
client says

Jul 30 15:53:57 dpcl082 kernel: [2880660.867248] NFS: Server nfs-home reports our clientid is in use
Jul 30 15:53:57 dpcl082 kernel: [2880660.867254] NFS: state manager: lease expired failed on NFSv4 server nfs-home with
Jul 30 15:54:54 dpcl082 kernel: [2880717.424872] NFS: Server nfs-home reports our clientid is in use
Jul 30 15:54:54 dpcl082 kernel: [2880717.424878] NFS: state manager: lease expired failed on NFSv4 server nfs-home with
Jul 30 15:55:01 dpcl082 kernel: [2880724.526741] NFS: Server nfs-home reports our clientid is in use
Jul 30 15:55:01 dpcl082 kernel: [2880724.526748] NFS: state manager: lease expired failed on NFSv4 server nfs-home with
:
:


The problem does not go away on its own. I have to umount and mount
/home on the client to get write access again. /var/log/kern.log on
the server doesn't mention this incident.

Since I saw "NFSv4.1: Fix client id trunking on Linux" introduced
early this year in the official kernel and included with 3.16.7-ckt7-1
into Debian's kernel I wonder if this rings a bell somewhere?

By now I saw this problem 4 times within the last week. I have more
than 100 NFS clients running 24/7, using a static NFS mount of /home
and /data. The problem appears to be hard to reproduce.


Every helpful comment is highly appreciated.

Regards
Harri
