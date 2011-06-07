Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664Ab1FGHwG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 03:52:06 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <19949.55456.285011.382387@regina.usersys.redhat.com>
Date: Tue, 7 Jun 2011 17:52:00 +1000
From: Max Matveev <makc@redhat.com>
To: Ben Greear <greearb@candelatech.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Question on portmapper source
In-Reply-To: <4DEDA087.5070905@candelatech.com>
References: <4DED6DC8.8020500@candelatech.com>
	<7B1787E7-75DC-4CBB-86DA-FAA1B0366B00@oracle.com>
	<4DEDA087.5070905@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 06 Jun 2011 20:52:39 -0700, Ben Greear wrote:

 greearb> On 06/06/2011 06:11 PM, Chuck Lever wrote:
 >> 
 >> On Jun 6, 2011, at 8:16 PM, Ben Greear wrote:
 >> 
 >>> What is the official upstream project that contains the portmapper
 >>> source?
 >> 
 >> Do you want pormapper or rpcbind?  The newer rpcbind actually allows RPC services to register at specific addresses, but the legacy portmapper does not.

 greearb> I don't know.  I was testing my nfs binding patches (which
 greearb> fixes up some of the kernel processes, at least), but when
 greearb> trying to connect through a router, we noticed that this
 greearb> traffic was using the wrong source IP (ie, it wasn't bound):

 greearb>    0.000000 192.168.100.117 -> 172.16.0.100 TCP 33282 > 111 [SYN] Seq=0
 greearb> Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=6981376 TSER=0 WS=10
 greearb>    3.007677 192.168.100.117 -> 172.16.0.100 TCP 33282 > 111 [SYN] Seq=0
 greearb> Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=6984384 TSER=0 WS=10
 greearb>    9.023670 192.168.100.117 -> 172.16.0.100 TCP 33282 > 111 [SYN] Seq=0
 greearb> Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=6990400 TSER=0 WS=10
 greearb>   10.010239 192.168.100.117 -> 172.16.0.100 Portmap V2 GETPORT Call NFS(100003)
 greearb> V:3 UDP
 greearb>   11.011269 192.168.100.117 -> 172.16.0.100 Portmap [RPC retransmission of #4]V2
 greearb> GETPORT Call NFS(100003) V:3 UDP
 greearb>   12.012298 192.168.100.117 -> 172.16.0.100 Portmap [RPC retransmission of #4]V2
 greearb> GETPORT Call NFS(100003) V:3 UDP
 greearb>   20.422093 192.168.100.117 -> 172.16.0.100 TCP 44732 > 111 [SYN] Seq=0
 greearb> Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=7001798 TSER=0 WS=10
 greearb>   23.423683 192.168.100.117 -> 172.16.0.100 TCP 44732 > 111 [SYN] Seq=0
 greearb> Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=7004800 TSER=0 WS=10
 greearb>   29.439676 192.168.100.117 -> 172.16.0.100 TCP 44732 > 111 [SYN] Seq=0
 greearb> Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=7010816 TSER=0 WS=10
 greearb>   30.432383 192.168.100.117 -> 172.16.0.100 Portmap V2 GETPORT Call NFS(100003)
 greearb> V:3 UDP
 greearb>   31.433420 192.168.100.117 -> 172.16.0.100 Portmap [RPC retransmission of
 greearb> #10]V2 GETPORT Call NFS(100003) V:3 UDP
 greearb>   32.434458 192.168.100.117 -> 172.16.0.100 Portmap [RPC retransmission of
 greearb> #10]V2 GETPORT Call NFS(100003) V:3 UDP

 greearb> I need to make whatever is generating that traffic bind to a source IP.

It's hard to say what's "rigth" and "wrong" from just this tcpdump:
there is only one IP address.

Recently there was a change to libtirpc to fix IP address selection
for UDP datagrams:

http://git.infradead.org/users/steved/libtirpc.git/commit/74ef3df0236c55185225c62fba34953f2582da72

This is on the server side - it looks to me you're trying to deal with
client side so it may be irrelevant.

 >>> Also, the mount.nfs package, as I'll probably need to modify that
 >>> as well...
 >> 
 >> mount.nfs is in nfs-utils.

 greearb> What is the git repo for it, though?

http://git.infradead.org/users/steved/nfs-utils.git

 >>> I am going to try to allow portmapper to bind to a particular
 >>> source IP when making outbound requests....
 >> 
 >> I don't understand.  portmapper, as an RPC service, receives
 >> incoming requests.  But we don't use the rpcbind CALLIT procedure
 >> on Linux, thus it doesn't make outbound requests.

 greearb> I could easily be confused about where the problem lies.
 greearb> Any idea what is generating those requests on the nfs client
 greearb> above?

mount.nfs does.

max
