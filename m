From: =?UTF-8?Q?=E6=9C=B1?= =?UTF-8?Q?=E6=88=90?= <zhucheng@longcheer.net>
Subject: nfs mount failed
Date: Mon, 09 May 2005 10:49:34 +0800
Message-ID: <1115606974.10065.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DUyJ7-0004Tv-Bg
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 19:47:45 -0700
Received: from [211.160.165.126] (helo=lctmail.longcheertel.com.cn)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DUyJ4-00030K-NZ
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 19:47:44 -0700
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

hi,all

i used u-boot to boot uImage from ram, and the kernel boot successed and
mounted nfs fs!
and i wanted to boot uImage from falsh, and did:
1.	tftp 0x10000000	(0x10000000 is ram address)
2.	erase 0x100000 0x3fffff (0x100000--0x3fffff is flash room)
3.	cp.b 0x10000000 0x100000 $(fileszie)
4. 	bootm 0x100000

the kernel boot successed and mounted nfs fs!(i used tcpdump on server
and found packages from my board) but if i rebooted, and "bootm
0x100000", the kernel stoped when mounted nfsroot fs.
the boot information was:
..............................
<6>Freeing initrd memory: 4096K
Freeing initrd memory: 4096K
<5>Looking up port of RPC 100003/2 on 172.16.6.79
Looking up port of RPC 100003/2 on 172.16.6.79

(172.16.6.79 is nfsroot server)

i used tcpdump on my nfsroot server, and found no package from my board

so, what's wrong with it?

thank you!




-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
