Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp04.online.nl ([194.134.41.34]:52211 "EHLO smtp04.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab1FCHjS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jun 2011 03:39:18 -0400
Received: from smtp04.online.nl (localhost [127.0.0.1])
	by smtp04.online.nl (Postfix) with ESMTP id 8FAB2E1D6
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jun 2011 09:29:20 +0200 (CEST)
Received: from srv2.net.home (s5375c22f.adsl.wanadoo.nl [83.117.194.47])
	by smtp04.online.nl (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jun 2011 09:29:20 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by srv2.net.home (Postfix) with ESMTP id 33964624F0
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jun 2011 09:29:20 +0200 (CEST)
Received: from srv2.net.home ([127.0.0.1])
	by localhost (webmail.net.home [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id fEehDnH2GisO for <linux-nfs@vger.kernel.org>;
	Fri,  3 Jun 2011 09:29:20 +0200 (CEST)
Received: from [192.168.1.2] (vovan.net.home [192.168.1.2])
	by srv2.net.home (Postfix) with ESMTPS id E06FE624EE
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jun 2011 09:29:19 +0200 (CEST)
Subject: NFS3 + kerberos: performance issues
From: Vladimir Elisseev <vovan@vovan.nl>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 03 Jun 2011 09:29:19 +0200
Message-ID: <1307086159.1052.19.camel@vovan.net.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

After using nfs3 with kerberos for a while I discovered very poor
performance for some file operations like creation of files. There are
two observations:
- the overal nfs3 performance is good: for instance copying large files
works fine
- this poor performance is definitely related to kerberos as the same
volume exported without sec=krb5 works ~10 times faster with creating
files
I'd appreciate if somebody can explain this behaviour?

Below are some details about NFS server and client:
server:
- kernel 2.6.36
- export options rw,sec=krb5,no_root_squash,no_subtree_check
- nfs-utils 1.2.3

client:
- kernel 2.6.38 or 2.6.39 
- mout options (from /proc/mounts):
rw,nosuid,nodev,noatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=krb5,mountaddr=192.168.1.219,mountvers=3,mountport=32767,mountproto=tcp,local_lock=none,addr=192.168.1.219

when the same volume exported without sec=krb5, the only option changes
in /proc/mounts is sec=sys

Regards,
Vlad.

