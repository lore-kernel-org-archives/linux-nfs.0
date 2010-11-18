Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46805 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758180Ab0KRUHy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 15:07:54 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id oAIK7rZK007850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 12:07:54 -0800
Message-ID: <4CE58799.1010702@candelatech.com>
Date: Thu, 18 Nov 2010 12:07:53 -0800
From: Ben Greear <greearb@candelatech.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Very slow O_DIRECT writes on NFS in .36
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I applied the NFS O_DIRECT patch (and all others) from the pending 2.6.36 stable
queue, and now I can at least use O_DIRECT w/out immediate failure.

However, I notice that when writing 2k chunks with O_DIRECT on
NFS, it runs extremely slowly (about 300Kbps throughput).  The
server is a Fedora 13 64-bit system running 2.6.34.7-56.fc13.x86_64

Here's some strace -ttT output for the writer:

07:03:42.898058 write(9, "\370'\37\345v\230\315\253\3\0\0\0\354\7\0\0\16\1\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 2048) = 2048 <0.059402>
07:03:42.957649 poll([{fd=4, events=POLLIN}, {fd=8, events=POLLIN}, {fd=6, events=POLLIN}], 3, 0) = 0 (Timeout) <0.000266>
07:03:42.958148 write(9, "\212$s\327v\230\315\253\3\0\0\0\354\7\0\0\17\1\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 2048) = 2048 <0.069295>
07:03:43.027524 poll([{fd=4, events=POLLIN}, {fd=8, events=POLLIN}, {fd=6, events=POLLIN}], 3, 0) = 0 (Timeout) <0.000011>


Writing 64k chunks takes basically the same amount of time per system call:

07:06:13.537488 write(9, "\5\340\202\262v\230\315\253\3\0\0\0\354\377\0\0\6\0\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 65536) = 65536 <0.049462>
07:06:13.587083 poll([{fd=4, events=POLLIN}, {fd=8, events=POLLIN}, {fd=6, events=POLLIN}], 3, 0) = 0 (Timeout) <0.000035>
07:06:13.587410 write(9, "\250\231\377cv\230\315\253\3\0\0\0\354\377\0\0\7\0\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 65536) = 65536 <0.058612>
07:06:13.646233 poll([{fd=4, events=POLLIN}, {fd=8, events=POLLIN}, {fd=6, events=POLLIN}], 3, 0) = 0 (Timeout) <0.000095>
07:06:13.646616 write(9, "\5-@\5v\230\315\253\3\0\0\0\354\377\0\0\10\0\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 65536) = 65536 <0.050282>


Reading is a good deal faster..about 34Mbps with O_DIRECT, NFS and 2k reads.

Any ideas about why the write performance is so bad?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

