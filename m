From: Juergen Rose <rose@rz.uni-potsdam.de>
Subject: Strange NFS respectively rpcinfo problem
Date: Sun, 11 Jul 2004 10:31:39 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.58.0407110136400.22650@persius.rz.uni-potsdam.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BjZki-0000rJ-AI
	for nfs@lists.sourceforge.net; Sun, 11 Jul 2004 01:32:04 -0700
Received: from hp.rz.uni-potsdam.de ([141.89.64.1])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BjZkh-00016s-I8
	for nfs@lists.sourceforge.net; Sun, 11 Jul 2004 01:32:04 -0700
Received: from localhost (localhost [127.0.0.1])
	by hp.rz.uni-potsdam.de (8.12.10/8.12.10) with ESMTP id i6B8W0fR006350
	for <nfs@lists.sourceforge.net>; Sun, 11 Jul 2004 10:32:00 +0200 (MET DST)
Received: from hp.rz.uni-potsdam.de ([127.0.0.1])
 by localhost (hp [127.0.0.1]) (amavisd-new, port 10024) with LMTP id 01323-19
 for <nfs@lists.sourceforge.net>; Sun, 11 Jul 2004 10:31:56 +0200 (MET DST)
Received: from persius.rz.uni-potsdam.de (persius.rz.uni-potsdam.de [141.89.68.1])
	by hp.rz.uni-potsdam.de (8.12.10/8.12.10) with ESMTP id i6B8VtsB006310
	for <nfs@lists.sourceforge.net>; Sun, 11 Jul 2004 10:31:55 +0200 (MET DST)
Received: from localhost (localhost [127.0.0.1])
	by persius.rz.uni-potsdam.de (8.12.11/8.12.11) with ESMTP id i6B8VvpD009729
	for <nfs@lists.sourceforge.net>; Sun, 11 Jul 2004 10:31:57 +0200 (CEST)
Received: from persius.rz.uni-potsdam.de ([127.0.0.1])
 by localhost (persius [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 08895-02 for <nfs@lists.sourceforge.net>;
 Sun, 11 Jul 2004 10:31:54 +0200 (CEST)
Received: from persius.rz.uni-potsdam.de (persius.rz.uni-potsdam.de [141.89.68.1])
	by persius.rz.uni-potsdam.de (8.12.11/8.12.11) with ESMTP id i6B8Vd8R009637
	for <nfs@lists.sourceforge.net>; Sun, 11 Jul 2004 10:31:39 +0200 (CEST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi all,

I have have four PCs in my network *.bioinf, let us call them server1,
server2, client1 and client2 all with linux-2.6.7.
In /etc/exports at server1 and server2 I have the line:
/home *.bioinf(sync,rw,nohide)

The mounting of server1:/home works perfectly from client1.bionf but It
does not work from client2.bionf.
The mounting of server2:home works perfectly from client1.bionf and
client2.bioinf. I found that this behaviour is correlated  with strange
behaviour of rpcinfo

Performing 'rpcinfo -p server1' and 'rpcinfo -p server2' gives the same
result on client1 and client2:

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100021    1   tcp  32769  nlockmgr
    100021    3   tcp  32769  nlockmgr
    100021    4   tcp  32769  nlockmgr
    100005    1   udp    908  mountd
    100005    1   tcp    911  mountd
    100005    2   udp    908  mountd
    100005    2   tcp    911  mountd
    100005    3   udp    908  mountd
    100005    3   tcp    911  mountd

So I see that the NFS service is running at both servers.
But if I try 'rpcinfo -u server1' at client2, I get:
rpcinfo: RPC: Timed out
program 100003 version 0 is not available

What can cause this timeout?

'rpcinfo -u server2'at client2 gives as expected:
program 100003 version 2 ready and waiting
program 100003 version 3 ready and waiting
program 100003 version 4 ready and waiting

At client2 'rpcinfo -u server1' and 'rpcinfo -u server2' gives also the
expected:
program 100003 version 2 ready and waiting
program 100003 version 3 ready and waiting
program 100003 version 4 ready and waiting

What could be the reason for this strange behaviour of rpcinfo at client2?
Could it be, that it is physical network problem, although I can
establish ssh connections between all PCs, without any problem?
In server1 there is a 3c940 controller running with sk98lin module. Neither
mii-diag nor ethtool gives information about the eth0 interface.
server1:/root(14)# ethtool eth0
Settings for eth0:
No data available
server1:/root(15)# mii-diag eth0
SIOCGMIIPHY on eth0 failed: Bad address

In client1 is a Intel 82557/8/9 controler running with e1000 module.
client1:/root(11)# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: umbg
        Wake-on: g
        Link detected: yes

client1:/root(13)# mii-diag eth0
Basic registers of MII PHY #0:  1140 796d 0141 0c23 0de1 45e1 0007 2001.
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x1140: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx
10baseT-FD 10baseT, w/ 802.3X flow control.

In client2 there is Intel 82540EM controller also running with e1000
module.
client2:/root(42)# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: umbg
        Wake-on: g
        Current message level: 0x00000007 (7)
        Link detected: yes

client2:/root(43)# mii-diag eth0
Basic registers of MII PHY #0:  1140 796d 0141 0c23 0de1 45e1 0005 2001.
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x1140: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx
10baseT-FD 10baseT, w/ 802.3X flow control.

I.e., I have Gigabit controllers hanging at 100MBit/s switch.

In server2 there is a 3C905 controler:
server2:root(2)# mii-diag eth0
Basic registers of MII PHY #24:  3000 782d 0041 6800 05e1 45e1 0017 2801.
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x3000: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx
10baseT-
FD 10baseT, w/ 802.3X flow control.
   End of basic transceiver information.

server2:/root(3)# ethtool eth0
Settings for eth0:
No data available

    Waiting for hints
          Juergen

PS.: Please send your mails also to my private email address, I am new
to this list


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
