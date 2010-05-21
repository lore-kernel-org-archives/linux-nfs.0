Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60066 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758577Ab0EUWJ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 May 2010 18:09:26 -0400
Date: Fri, 21 May 2010 17:09:24 -0500
Message-ID: <AANLkTin5z2vuslfeGxa9HtJgwiOqF9W8R0ueyc79cENq@mail.gmail.com>
Subject: NFS client socket in TIME_WAIT endlessly
From: Goldwyn Rodrigues <rgoldwyn@gmail.com>
To: linux-net@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

NFSv3 over TCP  hangs in case of network failure for a short while. I
investigated further, and found that the nfs socket goes into
TIME_WAIT state and doesn't come out of it, even after the default
timeout of 120 seconds. This blocks all further traffic and any I/O
from NFS client hangs. This happens only if tcp_timestamps is
disabled, and in 50% of the cases.

Kernel Version: 2.6.33.4

Steps to reproduce (at client end only):
1. Disable tcp_timestamps
2. Perform multi-user I/O on the NFS partition
3. Block traffic to NFS server. (I used iptables)
4. After the I/O queues up for some time (approx 3 minutes), re-enable
network to the server.

netstat -a | grep nfs shows nfs socket in TIME_WAIT state and it does
not come out of it.

I have the rpc logs (rpc_debug=129) if anyone requires
Let me know if you need anything else.

-- 
Goldwyn
