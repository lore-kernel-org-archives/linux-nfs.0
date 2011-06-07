Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33883 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658Ab1FGDwo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2011 23:52:44 -0400
Message-ID: <4DEDA087.5070905@candelatech.com>
Date: Mon, 06 Jun 2011 20:52:39 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Question on portmapper source
References: <4DED6DC8.8020500@candelatech.com> <7B1787E7-75DC-4CBB-86DA-FAA1B0366B00@oracle.com>
In-Reply-To: <7B1787E7-75DC-4CBB-86DA-FAA1B0366B00@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/06/2011 06:11 PM, Chuck Lever wrote:
>
> On Jun 6, 2011, at 8:16 PM, Ben Greear wrote:
>
>> What is the official upstream project that contains the portmapper
>> source?
>
> Do you want pormapper or rpcbind?  The newer rpcbind actually allows RPC services to register at specific addresses, but the legacy portmapper does not.

I don't know.  I was testing my nfs binding patches (which fixes up some of the kernel
processes, at least), but when trying to connect through a router, we noticed that
this traffic was using the wrong source IP (ie, it wasn't bound):

   0.000000 192.168.100.117 -> 172.16.0.100 TCP 33282 > 111 [SYN] Seq=0
Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=6981376 TSER=0 WS=10
   3.007677 192.168.100.117 -> 172.16.0.100 TCP 33282 > 111 [SYN] Seq=0
Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=6984384 TSER=0 WS=10
   9.023670 192.168.100.117 -> 172.16.0.100 TCP 33282 > 111 [SYN] Seq=0
Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=6990400 TSER=0 WS=10
  10.010239 192.168.100.117 -> 172.16.0.100 Portmap V2 GETPORT Call NFS(100003)
V:3 UDP
  11.011269 192.168.100.117 -> 172.16.0.100 Portmap [RPC retransmission of #4]V2
GETPORT Call NFS(100003) V:3 UDP
  12.012298 192.168.100.117 -> 172.16.0.100 Portmap [RPC retransmission of #4]V2
GETPORT Call NFS(100003) V:3 UDP
  20.422093 192.168.100.117 -> 172.16.0.100 TCP 44732 > 111 [SYN] Seq=0
Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=7001798 TSER=0 WS=10
  23.423683 192.168.100.117 -> 172.16.0.100 TCP 44732 > 111 [SYN] Seq=0
Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=7004800 TSER=0 WS=10
  29.439676 192.168.100.117 -> 172.16.0.100 TCP 44732 > 111 [SYN] Seq=0
Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=7010816 TSER=0 WS=10
  30.432383 192.168.100.117 -> 172.16.0.100 Portmap V2 GETPORT Call NFS(100003)
V:3 UDP
  31.433420 192.168.100.117 -> 172.16.0.100 Portmap [RPC retransmission of
#10]V2 GETPORT Call NFS(100003) V:3 UDP
  32.434458 192.168.100.117 -> 172.16.0.100 Portmap [RPC retransmission of
#10]V2 GETPORT Call NFS(100003) V:3 UDP

I need to make whatever is generating that traffic bind to a source IP.

>
>> Also, the mount.nfs package, as I'll probably need to modify that
>> as well...
>
> mount.nfs is in nfs-utils.

What is the git repo for it, though?

>
>> I am going to try to allow portmapper to bind to a particular
>> source IP when making outbound requests....
>
> I don't understand.  portmapper, as an RPC service, receives incoming requests.  But we don't use the rpcbind CALLIT procedure on Linux, thus it doesn't make outbound requests.

I could easily be confused about where the problem lies.  Any idea what is generating
those requests on the nfs client above?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
