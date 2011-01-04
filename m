Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from earth.cora.nwra.com ([65.44.101.180]:53533 "EHLO
	earth.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab1ADRhm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 12:37:42 -0500
Received: from [192.168.0.39] (orca.cora.nwra.com [192.168.0.39])
	(authenticated bits=0)
	by earth.cora.nwra.com (8.13.8/8.13.8) with ESMTP id p04HRtMU008517
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 4 Jan 2011 10:27:58 -0700
Message-ID: <4D23589B.6030409@cora.nwra.com>
Date: Tue, 04 Jan 2011 10:27:55 -0700
From: Orion Poplawski <orion@cora.nwra.com>
To: linux-nfs@vger.kernel.org
Subject: Trouble mounting from EL5.5 server on Fedora 14 - gss_kerberos_mech:
 unsupported algorithm 6
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm trying to get kerberized NFSv4 setup for the first time (have had 
non-secure v4 up for a while).  Client is Fedora 14, server is CentOS 5.5.  I 
get the following in the server log:

kernel: gss_kerberos_mech: unsupported algorithm 6

The mount command returns:

[root@orca ~]# mount -t nfs4 -o sec=krb5 saga:/ /mnt
mount.nfs4: access denied by server while mounting saga:/

rpc.svcgssd reports:

readline: read 1230 chars into buffer of size 2048:
\x 
\x6082026006092a864886f71201020201006e82024f3082024ba003020105a10302010ea20703050020000000a382012e6182012a30820126a003020105a10f1b0d434f52412e4e5752412e434f4da2243022a003020103a11b30191b036e66731b12736167612e636f72612e6e7772612e636f6da381e73081e4a003020110a103020103a281d70481d48767f98fcbdf10bc38542e3ba0c24671c0bcbce028a5711ba7098eabcfeef49280eb91dcb8aa0f3e15f6b5546f637150e4707eb37b48c2126ced175a40b0642d2325cae66e1b45a9469a47577187c5cf50...
in_handle:
length 0

in_tok:
length 612

   0000: 6082 0260 0609 2a86 4886 f712 0102 0201  `..`..*.H.......
   0010: 006e 8202 4f30 8202 4ba0 0302 0105 a103  .n..O0..K.......
   0020: 0201 0ea2 0703 0500 2000 0000 a382 012e  ........ .......
   0030: 6182 012a 3082 0126 a003 0201 05a1 0f1b  a..*0..&........
   0040: 0d43 4f52 412e 4e57 5241 2e43 4f4d a224  .CORA.NWRA.COM.$
   0050: 3022 a003 0201 03a1 1b30 191b 036e 6673  0".......0...nfs
   0060: 1b12 7361 6761 2e63 6f72 612e 6e77 7261  ..saga.cora.nwra
   0070: 2e63 6f6d a381 e730 81e4 a003 0201 10a1  .com...0........
   0080: 0302 0103 a281 d704 81d4 8767 f98f cbdf  ...........g....
   0090: 10bc 3854 2e3b a0c2 4671 c0bc bce0 28a5  ..8T.;..Fq....(.
   00a0: 711b a709 8eab cfee f492 80eb 91dc b8aa  q...............
   00b0: 0f3e 15f6 b554 6f63 7150 e470 7eb3 7b48  .>...TocqP.p~.{H
   00c0: c212 6ced 175a 40b0 642d 2325 cae6 6e1b  ..l..Z@.d-#%..n.
   00d0: 45a9 469a 4757 7187 c5cf 50c2 7e13 e712  E.F.GWq...P.~...
   00e0: d8b9 9d74 7a7b 6c5f e898 129a 6c48 e197  ...tz{l_....lH..
   00f0: 4bc7 f25a cc13 09f2 d969 50a2 df5f 883e  K..Z.....iP.._.>
   0100: 8b18 eb67 52b6 186e 47d3 325c 0b77 a6d6  ...gR..nG.2\.w..
   0110: b7b8 ebdb a2ab 9d05 2a03 a890 2e65 7fdc  ........*....e..
   0120: 60ac a508 0937 dff1 3a61 01f7 2cc5 7d47  `....7..:a..,.}G
   0130: 5dbf 30a1 c784 367d fe1c 607f 9551 bd46  ].0...6}..`..Q.F
   0140: 292c 974e 9091 7d61 26c6 477b 6591 a01a  ),.N..}a&.G{e...
   0150: 9f8d 4ede e689 7d94 e017 166a 1da2 a482  ..N...}....j....
   0160: 0102 3081 ffa0 0302 0110 a281 f704 81f4  ..0.............
   0170: cceb 0587 7bab 9231 82bd b878 e41e acb2  ....{..1...x....
   0180: c789 de88 7f46 0822 e291 5e72 d309 2015  .....F."..^r.. .
   0190: 7722 0ca0 4b64 a10f cdc2 e913 e730 5596  w"..Kd.......0U.
   01a0: c219 494a 92a2 d3be 367e 02d7 382d 8069  ..IJ....6~..8-.i
   01b0: 4d27 5c84 2ada 0b37 1751 f2c6 eaac 5b60  M'\.*..7.Q....[`
   01c0: 3a9b 622f 59d9 e045 ccda 9661 fd48 b5ae  :.b/Y..E...a.H..
   01d0: d107 924a bee4 f201 f14b 11d9 5175 cb55  ...J.....K..Qu.U
   01e0: 9238 1b4b bdb1 bdc6 bd2f dcb1 15b7 34d7  .8.K...../....4.
   01f0: e40e 9264 d7d5 24f2 fb3e cce4 416a 4304  ...d..$..>..AjC.
   0200: d044 16c8 7856 a78a cc5f 1220 62ee cde6  .D..xV..._. b...
   0210: 9a03 2b7e 160d 22d9 32e7 c497 4526 d9c1  ..+~..".2...E&..
   0220: d5e9 ec1f c906 e8fe eba5 ceda d517 24e5  ..............$.
   0230: dba5 1dc3 d282 423e e010 0eeb 0a0b dbab  ......B>........
   0240: 5251 4f7f a95c da1e 6d31 cd40 631c 7c5c  RQO..\..m1.@c.|\
   0250: 423e 9803 9036 f012 3f65 1998 9ce0 7218  B>...6..?e....r.
   0260: 29e2 6cd4                                ).l.
sname = nfs/orca.cora.nwra.com@CORA.NWRA.COM
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 6 and length 24
doing downcall
\x02000000 2147483647 -1 -1 0 krb5 
\x0000000000000000a49323b0ff7f00000c298fe6f72a000004000000020000001ba3244d66258e35090000002a864886f712010202060000001800000075d5d316ba3746528af4943d45cb0891f15ef7bfaec257a70600000018000000852523e64ac7b6a27a0464cdb53bf86101ae074f5e32a757 

sending null reply
writing message: \x 
\x6082026006092a864886f71201020201006e82024f3082024ba003020105a10302010ea20703050020000000a382012e6182012a30820126a003020105a10f1b0d434f52412e4e5752412e434f4da2243022a003020103a11b30191b036e66731b12736167612e636f72612e6e7772612e636f6da381e73081e4a003020110a103020103a281d70481d48767f98fcbdf10bc38542e3ba0c24671c0bcbce028a5711ba7098eabcfeef49280eb91dcb8aa0f3e15f6b5546f637150e4707eb37b48c2126ced175a40b0642d2325cae66e1b45a9469a47577187c5cf50c27e13e712d8b99d747a7b6c5fe898129a6...


keytabs on server and client are like:

    3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (Triple DES cbc mode with HMAC/sha1)
    3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (ArcFour with HMAC/md5)
    3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (DES with HMAC/sha1)
    3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (DES cbc mode with RSA-MD5)

Any ideas?

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA/CoRA Division                    FAX: 303-415-9702
3380 Mitchell Lane                  orion@cora.nwra.com
Boulder, CO 80301              http://www.cora.nwra.com
