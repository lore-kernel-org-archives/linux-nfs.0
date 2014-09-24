Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dgate10.ts.fujitsu.com ([80.70.172.49]:21288 "EHLO
	dgate10.ts.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbaIXLHG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 07:07:06 -0400
From: =?iso-8859-1?Q?Str=F6sser=2C_Bodo?= <bodo.stroesser@ts.fujitsu.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "bfields@fieldses.org" <bfields@fieldses.org>
Date: Wed, 24 Sep 2014 12:57:09 +0200
Subject: rpc.mountd can be blocked by a bad client
Message-ID: <8B06D1E6480A6747B23FEC34909D2B5EA819D7DCA4@ABGEX70E.FSC.NET>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

a few days ago we had some trouble with a NFS server. The clients most of the time no longer
could mount any shares, but in rare cases they had success.

We found out, that during the times when mounts failed, rpc.mountd hung on a write() to a TCP
socket. netstat showed, that Send-Q was full and Recv-Q counted up slowly. After a long time
the write ended with an error ("TCP timeout" IIRC) and rpc.mountd worked normally for a short
while until it again hung on write() for the same reason. The problem was caused by a MTU size
configured wrong. So, one single bad client (or as much clients as the number of threads used
by rpc.mountd) can block rpc.mountd entirely.

But what will happen, if someone intentionally sends RPC requests, but doesn't read() the
answers? I wrote a small tool to test this situation. It fires DUMP requests to rpc.mountd as
fast as possible, but does not read from the socket. The result is the same as with the
problem above: rpc.mountd hangs in write() and no longer responds to other requests while no
TCP timeout breaks up this situation.

So it's quite easy to intentionally block rpc.mountd from remote.

Please CC me, I'm not on the list.

Best regards,
Bodo
