From: "Vinay A. Mahadik" <devnull001@fastmail.fm>
Subject: Code Query: Frustrating ERR_ACCESS error with rpc.mountd while mounting.
Date: Wed, 13 Aug 2003 19:40:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F3AF699.300@fastmail.fm>
References: <E19n6s4-0000z4-00@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail01.qualys.com ([12.162.2.5])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19n7eU-0001G7-00
	for <nfs@lists.sourceforge.net>; Wed, 13 Aug 2003 19:15:46 -0700
To: nfs@lists.sourceforge.net
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

I have been trying to add code to our RPC library (for a scanner) to
MOUNT remote directories. While DUMP, EXPORT, and other calls work just
fine, I am consistently getting an ERR_ACCESS (0x0d) permission denied. 
The confusing thing is:

- I have checked the server side config, infact, using "mount" directly
from the same IP works just fine
- /etc/exports is just "/tmp/tmp -ro"
- The following show the network packets from "mount" and my code -
quite identical I guess.

Is there something I am missing? I have spent several hours trying to
debug this stuff with no progress.

Any hints/input will be greatly appreciated!

Thanks,
Vinay.


----------------From Mount Util----------------
User Datagram Protocol, Src Port: 664 (664), Dst Port: 797 (797)
     Source port: 664 (664)
     Destination port: 797 (797)
     Length: 132
     Checksum: 0xf3af (correct)
Remote Procedure Call
     XID: 0x6e24e176 (1847910774)
     Message Type: Call (0)
     RPC Version: 2
     Program: MOUNT (100005)
     Program Version: 1
     Procedure: MNT (1)
     Credentials
         Flavor: AUTH_UNIX (1)
         Length: 72
         Stamp: 0x3f3af09b
         Machine Name: localhost.localdomain
             length: 21
             contents: localhost.localdomain
             fill bytes: opaque data
         UID: 0
         GID: 0
         Auxiliary GIDs
             GID: 0
             GID: 1
             GID: 2
             GID: 3
             GID: 4
             GID: 6
             GID: 10
     Verifier
         Flavor: AUTH_NULL (0)
         Length: 0
Mount Service
     Program Version: 1
     V1 Procedure: MNT (1)
     Path: /tmp/tmp
         length: 8
         contents: /tmp/tmp

0000  00 02 b3 b8 41 c6 00 04 76 d4 1c fb 08 00 45 00   ....A...v.....E.
0010  00 98 00 00 40 00 40 11 10 28 0a 64 0b 2f 0a 0a   ....@.@..(.d./..
0020  0a 91 02 98 03 1d 00 84 f3 af 6e 24 e1 76 00 00   ..........n$.v..
0030  00 00 00 00 00 02 00 01 86 a5 00 00 00 01 00 00   ................
0040  00 01 00 00 00 01 00 00 00 48 3f 3a f0 9b 00 00   .........H?:....
0050  00 15 6c 6f 63 61 6c 68 6f 73 74 2e 6c 6f 63 61   ..localhost.loca
0060  6c 64 6f 6d 61 69 6e 00 00 00 00 00 00 00 00 00   ldomain.........
0070  00 00 00 00 00 07 00 00 00 00 00 00 00 01 00 00   ................
0080  00 02 00 00 00 03 00 00 00 04 00 00 00 06 00 00   ................
0090  00 0a 00 00 00 00 00 00 00 00 00 00 00 08 2f 74   ............../t
00a0  6d 70 2f 74 6d 70                                 mp/tmp
----------------From Mount Util----------------

-----------------From My Code------------------
User Datagram Protocol, Src Port: 50188 (50188), Dst Port: 797 (797)
     Source port: 50188 (50188)
     Destination port: 797 (797)
     Length: 140
     Checksum: 0xe689 (correct)
Remote Procedure Call
     XID: 0x7c4d2d8b (2085432715)
     Message Type: Call (0)
     RPC Version: 2
     Program: MOUNT (100005)
     Program Version: 1
     Procedure: MNT (1)
     Credentials
         Flavor: AUTH_UNIX (1)
         Length: 80
         Stamp: 0x3f3aec36
         Machine Name: localhost.localdomain
             length: 21
             contents: localhost.localdomain
             fill bytes: opaque data
         UID: 0
         GID: 0
         Auxiliary GIDs
             GID: 0
             GID: 1
             GID: 2
             GID: 3
             GID: 4
             GID: 6
             GID: 10
             GID: 11
             GID: 0
     Verifier
         Flavor: AUTH_NULL (0)
         Length: 0
Mount Service
     Program Version: 1
     V1 Procedure: MNT (1)
     Path: /tmp/tmp
         length: 8
         contents: /tmp/tmp

0000  00 02 b3 b9 94 d4 00 e0 81 04 54 1a 08 00 45 00   ..........T...E.
0010  00 a0 35 95 40 00 40 11 e4 d6 0a 28 01 1f 0a 0a   ..5.@.@....(....
0020  0a 91 c4 0c 03 1d 00 8c e6 89 7c 4d 2d 8b 00 00   ..........|M-...
0030  00 00 00 00 00 02 00 01 86 a5 00 00 00 01 00 00   ................
0040  00 01 00 00 00 01 00 00 00 50 3f 3a ec 36 00 00   .........P?:.6..
0050  00 15 6c 6f 63 61 6c 68 6f 73 74 2e 6c 6f 63 61   ..localhost.loca
0060  6c 64 6f 6d 61 69 6e 00 00 00 00 00 00 00 00 00   ldomain.........
0070  00 00 00 00 00 09 00 00 00 00 00 00 00 01 00 00   ................
0080  00 02 00 00 00 03 00 00 00 04 00 00 00 06 00 00   ................
0090  00 0a 00 00 00 0b 00 00 00 00 00 00 00 00 00 00   ................
00a0  00 00 00 00 00 08 2f 74 6d 70 2f 74 6d 70         ....../tmp/tmp
-----------------From My Code------------------

--------------From rpc.mountd log on HP-UX--------

03.08.13 04:00:23  hpux.vul  pid=23516  /usr/sbin/rpc.mountd
      mnt: SOP
03.08.13 04:00:23  hpux.vul  pid=23516  /usr/sbin/rpc.mountd
      mnt: MOUNTPROC_MNT called
03.08.13 04:00:23  hpux.vul  pid=23516  /usr/sbin/rpc.mountd
      mount: mount request from  denied: Permission denied
03.08.13 04:00:23  hpux.vul  pid=23516  /usr/sbin/rpc.mountd
      mnt check_exit returned
03.08.13 04:00:23  hpux.vul  pid=23516  /usr/sbin/rpc.mountd
      mnt: SOP

--------------From rpc.mountd log on HP-UX--------



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
