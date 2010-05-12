Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:26742 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758093Ab0ELVhl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 17:37:41 -0400
Message-ID: <4BEB1FA2.1060001@inria.fr>
Date: Wed, 12 May 2010 23:37:38 +0200
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
To: linux-nfs@vger.kernel.org
Subject: Re: trouble using kerberos between linux client and server
References: <4BCFE979.2000406@inria.fr> <4BE1E099.9050902@inria.fr>
In-Reply-To: <4BE1E099.9050902@inria.fr>
Content-Type: multipart/mixed;
 boundary="------------070002050807030002080900"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------070002050807030002080900
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Le 05/05/2010 23:18, Guillaume Rousse a écrit :
> I'm attaching network capture, even I can't figure additional
> information from it by myself.
Reading https://bugzilla.redhat.com/show_bug.cgi?id=562807, I rebuild
libtirpc with patch applied and -DDEBUG. Unfortunatly, it doesn't bring
additional information about the server-side failure :(
-- 
BOFH excuse #60:

system has been recalled

--------------070002050807030002080900
Content-Type: text/plain;
 name="client.out"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="client.out"

beginning poll
handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt37)
handle_gssd_upcall: 'mech=krb5 uid=0 '
handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt37)
process_krb5_upcall: service is '<null>'
Full hostname for 'loubianka.zarb.home' is 'loubianka.zarb.home'
Full hostname for 'beria.zarb.home' is 'beria.zarb.home'
Key table entry not found while getting keytab entry for 'root/beria.zarb.home@ZARB.HOME'
Success getting keytab entry for 'nfs/beria.zarb.home@ZARB.HOME'
Successfully obtained machine credentials for principal 'nfs/beria.zarb.home@ZARB.HOME' stored in ccache 'FILE:/tmp/krb5cc_machine_ZARB.HOME'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_ZARB.HOME' are good until 1273786473
using FILE:/tmp/krb5cc_machine_ZARB.HOME as credentials cache for machine creds
using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_ZARB.HOME
creating context using fsuid 0 (save_uid 0)
creating tcp client for server loubianka.zarb.home
DEBUG: port already set to 2049
creating context with server nfs@loubianka.zarb.home
rpcsec_gss: in authgss_create_default()
rpcsec_gss: in authgss_create()
authgss_create: name is 0x1a0f980
authgss_create: gd->name is 0x1a0b450
rpcsec_gss: in authgss_refresh()
rpcsec_gss: rpc_gss_sec:
     mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 }
     qop: 0
     service: 1
     cred: 0x1a0f2d0
rpcsec_gss: The token being sent (length 552):

  0000: 6082 0224 0609 2a86 4886 f712 0102 0201  `..$..*.H.......
  0010: 006e 8202 1330 8202 0fa0 0302 0105 a103  .n...0..........
  0020: 0201 0ea2 0703 0500 2000 0000 a382 013f  ........ ......?
  0030: 6182 013b 3082 0137 a003 0201 05a1 0b1b  a..;0..7........
  0040: 095a 4152 422e 484f 4d45 a225 3023 a003  .ZARB.HOME.%0#..
  0050: 0201 03a1 1c30 1a1b 036e 6673 1b13 6c6f  .....0...nfs..lo
  0060: 7562 6961 6e6b 612e 7a61 7262 2e68 6f6d  ubianka.zarb.hom
  0070: 65a3 81fb 3081 f8a0 0302 0101 a103 0201  e...0...........
  0080: 02a2 81eb 0481 e825 b158 7e3b e709 a61a  .......%.X~;....
  0090: 82c4 8f6c a741 9885 8c0b 634c a32c f091  ...l.A....cL.,..
  00a0: 02f1 8ecf b46c d7dc 5ef1 a949 3ef4 b7c7  .....l..^..I>...
  00b0: 2a45 f1de ff72 3ab8 8239 3aae 1ac3 fb19  *E...r:..9:.....
  00c0: 949b c4e3 46b9 6956 1e91 3ed5 1d48 72cb  ....F.iV..>..Hr.
  00d0: 33a6 95b6 09e8 b104 28be a1cb 14a3 5d7d  3.......(.....]}
  00e0: 8c14 2a8d 3aa9 d90c 2e81 cc05 bd00 9a51  ..*.:..........Q
  00f0: 8916 3375 1cf6 66ab 4fe7 4d8b bcbf 6ccc  ..3u..f.O.M...l.
  0100: 957b 3100 e4bb b0c8 e5cc c8ca 3b08 34dd  .{1.........;.4.
  0110: 66b6 913f c38a 746e f62d dbe2 a6e5 5fd8  f..?..tn.-...._.
  0120: 5afb b977 1fe4 470d 78ba 6cbc e7a9 9553  Z..w..G.x.l....S
  0130: 0889 7e9a ee26 0542 1494 e1fd cb50 f581  ..~..&.B.....P..
  0140: 9aa6 19ab ba09 30a2 ca23 2922 91d3 fce0  ......0..#)"....
  0150: 3f32 ec5f 819b f142 e449 ad07 8d49 2263  ?2._...B.I...I"c
  0160: cafa 491d e743 ad15 4a49 d72b 6562 98a4  ..I..C..JI.+eb..
  0170: 81b6 3081 b3a0 0302 0101 a281 ab04 81a8  ..0.............
  0180: 3ad3 49a2 2443 5f54 c8cb fd04 2c66 279b  :.I.$C_T....,f'.
  0190: 58bd 522e 5e9e c0e0 f7b0 e32d c1b8 2a93  X.R.^......-..*.
  01a0: da22 569d 3290 bbcd e7ed 2b84 812d 2022  ."V.2.....+..- "
  01b0: 9f06 b6f9 bef2 53cd 4760 b28c 7029 4456  ......S.G`..p)DV
  01c0: 59f9 057b cbce 5dc2 5aab 6979 6519 a6b3  Y..{..].Z.iye...
  01d0: c5e1 f575 23e8 1b16 e008 5d91 2dd1 8a97  ...u#.....].-...
  01e0: ed53 2b9a c9e6 53ab 59f0 928b 8fc7 a19d  .S+...S.Y.......
  01f0: 3f8a 050e fba9 c929 ca86 4940 93fd 1205  ?......)..I@....
  0200: a21e 077e d035 9f0f 72bd 1928 885e 45ef  ...~.5..r..(.^E.
  0210: 47f0 f627 cc58 5b35 55d4 3175 1390 0e9e  G..'.X[5U.1u....
  0220: c558 9320 48bb ee96          .X. H...
rpcsec_gss: in authgss_marshal()
rpcsec_gss: xdr_rpc_gss_buf: encode success ((nil):0)
rpcsec_gss: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
rpcsec_gss: xdr_rpc_gss_buf: encode success (0x1a43140:552)
rpcsec_gss: xdr_rpc_gss_init_args: encode success (token 0x1a43140:552)
rpcsec_gss: in authgss_validate()
rpcsec_gss: xdr_rpc_gss_buf: decode success (0x1a0d0e0:4)
rpcsec_gss: xdr_rpc_gss_buf: decode success (0x1a42d30:114)
rpcsec_gss: xdr_rpc_gss_init_res decode success (ctx 0x1a0d0e0:4, maj 524288, min 0, win 128, token 0x1a42d30:114)
authgss_create_default: freeing name 0x1a0f980
WARNING: Failed to create krb5 context for user with uid 0 for server loubianka.zarb.home
WARNING: Failed to create machine krb5 context with credentials cache FILE:/tmp/krb5cc_machine_ZARB.HOME for server loubianka.zarb.home
WARNING: Machine cache is prematurely expired or corrupted trying to recreate cache for server loubianka.zarb.home
Full hostname for 'loubianka.zarb.home' is 'loubianka.zarb.home'
Full hostname for 'beria.zarb.home' is 'beria.zarb.home'
Key table entry not found while getting keytab entry for 'root/beria.zarb.home@ZARB.HOME'
Success getting keytab entry for 'nfs/beria.zarb.home@ZARB.HOME'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_ZARB.HOME' are good until 1273786473
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_ZARB.HOME' are good until 1273786473
using FILE:/tmp/krb5cc_machine_ZARB.HOME as credentials cache for machine creds
using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_ZARB.HOME
creating context using fsuid 0 (save_uid 0)
creating tcp client for server loubianka.zarb.home
DEBUG: port already set to 2049
creating context with server nfs@loubianka.zarb.home
rpcsec_gss: in authgss_create_default()
rpcsec_gss: in authgss_create()
authgss_create: name is 0x1a0d890
authgss_create: gd->name is 0x1a42ec0
rpcsec_gss: in authgss_refresh()
rpcsec_gss: rpc_gss_sec:
     mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 }
     qop: 0
     service: 1
     cred: 0x1a0e910
rpcsec_gss: The token being sent (length 552):

  0000: 6082 0224 0609 2a86 4886 f712 0102 0201  `..$..*.H.......
  0010: 006e 8202 1330 8202 0fa0 0302 0105 a103  .n...0..........
  0020: 0201 0ea2 0703 0500 2000 0000 a382 013f  ........ ......?
  0030: 6182 013b 3082 0137 a003 0201 05a1 0b1b  a..;0..7........
  0040: 095a 4152 422e 484f 4d45 a225 3023 a003  .ZARB.HOME.%0#..
  0050: 0201 03a1 1c30 1a1b 036e 6673 1b13 6c6f  .....0...nfs..lo
  0060: 7562 6961 6e6b 612e 7a61 7262 2e68 6f6d  ubianka.zarb.hom
  0070: 65a3 81fb 3081 f8a0 0302 0101 a103 0201  e...0...........
  0080: 02a2 81eb 0481 e825 b158 7e3b e709 a61a  .......%.X~;....
  0090: 82c4 8f6c a741 9885 8c0b 634c a32c f091  ...l.A....cL.,..
  00a0: 02f1 8ecf b46c d7dc 5ef1 a949 3ef4 b7c7  .....l..^..I>...
  00b0: 2a45 f1de ff72 3ab8 8239 3aae 1ac3 fb19  *E...r:..9:.....
  00c0: 949b c4e3 46b9 6956 1e91 3ed5 1d48 72cb  ....F.iV..>..Hr.
  00d0: 33a6 95b6 09e8 b104 28be a1cb 14a3 5d7d  3.......(.....]}
  00e0: 8c14 2a8d 3aa9 d90c 2e81 cc05 bd00 9a51  ..*.:..........Q
  00f0: 8916 3375 1cf6 66ab 4fe7 4d8b bcbf 6ccc  ..3u..f.O.M...l.
  0100: 957b 3100 e4bb b0c8 e5cc c8ca 3b08 34dd  .{1.........;.4.
  0110: 66b6 913f c38a 746e f62d dbe2 a6e5 5fd8  f..?..tn.-...._.
  0120: 5afb b977 1fe4 470d 78ba 6cbc e7a9 9553  Z..w..G.x.l....S
  0130: 0889 7e9a ee26 0542 1494 e1fd cb50 f581  ..~..&.B.....P..
  0140: 9aa6 19ab ba09 30a2 ca23 2922 91d3 fce0  ......0..#)"....
  0150: 3f32 ec5f 819b f142 e449 ad07 8d49 2263  ?2._...B.I...I"c
  0160: cafa 491d e743 ad15 4a49 d72b 6562 98a4  ..I..C..JI.+eb..
  0170: 81b6 3081 b3a0 0302 0101 a281 ab04 81a8  ..0.............
  0180: 1dad 9916 ee93 d883 6ca4 146e eef3 2854  ........l..n..(T
  0190: 1b11 06f1 2866 e976 7f78 8caa 130b 6d39  ....(f.v.x....m9
  01a0: aba4 395e 4a3d e631 29a4 ce7c afd8 bd18  ..9^J=.1)..|....
  01b0: 7507 47c8 5cc6 e6d4 aabd 0512 1cd1 61ad  u.G.\.........a.
  01c0: 8b14 e64e b45b 6679 4381 820c 2a68 d396  ...N.[fyC...*h..
  01d0: d971 7a92 e289 bd99 170b 3b96 88ac 2ed7  .qz.......;.....
  01e0: db03 e594 3624 8658 29be 3dc8 b415 9801  ....6$.X).=.....
  01f0: ba9e 5363 d223 8b6d fb9f 9f41 6fe6 5d99  ..Sc.#.m...Ao.].
  0200: 2cf4 6749 5204 7f50 9695 6ff1 7346 ab69  ,.gIR..P..o.sF.i
  0210: ab51 0ca3 7287 bb79 5ef0 a1f2 3e1c 83b0  .Q..r..y^...>...
  0220: 0cc1 cf39 fc82 8764          ...9...d
rpcsec_gss: in authgss_marshal()
rpcsec_gss: xdr_rpc_gss_buf: encode success ((nil):0)
rpcsec_gss: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
rpcsec_gss: xdr_rpc_gss_buf: encode success (0x1a332c0:552)
rpcsec_gss: xdr_rpc_gss_init_args: encode success (token 0x1a332c0:552)
rpcsec_gss: in authgss_validate()
rpcsec_gss: xdr_rpc_gss_buf: decode success (0x1a33050:4)
rpcsec_gss: xdr_rpc_gss_buf: decode success (0x1a0d100:114)
rpcsec_gss: xdr_rpc_gss_init_res decode success (ctx 0x1a33050:4, maj 524288, min 0, win 128, token 0x1a0d100:114)
authgss_create_default: freeing name 0x1a0d890
WARNING: Failed to create krb5 context for user with uid 0 for server loubianka.zarb.home
WARNING: Failed to create machine krb5 context with credentials cache FILE:/tmp/krb5cc_machine_ZARB.HOME for server loubianka.zarb.home
WARNING: Failed to create machine krb5 context with any credentials cache for server loubianka.zarb.home
doing error downcall
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt38
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt37

--------------070002050807030002080900
Content-Type: text/plain;
 name="server.out"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="server.out"

entering poll
leaving poll
handling null request
sname =3D nfs/beria.zarb.home@ZARB.HOME
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1273786282 (86368 from now), =
clnt: nfs@beria.zarb.home, uid: -1, gid: -1, num aux grps: 0:
: qword_eol: fflush failed: errno 95 (Operation not supported)
WARNING: error writing to downcall channel /proc/net/rpc/auth.rpcsec.contex=
t/channel: Operation not supported
sending null reply
writing message: \x \x6082022406092a864886f71201020201006e8202133082020fa00=
3020105a10302010ea20703050020000000a382013f6182013b30820137a003020105a10b1b=
095a4152422e484f4d45a2253023a003020103a11c301a1b036e66731b136c6f756269616e6=
b612e7a6172622e686f6d65a381fb3081f8a003020101a103020102a281eb0481e8f147ea9d=
87f2a69ac17f6268886ca4d4b4b49b23e1c66b98e327a7dbdafad7f94a0ef88f6875d136986=
d72a5171d233f01deb76e38ff04c85f69deb82f4c6429c07c682d7b01119f7a8cd31cb60826=
66dc008396cb8fc04023821164537ee775b989d65707f67d9ff88a9c2d35e6faef9f286c50d=
75248123f5eb9f333792c5e8e6d68e54aab748cea1beb87e1636749c918d3e9073eedb36cb8=
d8fce5a3e5e6ec7a02d4017290ba2bfbeff75e4dfda5717c5ec3dfe63d3875c9b1c905490db=
a2457b8264729691526a58aade0773cd91bd66489a3fc159cb645d1e0dfd36eaab80eff2512=
61ec84a481b63081b3a003020101a281ab0481a860e34f864e6b135c060cc54b265e6cb489d=
f0f8c592ed1057ff77245b9fd4edd1c84e6bdc14da6133993e58e8657893c36af8f39f6e98e=
b7f4ad3542662d9477344e58fe73e94fa74a97f58c2018e1703f1aa1481dd97a8ea067aa57a=
447a565f6344007cf74068757b8992209772fdfb5e4dbac8cf3381be336e410e2513b9c3b96=
bad26c761af72f010bc0a5208ccbbfac1b50c6e8e6491a3cdea8f3bdb6768fd5dba099fcd4b=
b 1273699974 0 0 \x01000000 \x607006092a864886f71201020202006f61305fa003020=
105a10302010fa2533051a003020101a24a0448cba3a2be2aea1045e13550745c947c133287=
98420d87e7b68107aa1eaddc686e92265a4277550af4a6658aad21b7ab1993c1f9fa503581a=
8eaa12f5648582100259cb1f633bfea10=20
finished handling null request
entering poll
leaving poll
handling null request
sname =3D nfs/beria.zarb.home@ZARB.HOME
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1273786282 (86368 from now), =
clnt: nfs@beria.zarb.home, uid: -1, gid: -1, num aux grps: 0:
: qword_eol: fflush failed: errno 95 (Operation not supported)
WARNING: error writing to downcall channel /proc/net/rpc/auth.rpcsec.contex=
t/channel: Operation not supported
sending null reply
writing message: \x \x6082022406092a864886f71201020201006e8202133082020fa00=
3020105a10302010ea20703050020000000a382013f6182013b30820137a003020105a10b1b=
095a4152422e484f4d45a2253023a003020103a11c301a1b036e66731b136c6f756269616e6=
b612e7a6172622e686f6d65a381fb3081f8a003020101a103020102a281eb0481e8f147ea9d=
87f2a69ac17f6268886ca4d4b4b49b23e1c66b98e327a7dbdafad7f94a0ef88f6875d136986=
d72a5171d233f01deb76e38ff04c85f69deb82f4c6429c07c682d7b01119f7a8cd31cb60826=
66dc008396cb8fc04023821164537ee775b989d65707f67d9ff88a9c2d35e6faef9f286c50d=
75248123f5eb9f333792c5e8e6d68e54aab748cea1beb87e1636749c918d3e9073eedb36cb8=
d8fce5a3e5e6ec7a02d4017290ba2bfbeff75e4dfda5717c5ec3dfe63d3875c9b1c905490db=
a2457b8264729691526a58aade0773cd91bd66489a3fc159cb645d1e0dfd36eaab80eff2512=
61ec84a481b63081b3a003020101a281ab0481a8c6dff980a14e5a4fabc3e8578adf1984884=
005392e43e4835b75129503e56c5e7276a80c4b03280b57645b6443a588f61ece121f62d2dc=
8e14d6af4dcbd2a57a5d32f010656678f432e54e6ce5150ae3938a8a5f76c4f17274bfa9314=
620f0f32a66ac4d84f014a653b237f035e65efbba1f7b1193a65e5d305ab60ccea21da4be2d=
7da64be91d4b9fcd1b9dd7ef6afcde6acd77e89477a652bc2fce94d529c6252deefffa2faa2=
c 1273699974 0 0 \x02000000 \x607006092a864886f71201020202006f61305fa003020=
105a10302010fa2533051a003020101a24a0448b34692835c0e0a2ab0d9503e7a9684738be8=
9813e3701d039511146c6c471d69dbfbd624dd43a0537cb25d60511040baf656ae60da28b34=
fd77bdd46326b3b460b28e439f5663954=20
finished handling null request
entering poll
leaving poll
handling null request
sname =3D nfs/beria.zarb.home@ZARB.HOME
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1273786473 (86401 from now), =
clnt: nfs@beria.zarb.home, uid: -1, gid: -1, num aux grps: 0:
: qword_eol: fflush failed: errno 95 (Operation not supported)
WARNING: error writing to downcall channel /proc/net/rpc/auth.rpcsec.contex=
t/channel: Operation not supported
sending null reply
writing message: \x \x6082022406092a864886f71201020201006e8202133082020fa00=
3020105a10302010ea20703050020000000a382013f6182013b30820137a003020105a10b1b=
095a4152422e484f4d45a2253023a003020103a11c301a1b036e66731b136c6f756269616e6=
b612e7a6172622e686f6d65a381fb3081f8a003020101a103020102a281eb0481e825b1587e=
3be709a61a82c48f6ca74198858c0b634ca32cf09102f18ecfb46cd7dc5ef1a9493ef4b7c72=
a45f1deff723ab882393aae1ac3fb19949bc4e346b969561e913ed51d4872cb33a695b609e8=
b10428bea1cb14a35d7d8c142a8d3aa9d90c2e81cc05bd009a51891633751cf666ab4fe74d8=
bbcbf6ccc957b3100e4bbb0c8e5ccc8ca3b0834dd66b6913fc38a746ef62ddbe2a6e55fd85a=
fbb9771fe4470d78ba6cbce7a9955308897e9aee2605421494e1fdcb50f5819aa619abba093=
0a2ca23292291d3fce03f32ec5f819bf142e449ad078d492263cafa491de743ad154a49d72b=
656298a481b63081b3a003020101a281ab0481a83ad349a224435f54c8cbfd042c66279b58b=
d522e5e9ec0e0f7b0e32dc1b82a93da22569d3290bbcde7ed2b84812d20229f06b6f9bef253=
cd4760b28c7029445659f9057bcbce5dc25aab69796519a6b3c5e1f57523e81b16e0085d912=
dd18a97ed532b9ac9e653ab59f0928b8fc7a19d3f8a050efba9c929ca86494093fd1205a21e=
077ed0359f0f72bd1928885e45ef47f0f627cc585b3555d4317513900e9ec558932048bbee9=
6 1273700132 0 0 \x03000000 \x607006092a864886f71201020202006f61305fa003020=
105a10302010fa2533051a003020101a24a04485eea3ec8d3a72acdbad4238ce5d2ad72880d=
e63fd814140df70591d5d391ac24c3cae241a4bf5ab21473cc2850daedd24185acf0e8daa69=
6fbde56590b9c50d105676c7b0fc1d2b6=20
finished handling null request
entering poll
leaving poll
handling null request
sname =3D nfs/beria.zarb.home@ZARB.HOME
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1273786473 (86401 from now), =
clnt: nfs@beria.zarb.home, uid: -1, gid: -1, num aux grps: 0:
: qword_eol: fflush failed: errno 95 (Operation not supported)
WARNING: error writing to downcall channel /proc/net/rpc/auth.rpcsec.contex=
t/channel: Operation not supported
sending null reply
writing message: \x \x6082022406092a864886f71201020201006e8202133082020fa00=
3020105a10302010ea20703050020000000a382013f6182013b30820137a003020105a10b1b=
095a4152422e484f4d45a2253023a003020103a11c301a1b036e66731b136c6f756269616e6=
b612e7a6172622e686f6d65a381fb3081f8a003020101a103020102a281eb0481e825b1587e=
3be709a61a82c48f6ca74198858c0b634ca32cf09102f18ecfb46cd7dc5ef1a9493ef4b7c72=
a45f1deff723ab882393aae1ac3fb19949bc4e346b969561e913ed51d4872cb33a695b609e8=
b10428bea1cb14a35d7d8c142a8d3aa9d90c2e81cc05bd009a51891633751cf666ab4fe74d8=
bbcbf6ccc957b3100e4bbb0c8e5ccc8ca3b0834dd66b6913fc38a746ef62ddbe2a6e55fd85a=
fbb9771fe4470d78ba6cbce7a9955308897e9aee2605421494e1fdcb50f5819aa619abba093=
0a2ca23292291d3fce03f32ec5f819bf142e449ad078d492263cafa491de743ad154a49d72b=
656298a481b63081b3a003020101a281ab0481a81dad9916ee93d8836ca4146eeef328541b1=
106f12866e9767f788caa130b6d39aba4395e4a3de63129a4ce7cafd8bd18750747c85cc6e6=
d4aabd05121cd161ad8b14e64eb45b66794381820c2a68d396d9717a92e289bd99170b3b968=
8ac2ed7db03e5943624865829be3dc8b4159801ba9e5363d2238b6dfb9f9f416fe65d992cf4=
674952047f5096956ff17346ab69ab510ca37287bb795ef0a1f23e1c83b00cc1cf39fc82876=
4 1273700132 0 0 \x04000000 \x607006092a864886f71201020202006f61305fa003020=
105a10302010fa2533051a003020101a24a04489b34d71277a39e36a8c5733778e89320f138=
ca15024a65803b9f91283ee321267f3424e183282c31c386c4a34f64c6e89400b58122a036b=
98176f3ee658dd1a0af1d83f9cef6bd87=20
finished handling null request
entering poll

--------------070002050807030002080900--
