From: Jeff Davis <jdavis@hess.com>
Subject: Re: NFS digest, Vol 1 #1534 - 6 msgs
Date: 18 Jul 2003 14:13:50 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1058555629.2554.130.camel@oac195.ep.hess.com>
References: <E19dZUF-0007i6-00@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dagF-0006Ao-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Jul 2003 12:14:11 -0700
Received: from [63.105.228.197] (port=62101 helo=outside.ep.hess.com)
	by externalmx.vasoftware.com with smtp (Exim 4.20 #1 (Debian))
	id 19dag8-0000aI-F3
	for <nfs@lists.sourceforge.net>; Fri, 18 Jul 2003 12:14:04 -0700
Received: from oac195.ep.hess.com (oac195.ep.hess.com [192.168.1.21]) by mailhub.ep.hess.com (AIX4.2/UCB 8.7/8.7) with ESMTP id OAA42590 for <nfs@lists.sourceforge.net>; Fri, 18 Jul 2003 14:13:50 -0500 (CDT)
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
In-Reply-To: <E19dZUF-0007i6-00@sc8-sf-list2.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

upgrading to nfs-utils 1.05 seems to have helped


> --__--__--
> 
> Message: 6
> From: Jeff Davis <jdavis@hess.com>
> To: nfs@lists.sourceforge.net
> Date: 18 Jul 2003 12:31:25 -0500
> Subject: [NFS] round robin dns, multihomed host, nfs mounting issues
> 
> I'm testing out a NFS server which has two interfaces on two different
> subnets. I'm using a single hostname and round robin dns. Clients are
> both RedHat Linux systems.
> 
> I can access the primary interface on server via NFS from any system
> on
> my network. I can only access the second interface from hosts on the
> same subnet. Unfortunately, round robin dns on systems that are not
> local to subnets on either of the server's nics will randomly get one
> of
> the two nics to access nfs fs through. 
> 
> int 1 - 192.168.19.224
> int 2 - 172.25.2.106
> 
> # can mount through int 1 from any host\
> # can mount thoughh int 2 from same ip subnet as int 2
> # cannot mount throught int 2 from remote ip subnets
> # on local subnets, mounts work as desired through correct, optimal
> interface on nfs server
> 
> # on remote subnets, round robin directs ~50% of mount requests
> to server through int 2 which fail
> 
> why doesn't this work? doesn't even work if try to mount directly
> using ip addresses. additionally, have build tcp support in NFS
> servers
> kernel but get different error but scenarios appear to be same.
>  
> default gateway through int1, and system's hostname based on int1
> 
> -- NFS client on different subnet than either of the servers two nics
> 
> :/u/tdhf045> nslookup -sil oac195
> Server:         192.168.8.94
> Address:        192.168.8.94#53
> 
> Name:   oac195.ep.hess.com
> Address: 192.168.1.21
> 
> 
> -- Round Robin DNS for nfs server
> 
> :/u/tdhf045> nslookup -sil beo224.ihess.com
> Server:         192.168.8.94
> Address:        192.168.8.94#53
> 
> Name:   beo224.ihess.com
> Address: 192.168.19.224
> Name:   beo224.ihess.com
> Address: 172.25.2.106
> 
> -- Client can access server on both networks on NFS server
> 
> oac195:/u/tdhf045> traceroute beo224.ihess.com
> traceroute: Warning: beo224.ihess.com has multiple addresses; using
> 192.168.19.224
> traceroute to beo224.ihess.com (192.168.19.224), 30 hops max, 38 byte
> packets
>  1  sw0311 (192.168.1.249)  1.006 ms  0.625 ms  0.559 ms
>  2  oac21c (192.168.12.253)  0.542 ms  0.537 ms  0.593 ms
>  3  beo224.ihess.com (192.168.19.224)  0.613 ms  0.625 ms  0.508 ms
> oac195:/u/tdhf045> traceroute beo224.ihess.com
> traceroute: Warning: beo224.ihess.com has multiple addresses; using
> 172.25.2.106
> traceroute to beo224.ihess.com (172.25.2.106), 30 hops max, 38 byte
> packets
>  1  sw0311 (192.168.1.249)  1.248 ms  0.584 ms  0.566 ms
>  2  oac21c (192.168.12.253)  0.507 ms  0.675 ms  0.514 ms
>  3  beo224.ihess.com (172.25.2.106)  0.598 ms  0.541 ms  0.515 ms
> 
> 
> -- trying to mount filesystem
> 
> :/u/tdhf045> mount 192.168.19.224:/export/rsync /mnt
> :/u/tdhf045> umount /mnt
> 
> :/u/tdhf045> mount 172.25.2.106:/export/rsync /mnt
> mount: RPC: Timed out
> 
> :/u/tdhf045> mount -o tcp 172.25.2.106:/export/rsync /mnt
> nfs server reported service unavailable: Address already in use
> 
> :/u/tdhf045> mount beo224.ihess.com:/export/rsync /mnt
> :/u/tdhf045> mount beo224.ihess.com:/export/rsync2 /mnt2
> mount: RPC: Timed out
> :/u/tdhf045> mount | tail -1
> beo224.ihess.com:/export/rsync on /mnt type nfs
> (rw,addr=192.168.19.224)
> :/u/tdhf045> mount -o tcp  beo224.ihess.com:/export/rsync2 /mnt2
> :/u/tdhf045> mount | tail -2
> beo224.ihess.com:/export/rsync on /mnt type nfs
> (rw,addr=192.168.19.224)
> beo224.ihess.com:/export/rsync2 on /mnt2 type nfs
> (rw,tcp,addr=192.168.19.224)
> :/u/tdhf045> umount /mnt2
> :/u/tdhf045> mount -o tcp  beo224.ihess.com:/export/rsync2 /mnt2
> nfs server reported service unavailable: Address already in use
> 
> tcpdump of things on client (hacdsc001 is dns server)
> 
> [root@oac195 root]# tcpdump -vvv -r capt
> 13:05:57.561448 oac195.ep.hess.com.631 > beo224.ihess.com.sunrpc: S
> [tcp
> sum ok] 956382497:956382497(0) win 5840 <mss 1460,sackOK,timestamp
> 9309729 0,nop,wscale 0> (DF) (ttl 64, id 13056, len 60)
> 13:05:57.561707 beo224.ihess.com.sunrpc > oac195.ep.hess.com.631: S
> [tcp
> sum ok] 947522422:947522422(0) ack 956382498 win 5792 <mss
> 1460,sackOK,timestamp 2394356 9309729,nop,wscale 0> (DF) (ttl 62, id
> 0,
> len 60)
> 13:05:57.561765 oac195.ep.hess.com.631 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 1:1(0) ack 1 win 5840 <nop,nop,timestamp 9309729 2394356> (DF)
> (ttl 64, id 13057, len 52)
> 13:05:57.562427 oac195.ep.hess.com.631 > beo224.ihess.com.sunrpc: P
> 1:45(44) ack 1 win 5840 <nop,nop,timestamp 9309729 2394356> (DF) (ttl
> 64, id 13058, len 96)
> 13:05:57.562653 beo224.ihess.com.sunrpc > oac195.ep.hess.com.631: .
> [tcp
> sum ok] 1:1(0) ack 45 win 5792 <nop,nop,timestamp 2394357 9309729>
> (DF)
> (ttl 62, id 33666, len 52)
> 13:05:57.563067 beo224.ihess.com.sunrpc > oac195.ep.hess.com.631: P
> 1:401(400) ack 45 win 5792 <nop,nop,timestamp 2394357 9309729> (DF)
> (ttl
> 62, id 33667, len 452)
> 13:05:57.563112 oac195.ep.hess.com.631 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 45:45(0) ack 401 win 6432 <nop,nop,timestamp 9309730 2394357>
> (DF) (ttl 64, id 13059, len 52)
> 13:05:57.563370 beo224.ihess.com.sunrpc > oac195.ep.hess.com.631: P
> 401:517(116) ack 45 win 5792 <nop,nop,timestamp 2394357 9309730> (DF)
> (ttl 62, id 33668, len 168)
> 13:05:57.563397 oac195.ep.hess.com.631 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 45:45(0) ack 517 win 6432 <nop,nop,timestamp 9309730 2394357>
> (DF) (ttl 64, id 13060, len 52)
> 13:05:57.563541 oac195.ep.hess.com.631 > beo224.ihess.com.sunrpc: F
> [tcp
> sum ok] 45:45(0) ack 517 win 6432 <nop,nop,timestamp 9309730 2394357>
> (DF) (ttl 64, id 13061, len 52)
> 13:05:57.563753 beo224.ihess.com.sunrpc > oac195.ep.hess.com.631: F
> [tcp
> sum ok] 517:517(0) ack 46 win 5792 <nop,nop,timestamp 2394357 9309730>
> (DF) (ttl 62, id 33669, len 52)
> 13:05:57.563788 oac195.ep.hess.com.631 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 46:46(0) ack 518 win 6432 <nop,nop,timestamp 9309730 2394357>
> (DF) (ttl 64, id 13062, len 52)
> 13:05:57.564273 oac195.ep.hess.com.632 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:00.573228 oac195.ep.hess.com.632 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:03.583306 oac195.ep.hess.com.632 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:06.593368 oac195.ep.hess.com.632 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:09.603466 oac195.ep.hess.com.632 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:12.613555 oac195.ep.hess.com.632 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:15.623927 oac195.ep.hess.com.632 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:21.233245 oac195.ep.hess.com.32828 >
> hacssdc001.ihess.com.domain: 
> [udp sum ok] 2497+ PTR? 89.1.25.172.in-addr.arpa. [|domain] (DF) (ttl
> 64, id 5984, len 70)
> 13:06:21.234162 hacssdc001.ihess.com.domain >
> oac195.ep.hess.com.32828: 
> 2497 NXDomain* q: PTR? 89.1.25.172.in-addr.arpa. 0/1/0 ns: 172.in-addr
> (120) (ttl 126, id 51967, len 148)
> 13:06:23.076964 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: S
> [tcp
> sum ok] 979826568:979826568(0) win 5840 <mss 1460,sackOK,timestamp
> 9312281 0,nop,wscale 0> (DF) (ttl 64, id 61329, len 60)
> 13:06:23.077829 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: S
> [tcp
> sum ok] 994347360:994347360(0) ack 979826569 win 5792 <mss
> 1460,sackOK,timestamp 2407423 9312281,nop,wscale 0> (DF) (ttl 62, id
> 0,
> len 60)
> 13:06:23.077890 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 1:1(0) ack 1 win 5840 <nop,nop,timestamp 9312281 2407423> (DF)
> (ttl 64, id 61330, len 52)
> 13:06:23.078094 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: P
> 1:45(44) ack 1 win 5840 <nop,nop,timestamp 9312281 2407423> (DF) (ttl
> 64, id 61331, len 96)
> 13:06:23.078407 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: .
> [tcp
> sum ok] 1:1(0) ack 45 win 5792 <nop,nop,timestamp 2407424 9312281>
> (DF)
> (ttl 62, id 13665, len 52)
> 13:06:23.078892 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: P
> 1:401(400) ack 45 win 5792 <nop,nop,timestamp 2407424 9312281> (DF)
> (ttl
> 62, id 13666, len 452)
> 13:06:23.078928 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 45:45(0) ack 401 win 6432 <nop,nop,timestamp 9312281 2407424>
> (DF) (ttl 64, id 61332, len 52)
> 13:06:23.079184 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: P
> 401:517(116) ack 45 win 5792 <nop,nop,timestamp 2407424 9312281> (DF)
> (ttl 62, id 13667, len 168)
> 13:06:23.079214 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 45:45(0) ack 517 win 6432 <nop,nop,timestamp 9312281 2407424>
> (DF) (ttl 64, id 61333, len 52)
> 13:06:23.079312 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: F
> [tcp
> sum ok] 45:45(0) ack 517 win 6432 <nop,nop,timestamp 9312281 2407424>
> (DF) (ttl 64, id 61334, len 52)
> 13:06:23.079541 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: F
> [tcp
> sum ok] 517:517(0) ack 46 win 5792 <nop,nop,timestamp 2407424 9312281>
> (DF) (ttl 62, id 13668, len 52)
> 13:06:23.079593 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 46:46(0) ack 518 win 6432 <nop,nop,timestamp 9312281 2407424>
> (DF) (ttl 64, id 61335, len 52)
> 13:06:23.079669 oac195.ep.hess.com.930 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:23.085816 beo224.ihess.com.32801 > oac195.ep.hess.com.930:  udp
> 56
> (DF) (ttl 62, id 0, len 84)
> 13:06:23.085993 oac195.ep.hess.com.932 > beo224.ihess.com.sunrpc:  udp
> 56 (DF) (ttl 64, id 0, len 84)
> 13:06:23.086453 beo224.ihess.com.sunrpc > oac195.ep.hess.com.932: 
> [udp
> sum ok] udp 28 (DF) (ttl 62, id 0, len 56)
> 13:06:23.086774 oac195.ep.hess.com.2754784087 > beo224.ihess.com.nfs:
> 112 getattr [|nfs] (DF) (ttl 64, id 0, len 140)
> 13:06:23.087083 beo224.ihess.com.nfs > oac195.ep.hess.com.2754784087:
> reply ok 112 getattr DIR 40755 ids 0/0 [|nfs] (DF) (ttl 62, id 0, len
> 140)
> 13:06:23.087182 oac195.ep.hess.com.2771561303 > beo224.ihess.com.nfs:
> 112 fsstat [|nfs] (DF) (ttl 64, id 0, len 140)
> 13:06:23.088137 beo224.ihess.com.nfs > oac195.ep.hess.com.2771561303:
> reply ok 84 fsstat POST: [|nfs] (DF) (ttl 62, id 0, len 112)
> 13:06:23.088211 oac195.ep.hess.com.2788338519 > beo224.ihess.com.nfs:
> 112 fsinfo [|nfs] (DF) (ttl 64, id 0, len 140)
> 13:06:23.088838 beo224.ihess.com.nfs > oac195.ep.hess.com.2788338519:
> reply ok 80 fsinfo POST: [|nfs] (DF) (ttl 62, id 0, len 108)
> 13:06:24.778127 oac195.ep.hess.com.2855447383 > beo224.ihess.com.nfs:
> 144 getattr [|nfs] (DF) (ttl 64, id 0, len 172)
> 13:06:24.778522 beo224.ihess.com.nfs > oac195.ep.hess.com.2855447383:
> reply ok 112 getattr DIR 40755 ids 0/0 [|nfs] (DF) (ttl 62, id 0, len
> 140)
> 13:06:29.312363 oac195.ep.hess.com.931 > beo224.ihess.com.sunrpc:  udp
> 56 (DF) (ttl 64, id 0, len 84)
> 13:06:29.312815 beo224.ihess.com.sunrpc > oac195.ep.hess.com.931: 
> [udp
> sum ok] udp 28 (DF) (ttl 62, id 0, len 56)
> 13:06:29.313040 oac195.ep.hess.com.932 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 64, id 0, len 144)
> 13:06:29.320408 beo224.ihess.com.32801 > oac195.ep.hess.com.932:  [udp
> sum ok] udp 24 (DF) (ttl 62, id 0, len 52)
> 
> tcpdump of things on server (hacssdc001 is dns server)
> 
> [root@beo224 nfs]# tcpdump -vvv -r capt
> 13:05:58.043283 beo224.ihess.com.sunrpc > oac195.ep.hess.com.ipp: S
> [tcp
> sum ok] 947522422:947522422(0) ack 956382498 win 5792 <mss
> 1460,sackOK,timestamp 2394356 9309729,nop,wscale 0> (DF) (ttl 64, id
> 0,
> len 60)
> 13:05:58.044239 beo224.ihess.com.sunrpc > oac195.ep.hess.com.ipp: .
> [tcp
> sum ok] 1:1(0) ack 45 win 5792 <nop,nop,timestamp 2394357 9309729>
> (DF)
> (ttl 64, id 33666, len 52)
> 13:05:58.044502 beo224.ihess.com.sunrpc > oac195.ep.hess.com.ipp: P
> 1:401(400) ack 45 win 5792 <nop,nop,timestamp 2394357 9309729> (DF)
> (ttl
> 64, id 33667, len 452)
> 13:05:58.044904 beo224.ihess.com.sunrpc > oac195.ep.hess.com.ipp: P
> 401:517(116) ack 45 win 5792 <nop,nop,timestamp 2394357 9309730> (DF)
> (ttl 64, id 33668, len 168)
> 13:05:58.045343 beo224.ihess.com.sunrpc > oac195.ep.hess.com.ipp: F
> [tcp
> sum ok] 517:517(0) ack 46 win 5792 <nop,nop,timestamp 2394357 9309730>
> (DF) (ttl 64, id 33669, len 52)
> 13:05:58.046899 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47351+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 35062, len 71)
> 13:05:58.047153 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47351* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 48803, len 103)
> 13:05:58.047842 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47352+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 35063, len 64)
> 13:05:58.048068 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47352* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 48804, len 80)
> 13:06:01.056635 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47353+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 36603, len 71)
> 13:06:01.057847 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47353* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 49305, len 103)
> 13:06:01.058538 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47354+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 36604, len 64)
> 13:06:01.059201 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47354* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 49307, len 80)
> 13:06:04.066909 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47355+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 38145, len 71)
> 13:06:04.067164 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47355* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 50033, len 103)
> 13:06:04.067793 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47356+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 38145, len 64)
> 13:06:04.068032 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47356* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 50034, len 80)
> 13:06:07.077610 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47357+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 39686, len 71)
> 13:06:07.078048 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47357* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 50381, len 103)
> 13:06:07.078786 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47358+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 39687, len 64)
> 13:06:07.079025 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47358* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 50382, len 80)
> 13:06:10.087895 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47359+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 41228, len 71)
> 13:06:10.088319 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47359* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 50720, len 103)
> 13:06:10.088973 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47360+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 41228, len 64)
> 13:06:10.089212 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47360* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 50721, len 80)
> 13:06:13.098586 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47361+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 42769, len 71)
> 13:06:13.099110 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47361* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 50994, len 103)
> 13:06:13.099788 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47362+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 42770, len 64)
> 13:06:13.100026 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47362* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 50995, len 80)
> 13:06:16.109364 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47363+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 44311, len 71)
> 13:06:16.109690 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47363* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 51280, len 103)
> 13:06:16.110378 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47364+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 44311, len 64)
> 13:06:16.110654 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47364* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 51282, len 80)
> 13:06:23.562731 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: S
> [tcp
> sum ok] 979826568:979826568(0) win 5840 <mss 1460,sackOK,timestamp
> 9312281 0,nop,wscale 0> (DF) (ttl 62, id 61329, len 60)
> 13:06:23.562807 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: S
> [tcp
> sum ok] 994347360:994347360(0) ack 979826569 win 5792 <mss
> 1460,sackOK,timestamp 2407423 9312281,nop,wscale 0> (DF) (ttl 64, id
> 0,
> len 60)
> 13:06:23.563629 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 1:1(0) ack 1 win 5840 <nop,nop,timestamp 9312281 2407423> (DF)
> (ttl 62, id 61330, len 52)
> 13:06:23.563898 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: P
> 1:45(44) ack 1 win 5840 <nop,nop,timestamp 9312281 2407423> (DF) (ttl
> 62, id 61331, len 96)
> 13:06:23.563924 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: .
> [tcp
> sum ok] 1:1(0) ack 45 win 5792 <nop,nop,timestamp 2407424 9312281>
> (DF)
> (ttl 64, id 13665, len 52)
> 13:06:23.564163 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: P
> 1:401(400) ack 45 win 5792 <nop,nop,timestamp 2407424 9312281> (DF)
> (ttl
> 64, id 13666, len 452)
> 13:06:23.564642 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 45:45(0) ack 401 win 6432 <nop,nop,timestamp 9312281 2407424>
> (DF) (ttl 62, id 61332, len 52)
> 13:06:23.564660 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: P
> 401:517(116) ack 45 win 5792 <nop,nop,timestamp 2407424 9312281> (DF)
> (ttl 64, id 13667, len 168)
> 13:06:23.564910 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 45:45(0) ack 517 win 6432 <nop,nop,timestamp 9312281 2407424>
> (DF) (ttl 62, id 61333, len 52)
> 13:06:23.565012 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: F
> [tcp
> sum ok] 45:45(0) ack 517 win 6432 <nop,nop,timestamp 9312281 2407424>
> (DF) (ttl 62, id 61334, len 52)
> 13:06:23.565054 beo224.ihess.com.sunrpc > oac195.ep.hess.com.929: F
> [tcp
> sum ok] 517:517(0) ack 46 win 5792 <nop,nop,timestamp 2407424 9312281>
> (DF) (ttl 64, id 13668, len 52)
> 13:06:23.565284 oac195.ep.hess.com.929 > beo224.ihess.com.sunrpc: .
> [tcp
> sum ok] 46:46(0) ack 518 win 6432 <nop,nop,timestamp 9312281 2407424>
> (DF) (ttl 62, id 61335, len 52)
> 13:06:23.565392 oac195.ep.hess.com.930 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 62, id 0, len 144)
> 13:06:23.566243 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47365+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 48129, len 71)
> 13:06:23.566703 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47365* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 52118, len 103)
> 13:06:23.567432 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47366+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 48130, len 64)
> 13:06:23.567695 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47366* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 52119, len 80)
> 13:06:23.571317 beo224.ihess.com.32801 > oac195.ep.hess.com.930:  udp
> 56
> (DF) (ttl 64, id 0, len 84)
> 13:06:23.571704 oac195.ep.hess.com.932 > beo224.ihess.com.sunrpc:  udp
> 56 (DF) (ttl 62, id 0, len 84)
> 13:06:23.571965 beo224.ihess.com.sunrpc > oac195.ep.hess.com.932: 
> [udp
> sum ok] udp 28 (DF) (ttl 64, id 0, len 56)
> 13:06:23.572500 oac195.ep.hess.com.2754784087 > beo224.ihess.com.nfs:
> 112 getattr [|nfs] (DF) (ttl 62, id 0, len 140)
> 13:06:23.572563 beo224.ihess.com.nfs > oac195.ep.hess.com.2754784087:
> reply ok 112 getattr DIR 40755 ids 0/0 [|nfs] (DF) (ttl 64, id 0, len
> 140)
> 13:06:23.573032 oac195.ep.hess.com.2771561303 > beo224.ihess.com.nfs:
> 112 fsstat [|nfs] (DF) (ttl 62, id 0, len 140)
> 13:06:23.573623 beo224.ihess.com.nfs > oac195.ep.hess.com.2771561303:
> reply ok 84 fsstat POST: [|nfs] (DF) (ttl 64, id 0, len 112)
> 13:06:23.574057 oac195.ep.hess.com.2788338519 > beo224.ihess.com.nfs:
> 112 fsinfo [|nfs] (DF) (ttl 62, id 0, len 140)
> 13:06:23.574079 beo224.ihess.com.nfs > oac195.ep.hess.com.2788338519:
> reply ok 80 fsinfo POST: (DF) (ttl 64, id 0, len 108)
> 13:06:25.264215 oac195.ep.hess.com.2855447383 > beo224.ihess.com.nfs:
> 144 getattr [|nfs] (DF) (ttl 62, id 0, len 172)
> 13:06:25.264244 beo224.ihess.com.nfs > oac195.ep.hess.com.2855447383:
> reply ok 112 getattr DIR 40755 ids 0/0 [|nfs] (DF) (ttl 64, id 0, len
> 140)
> 13:06:29.799039 oac195.ep.hess.com.931 > beo224.ihess.com.sunrpc:  udp
> 56 (DF) (ttl 62, id 0, len 84)
> 13:06:29.799283 beo224.ihess.com.sunrpc > oac195.ep.hess.com.931: 
> [udp
> sum ok] udp 28 (DF) (ttl 64, id 0, len 56)
> 13:06:29.799730 oac195.ep.hess.com.932 > beo224.ihess.com.32801:  udp
> 116 (DF) (ttl 62, id 0, len 144)
> 13:06:29.800530 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47367+ PTR? 21.1.168.192.in-addr.arpa. [|domain] (DF)
> (ttl
> 64, id 51321, len 71)
> 13:06:29.800938 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> 47367* q: PTR? 21.1.168.192.in-addr.arpa. 1/0/0
> 21.1.168.192.in-addr.arpa. (75) (ttl 125, id 54088, len 103)
> 13:06:29.801586 beo224.ihess.com.32807 > hacssdc001.ihess.com.domain: 
> [udp sum ok] 47368+ A? oac195.ep.hess.com. [|domain] (DF) (ttl 64, id
> 51322, len 64)
> 13:06:29.801866 hacssdc001.ihess.com.domain > beo224.ihess.com.32807: 
> [udp sum ok] 47368* q: A? oac195.ep.hess.com. 1/0/0
> oac195.ep.hess.com.
> A oac195.ep.hess.com (52) (ttl 125, id 54089, len 80)
> 13:06:29.806875 beo224.ihess.com.32801 > oac195.ep.hess.com.932:  [udp
> sum ok] udp 24 (DF) (ttl 64, id 0, len 52)
> 
> 
> on server
> 
> [root@beo224 root]# rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100021    1   udp  32769  nlockmgr
>     100021    3   udp  32769  nlockmgr
>     100021    4   udp  32769  nlockmgr
>     100021    1   tcp  32769  nlockmgr
>     100021    3   tcp  32769  nlockmgr
>     100021    4   tcp  32769  nlockmgr
>     100007    2   udp    911  ypbind
>     100007    1   udp    911  ypbind
>     100007    2   tcp    915  ypbind
>     100007    1   tcp    915  ypbind
>     391002    2   tcp  32770  sgi_fam
>     100011    1   udp    991  rquotad
>     100011    2   udp    991  rquotad
>     100011    1   tcp    994  rquotad
>     100011    2   tcp    994  rquotad
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100005    1   udp  32770  mountd
>     100005    1   tcp  32771  mountd
>     100005    2   udp  32770  mountd
>     100005    2   tcp  32771  mountd
>     100005    3   udp  32770  mountd
>     100005    3   tcp  32771  mountd
> 
> 
> 
> server is running latest nfs-utils rpm for redhat 8.0
>  193453 Jul 09 12:50 nfs-utils-1.0.1-2.80.i386.rpm
> 
> ill be glad to provide any additional info
> 
> thanks
> 
> -- 
> 
> Jeff Davis
> Amerada Hess Corporation
> Global IT Technical Computing Infrastructure
> Houston, Texas
> jdavis@hess.com
> Office: 713-609-5436
> Mobile: 281-467-9448
> http://www.jrdavis.net/
> 
> 
> 
> 
> --__--__--
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 
> End of NFS Digest
-- 

Jeff Davis
Amerada Hess Corporation
Global IT Technical Computing Infrastructure
Houston, Texas
jdavis@hess.com
Office: 713-609-5436
Mobile: 281-467-9448
http://www.jrdavis.net/



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
