Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:4993 "EHLO
	mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755410Ab0EMVNW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 17:13:22 -0400
Message-ID: <4BEC6B6E.9090705@inria.fr>
Date: Thu, 13 May 2010 23:13:18 +0200
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: trouble using kerberos between linux client and server
References: <4BCFE979.2000406@inria.fr> <4BE1E099.9050902@inria.fr>	 <4BEB1FA2.1060001@inria.fr>	 <AANLkTinNTYrEe9G6urXBxv-hogZPatOe9zWbbjnVTbWz@mail.gmail.com>	 <4BEBC1B0.8030502@inria.fr> <AANLkTinPfbYgqFxcIuT3975TAtk0e1D84bMAeez5Z06T@mail.gmail.com>
In-Reply-To: <AANLkTinPfbYgqFxcIuT3975TAtk0e1D84bMAeez5Z06T@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Le 13/05/2010 14:55, Kevin Coffman a écrit :
> On Thu, May 13, 2010 at 5:09 AM, Guillaume Rousse
> <Guillaume.Rousse@inria.fr> wrote:
>> Le 13/05/2010 01:21, Kevin Coffman a écrit :
>>> On Wed, May 12, 2010 at 5:37 PM, Guillaume Rousse
>>> <Guillaume.Rousse@inria.fr> wrote:
>>>> Le 05/05/2010 23:18, Guillaume Rousse a écrit :
>>>>> I'm attaching network capture, even I can't figure additional
>>>>> information from it by myself.
>>>> Reading https://bugzilla.redhat.com/show_bug.cgi?id=562807, I rebuild
>>>> libtirpc with patch applied and -DDEBUG. Unfortunatly, it doesn't bring
>>>> additional information about the server-side failure :(
>>>
>>> It looks to me like fflush(), called in qword_eol(), may be returning
>>> the number of bytes flushed (95) rather than zero for success?  I
>>> don't immediately see any changes that would cause this.  But I
>>> haven't looked extensively...
>> Not necessarily a change: I never used a kerberized server sofar, only
>> clients.
> 
> Well, I've not seen that issue before, so I assumed it was a change.
> I looked back a bit, but didn't see: what versions of nfs-utils and
> kernel are on the server?
The same on both sides: kernel 2.6.33.3 + nfs-utils 1.2.2

I just rebuild nfs-utils with -DDEBUG flag, here is the trace:
[root@loubianka ~]# rpc.svcgssd -f -vvvvv
entering poll
leaving poll
handling null request
in_handle (length 0)
in_tok (length 552)
  0000: 6082 0224 0609 2a86 4886 f712 0102 0201  `..$..*.H.......
  0010: 006e 8202 1330 8202 0fa0 0302 0105 a103  .n...0..........
  0020: 0201 0ea2 0703 0500 2000 0000 a382 013f  ........ ......?
  0030: 6182 013b 3082 0137 a003 0201 05a1 0b1b  a..;0..7........
  0040: 095a 4152 422e 484f 4d45 a225 3023 a003  .ZARB.HOME.%0#..
  0050: 0201 03a1 1c30 1a1b 036e 6673 1b13 6c6f  .....0...nfs..lo
  0060: 7562 6961 6e6b 612e 7a61 7262 2e68 6f6d  ubianka.zarb.hom
  0070: 65a3 81fb 3081 f8a0 0302 0101 a103 0201  e...0...........
  0080: 02a2 81eb 0481 e87f 7aab 72a5 f0c5 3967  ........z.r...9g
  0090: ad82 1f96 8e90 1ba3 a540 030d 4da0 73b4  .........@..M.s.
  00a0: 5dc1 8226 0658 2907 11b6 7a2d e763 2809  ]..&.X)...z-.c(.
  00b0: e7d5 d12e ebd3 956b fe6d 4b7e 9e88 ca23  .......k.mK~...#
  00c0: d503 7516 ced5 819f fc9a 1381 e890 2459  ..u...........$Y
  00d0: 712c c035 7e37 f797 faff d4d5 5980 6d04  q,.5~7......Y.m.
  00e0: 1881 ac03 a997 0cca 10ea 3f00 070a 70e6  ..........?...p.
  00f0: d86c b1cf 0fe7 e4c2 a1bb a91c 0165 73f2  .l...........es.
  0100: 6e88 d676 d5d9 2f69 0b84 ea33 9ac8 13ce  n..v../i...3....
  0110: d014 2977 ce2b 5154 e7a8 22df 34d2 f32f  ..)w.+QT..".4../
  0120: 6de7 f18f 2fcf 3f1d f503 aa36 cc0f 1c37  m.../.?....6...7
  0130: 251b 784e 4187 218b df0f b276 e3a3 09c6  %.xNA.!....v....
  0140: 27bc 1776 b54d 7295 a432 16f9 d1fe 7766  '..v.Mr..2....wf
  0150: c588 48ac 6657 8c86 a1c7 f7bf f2fb 6945  ..H.fW........iE
  0160: 2f51 661f b7a9 b8d1 c7ea 9667 0928 f1a4  /Qf........g.(..
  0170: 81b6 3081 b3a0 0302 0101 a281 ab04 81a8  ..0.............
  0180: 0996 dd55 17a9 25be e6d9 fc11 1ae2 f460  ...U..%........`
  0190: 2fa2 46f2 cf1b 710b 2f83 2c94 93b0 f0d4  /.F...q./.,.....
  01a0: 9ae9 ae94 bbb7 2a9f 7c91 db19 d107 f3ea  ......*.|.......
  01b0: afeb 8f92 4575 2f4f 5a8e 3616 5ffe ae76  ....Eu/OZ.6._..v
  01c0: 1f96 ecfe bf2d 499e f140 3d91 b68c e4f1  .....-I..@=.....
  01d0: b24d f1b6 2057 0ce1 471d b9fb d7b9 44fc  .M.. W..G.....D.
  01e0: 24f5 9757 1374 8c93 d7fb 1786 a3bc bc81  $..W.t..........
  01f0: 4877 ac8e 19eb 7269 6478 d9b5 72b9 4c54  Hw....ridx..r.LT
  0200: 5357 8cf0 9610 8a3d 71de 809e bddd 1fd7  SW.....=q.......
  0210: ee05 3501 3750 4146 c9db 7976 a973 623e  ..5.7PAF..yv.sb>
  0220: 87d6 2337 cdcb cb40                      ..#7...@
sname = nfs/beria.zarb.home@ZARB.HOME
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1273870075 (84939 from
now), clnt: nfs@beria.zarb.home, uid: -1, gid: -1, num aux grps: 0:
: qword_eol: fflush failed: errno 95 (Operation not supported)
WARNING: error writing to downcall channel
/proc/net/rpc/auth.rpcsec.context/channel: Operation not supported
sending null reply
writing message: \x
\x6082022406092a864886f71201020201006e8202133082020fa003020105a10302010ea20703050020000000a382013f6182013b30820137a003020105a10b1b095a4152422e484f4d45a2253023a003020103a11c301a1b036e66731b136c6f756269616e6b612e7a6172622e686f6d65a381fb3081f8a003020101a103020102a281eb0481e87f7aab72a5f0c53967ad821f968e901ba3a540030d4da073b45dc182260658290711b67a2de7632809e7d5d12eebd3956bfe6d4b7e9e88ca23d5037516ced5819ffc9a1381e8902459712cc0357e37f797faffd4d559806d041881ac03a9970cca10ea3f00070a70e6d86cb1cf0fe7e4c2a1bba91c016573f26e88d676d5d92f690b84ea339ac813ced0142977ce2b5154e7a822df34d2f32f6de7f18f2fcf3f1df503aa36cc0f1c37251b784e4187218bdf0fb276e3a309c627bc1776b54d7295a43216f9d1fe7766c58848ac66578c86a1c7f7bff2fb69452f51661fb7a9b8d1c7ea96670928f1a481b63081b3a003020101a281ab0481a80996dd5517a925bee6d9fc111ae2f4602fa246f2cf1b710b2f832c9493b0f0d49ae9ae94bbb72a9f7c91db19d107f3eaafeb8f9245752f4f5a8e36165ffeae761f96ecfebf2d499ef1403d91b68ce4f1b24df1b620570ce1471db9fbd7b944fc24f5975713748c93d7fb1786a3bc
bc814877ac8e19eb72696478d9b572b94c5453578cf096108a3d71de809ebddd1fd7ee05350137504146c9db7976a973623e87d62337cdcbcb40
1273785196 0 0 \x01000000
\x607006092a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a24a0448ba282fe905b53fbd556c771446c691f46c3879fed41f67dc822fc13bccf60d9c4020181a1de4a2ca4da7f52fd89b68f1d1e266eb5c38305eb4e12af5cc675ead822c35c1fb7639b5

finished handling null request
entering poll
leaving poll
handling null request
in_handle (length 0)
in_tok (length 552)
  0000: 6082 0224 0609 2a86 4886 f712 0102 0201  `..$..*.H.......
  0010: 006e 8202 1330 8202 0fa0 0302 0105 a103  .n...0..........
  0020: 0201 0ea2 0703 0500 2000 0000 a382 013f  ........ ......?
  0030: 6182 013b 3082 0137 a003 0201 05a1 0b1b  a..;0..7........
  0040: 095a 4152 422e 484f 4d45 a225 3023 a003  .ZARB.HOME.%0#..
  0050: 0201 03a1 1c30 1a1b 036e 6673 1b13 6c6f  .....0...nfs..lo
  0060: 7562 6961 6e6b 612e 7a61 7262 2e68 6f6d  ubianka.zarb.hom
  0070: 65a3 81fb 3081 f8a0 0302 0101 a103 0201  e...0...........
  0080: 02a2 81eb 0481 e87f 7aab 72a5 f0c5 3967  ........z.r...9g
  0090: ad82 1f96 8e90 1ba3 a540 030d 4da0 73b4  .........@..M.s.
  00a0: 5dc1 8226 0658 2907 11b6 7a2d e763 2809  ]..&.X)...z-.c(.
  00b0: e7d5 d12e ebd3 956b fe6d 4b7e 9e88 ca23  .......k.mK~...#
  00c0: d503 7516 ced5 819f fc9a 1381 e890 2459  ..u...........$Y
  00d0: 712c c035 7e37 f797 faff d4d5 5980 6d04  q,.5~7......Y.m.
  00e0: 1881 ac03 a997 0cca 10ea 3f00 070a 70e6  ..........?...p.
  00f0: d86c b1cf 0fe7 e4c2 a1bb a91c 0165 73f2  .l...........es.
  0100: 6e88 d676 d5d9 2f69 0b84 ea33 9ac8 13ce  n..v../i...3....
  0110: d014 2977 ce2b 5154 e7a8 22df 34d2 f32f  ..)w.+QT..".4../
  0120: 6de7 f18f 2fcf 3f1d f503 aa36 cc0f 1c37  m.../.?....6...7
  0130: 251b 784e 4187 218b df0f b276 e3a3 09c6  %.xNA.!....v....
  0140: 27bc 1776 b54d 7295 a432 16f9 d1fe 7766  '..v.Mr..2....wf
  0150: c588 48ac 6657 8c86 a1c7 f7bf f2fb 6945  ..H.fW........iE
  0160: 2f51 661f b7a9 b8d1 c7ea 9667 0928 f1a4  /Qf........g.(..
  0170: 81b6 3081 b3a0 0302 0101 a281 ab04 81a8  ..0.............
  0180: 2fc0 6153 e878 e685 d5dc f447 ab2a 37b8  /.aS.x.....G.*7.
  0190: f1be d30e edb6 dbdc c549 9fbc f58c abe7  .........I......
  01a0: 9b70 8efc 1588 c362 9bac 5c44 8cc5 72e1  .p.....b..\D..r.
  01b0: 3f22 3726 b144 9303 52cd 9c75 dc65 5671  ?"7&.D..R..u.eVq
  01c0: cd2b dc52 9d7f 9d21 ab87 b01e 35bb 1655  .+.R...!....5..U
  01d0: 7ba6 cdc5 3d14 d82b 5140 7831 2cc4 ce9b  {...=..+Q@x1,...
  01e0: eb42 4614 2b8b 5ce4 0ffe 160f 85ef 0d9a  .BF.+.\.........
  01f0: 84d3 aa5f 3360 2557 120c 1f80 b7fc edaf  ..._3`%W........
  0200: fb93 64df 137b f16d 60c6 b7f8 4e50 f582  ..d..{.m`...NP..
  0210: 6f59 88f4 13c0 0507 8fb7 e176 2c0b 17a1  oY.........v,...
  0220: b1f3 005f 089d 8560                      ..._...`
sname = nfs/beria.zarb.home@ZARB.HOME
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1273870075 (84939 from
now), clnt: nfs@beria.zarb.home, uid: -1, gid: -1, num aux grps: 0:
: qword_eol: fflush failed: errno 95 (Operation not supported)
WARNING: error writing to downcall channel
/proc/net/rpc/auth.rpcsec.context/channel: Operation not supported
sending null reply
writing message: \x
\x6082022406092a864886f71201020201006e8202133082020fa003020105a10302010ea20703050020000000a382013f6182013b30820137a003020105a10b1b095a4152422e484f4d45a2253023a003020103a11c301a1b036e66731b136c6f756269616e6b612e7a6172622e686f6d65a381fb3081f8a003020101a103020102a281eb0481e87f7aab72a5f0c53967ad821f968e901ba3a540030d4da073b45dc182260658290711b67a2de7632809e7d5d12eebd3956bfe6d4b7e9e88ca23d5037516ced5819ffc9a1381e8902459712cc0357e37f797faffd4d559806d041881ac03a9970cca10ea3f00070a70e6d86cb1cf0fe7e4c2a1bba91c016573f26e88d676d5d92f690b84ea339ac813ced0142977ce2b5154e7a822df34d2f32f6de7f18f2fcf3f1df503aa36cc0f1c37251b784e4187218bdf0fb276e3a309c627bc1776b54d7295a43216f9d1fe7766c58848ac66578c86a1c7f7bff2fb69452f51661fb7a9b8d1c7ea96670928f1a481b63081b3a003020101a281ab0481a82fc06153e878e685d5dcf447ab2a37b8f1bed30eedb6dbdcc5499fbcf58cabe79b708efc1588c3629bac5c448cc572e13f223726b144930352cd9c75dc655671cd2bdc529d7f9d21ab87b01e35bb16557ba6cdc53d14d82b514078312cc4ce9beb4246142b8b5ce40ffe160f85ef
0d9a84d3aa5f33602557120c1f80b7fcedaffb9364df137bf16d60c6b7f84e50f5826f5988f413c005078fb7e1762c0b17a1b1f3005f089d8560
1273785196 0 0 \x02000000
\x607006092a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a24a0448dda178816b2563207402c75826cb9098f5bcc8d02b7f229f5316d047875a3bfc7643aa96dffae46a0b14c79ab55f2ad0419af006960bd444da016079fb3ec601414abbf1070e154a

finished handling null request
entering poll
-- 
BOFH excuse #42:

spaghetti cable cause packet failure
