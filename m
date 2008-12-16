From: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Subject: nfs-utils mountd getfh failed: No such file or directory
Date: Tue, 16 Dec 2008 16:38:14 +0100
Message-ID: <x6k5a0166x@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:39761 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756735AbYLPQAG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 11:00:06 -0500
Received: from odpn1.odpn.net [212.40.96.53]
	by odpn1.odpn.net for linux-nfs@vger.kernel.org
	id 1LCbzz-0006X7-4Z; Tue, 16 Dec 2008 16:38:15 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I would like to use nfs-utils 1.1.4 (and 1.1.*) in the following environment:

[kernel]
Linux gzp 2.6.27.9-gzp2 #1 Tue Dec 16 15:17:04 CET 2008 i686 GNU/Linux

[glibc]
GNU C Library stable release version 2.3.6, by Roland McGrath et al.
Compiled by GNU CC version 4.1.2.
Compiled on a Linux 2.4.34-gzp1 system on 2007-04-04.

But getting this error after trying to mount from remote:

2008 Dec 16 15:48:44 <daemon.info> gzp portmap[1843]: connect from 192.168.1.1 to getport(nfs)
2008 Dec 16 15:48:44 <daemon.info> gzp portmap[1844]: connect from 192.168.1.1 to getport(mountd)
2008 Dec 16 15:48:44 <daemon.notice> gzp mountd[1748]: authenticated mount request from 192.168.1.1:835 for /var/archive/sda1 (/var/archive/sda1)
2008 Dec 16 15:48:44 <daemon.warning> gzp mountd[1748]: getfh failed: No such file or directory

Found the revelant code in the mountd source, but I don't know what is this error.
