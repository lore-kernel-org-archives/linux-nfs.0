Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cmsout01.mbox.net ([165.212.64.31]:41990 "EHLO
	cmsout01.mbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759026Ab0ECO6B convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 10:58:01 -0400
Received: from cmsout01.mbox.net (cmsout01-lo [127.0.0.1])
	by cmsout01.mbox.net (Postfix) with ESMTP id 7EEFF2AC566
	for <linux-nfs@vger.kernel.org>; Mon,  3 May 2010 14:45:54 +0000 (GMT)
Date: Mon, 03 May 2010 09:45:53 -0500
From: "Jack Byer" <ojbyer@usa.net>
Reply-To: ftn768@gmail.com
To: <linux-nfs@vger.kernel.org>
Subject: IPv6 and NFS4
Message-ID: <544oecoS23680S01.1272897953@web01.cms.usa.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If I have an NFS4 server successfully sharing a directory with a client and
both machines have valid IPv4 and IPv6 addresses should it be possible to
mount the directory using either IPv4 or IPv6?

Both machines are running 2.6.34-rc6 kernels, nfs-utils-1.2.2,
libtirpc-0.2.0 and rpcbind-0.2.0. Mounting over IPv4 works perfectly, but
IPv6 just times out while trying to mount the share. Using tcpdump I see
that the two machines exchange 40 packets before the client finally gives
up. There are no messages generated in the system log or dmesg of either
machine.


