Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52193 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758137Ab0KRUXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 15:23:51 -0500
Message-ID: <4CE58B54.4090203@candelatech.com>
Date: Thu, 18 Nov 2010 12:23:48 -0800
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Very slow O_DIRECT writes on NFS in .36
References: <4CE58799.1010702@candelatech.com> <4234EB44-97D5-4212-A52E-983907D2733F@oracle.com>
In-Reply-To: <4234EB44-97D5-4212-A52E-983907D2733F@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/18/2010 12:17 PM, Chuck Lever wrote:
>
> On Nov 18, 2010, at 3:07 PM, Ben Greear wrote:
>
>> I applied the NFS O_DIRECT patch (and all others) from the pending 2.6.36 stable
>> queue, and now I can at least use O_DIRECT w/out immediate failure.
>>
>> However, I notice that when writing 2k chunks with O_DIRECT on
>> NFS, it runs extremely slowly (about 300Kbps throughput).  The
>> server is a Fedora 13 64-bit system running 2.6.34.7-56.fc13.x86_64
>>
>> Here's some strace -ttT output for the writer:
>>
>> 07:03:42.898058 write(9, "\370'\37\345v\230\315\253\3\0\0\0\354\7\0\0\16\1\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 2048) = 2048<0.059402>
>> 07:03:42.957649 poll([{fd=4, events=POLLIN}, {fd=8, events=POLLIN}, {fd=6, events=POLLIN}], 3, 0) = 0 (Timeout)<0.000266>
>> 07:03:42.958148 write(9, "\212$s\327v\230\315\253\3\0\0\0\354\7\0\0\17\1\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 2048) = 2048<0.069295>
>> 07:03:43.027524 poll([{fd=4, events=POLLIN}, {fd=8, events=POLLIN}, {fd=6, events=POLLIN}], 3, 0) = 0 (Timeout)<0.000011>
>>
>>
>> Writing 64k chunks takes basically the same amount of time per system call:
>>
>> 07:06:13.537488 write(9, "\5\340\202\262v\230\315\253\3\0\0\0\354\377\0\0\6\0\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 65536) = 65536<0.049462>
>> 07:06:13.587083 poll([{fd=4, events=POLLIN}, {fd=8, events=POLLIN}, {fd=6, events=POLLIN}], 3, 0) = 0 (Timeout)<0.000035>
>> 07:06:13.587410 write(9, "\250\231\377cv\230\315\253\3\0\0\0\354\377\0\0\7\0\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 65536) = 65536<0.058612>
>> 07:06:13.646233 poll([{fd=4, events=POLLIN}, {fd=8, events=POLLIN}, {fd=6, events=POLLIN}], 3, 0) = 0 (Timeout)<0.000095>
>> 07:06:13.646616 write(9, "\5-@\5v\230\315\253\3\0\0\0\354\377\0\0\10\0\0\0\0\1\2\3\4\5\6\7\10\t\n\v"..., 65536) = 65536<0.050282>
>>
>>
>> Reading is a good deal faster..about 34Mbps with O_DIRECT, NFS and 2k reads.
>>
>> Any ideas about why the write performance is so bad?
>
> A network trace will probably show you that the per-write latency is due to the server.
>

Looks like you are right.  I don't remember it being this slow before, but
maybe it was.  We'll run some tests with older kernels and/or different
servers.

   6.700193 192.168.100.173 -> 192.168.100.3 NFS V3 WRITE Call, FH:0x6bc05782 Offset:96256 Len:1024 FILE_SYNC
   6.740547 192.168.100.3 -> 192.168.100.173 TCP 2049 > 800 [ACK] Seq=12321 Ack=101729 Win=501 Len=0 TSV=218471603 TSER=1385525
   6.769380 192.168.100.3 -> 192.168.100.173 NFS V3 WRITE Reply (Call In 262) Len:1024 FILE_SYNC
   6.769609 192.168.100.173 -> 192.168.100.3 NFS V3 WRITE Call, FH:0x6bc05782 Offset:97280 Len:1024 FILE_SYNC
   6.809777 192.168.100.3 -> 192.168.100.173 TCP 2049 > 800 [ACK] Seq=12461 Ack=102885 Win=501 Len=0 TSV=218471673 TSER=1385594
   6.850373 192.168.100.3 -> 192.168.100.173 NFS V3 WRITE Reply (Call In 265) Len:1024 FILE_SYNC
   6.850631 192.168.100.173 -> 192.168.100.3 NFS V3 WRITE Call, FH:0x6bc05782 Offset:98304 Len:1024 FILE_SYNC
   6.890845 192.168.100.3 -> 192.168.100.173 TCP 2049 > 800 [ACK] Seq=12601 Ack=104041 Win=501 Len=0 TSV=218471754 TSER=1385675
   6.930344 192.168.100.3 -> 192.168.100.173 NFS V3 WRITE Reply (Call In 268) Len:1024 FILE_SYNC
   6.930703 192.168.100.173 -> 192.168.100.3 NFS V3 WRITE Call, FH:0x6bc05782 Offset:99328 Len:1024 FILE_SYNC
   6.971753 192.168.100.3 -> 192.168.100.173 TCP 2049 > 800 [ACK] Seq=12741 Ack=105197 Win=501 Len=0 TSV=218471834 TSER=1385755
   6.980341 192.168.100.3 -> 192.168.100.173 NFS V3 WRITE Reply (Call In 271) Len:1024 FILE_SYNC


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

