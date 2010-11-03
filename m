Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mb2.zcs.datasyncintra.net ([208.88.241.40]:43917 "EHLO
	mb2.zcs.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674Ab0KCSIx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 14:08:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by mb2.zcs.datasyncintra.net (Postfix) with ESMTP id B30C5BE079
	for <linux-nfs@vger.kernel.org>; Wed,  3 Nov 2010 12:58:02 -0500 (CDT)
Received: from mb2.zcs.datasyncintra.net ([127.0.0.1])
	by localhost (mb2.zcs.datasyncintra.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5OQQQLmSfu86 for <linux-nfs@vger.kernel.org>;
	Wed,  3 Nov 2010 12:58:02 -0500 (CDT)
Received: from mb2.zcs.datasyncintra.net (mb2.zcs.datasyncintra.net [172.16.0.67])
	by mb2.zcs.datasyncintra.net (Postfix) with ESMTP id 1B6D4BE073
	for <linux-nfs@vger.kernel.org>; Wed,  3 Nov 2010 12:58:02 -0500 (CDT)
Date: Wed, 3 Nov 2010 11:58:02 -0600 (CST)
From: Shehjar Tikoo <shehjart@gluster.com>
To: linux-nfs@vger.kernel.org
Message-ID: <766909857.700951.1288807081999.JavaMail.root@mb2>
Subject: Streaming perf problem on 10g
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi All,

I am running into a performance problem with 2.6.32-23 Ubuntu lucid on both client and server.

The disk is an SSD performing at 1.4 - 1.6Gbps for a dd of a 6gb file in 64k blocks.

The network is performing fine with many Gbps of iperf throughput.

Yet, the dd write performance over the nfs mount point ranges from 96-105 Mbps for a 6gb file in 64k blocks.

I've tried changing the tcp_slot_table_entries and the wsize but there is negligible gain from these.

Does it sound like a client side inefficiency?

Thanks
-Shehjar
