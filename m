Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:44650 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250Ab3FYKit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 06:38:49 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<sven@gegg.us>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1UrPtn-0005ff-VZ
	for linux-nfs@vger.kernel.org; Tue, 25 Jun 2013 11:50:56 +0200
Received: from sven  by ultimate100.geggus.net (envelope-from
	<sven@gegg.us>)
	with local (Exim 4.72)
	id 1UrPtk-0000f0-4q
	for linux-nfs@vger.kernel.org; Tue, 25 Jun 2013 11:50:52 +0200
Date: Tue, 25 Jun 2013 11:46:13 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130625094612.GA2186@geggus.net>
References: <kpscp8$fo3$1@ultimate100.geggus.net>
 <20130619213412.GA2547@fieldses.org>
 <20130620080354.GA5591@geggus.net>
 <20130620144955.GB11728@fieldses.org>
 <20130620145209.GC11728@fieldses.org>
 <20130621083221.GA4103@geggus.net>
 <20130624215408.GD23596@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
In-Reply-To: <20130624215408.GD23596@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

J. Bruce Fields schrieb am Montag, den 24. Juni um 23:54 Uhr:

> Could you run
> 
> 	strace -p $(pidof rpc.svcgssd) -s4096 -e trace=open,close,read,write
> 
> on the server while trying this?

Hm how confidential is this information? This is a test-vm only, but should
I re-generate the krb5.keytab of the machine when posting this here?

Anyway, file attached.

Regards

Sven

-- 
Microsoft ist offenbar die einzige Firma, die in der Lage ist, ein mit
Office nicht kompatibles Bürosoftwarepaket einzuführen.
                            (Florian Weimer in de.alt.sysadmin.recovery)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="svcgssd-trace.txt"
Content-Transfer-Encoding: quoted-printable

read(4, "\\x \\x6082051f06092a864886f71201020201006e82050e3082050aa00302010=
5a10302010ea20703050020000000a382040761820403308203ffa003020105a1101b0e5043=
2e494954422e4648472e4445a2273025a003020103a11e301c1b036e66731b15766e6673727=
62e70632e696974622e6668672e6465a38203bb308203b7a003020117a103020102a28203a9=
048203a569e454c74d63a5e336da118e0d8632d542b66043e3affb1bd63db929ef215409ee7=
741ba6e47d4caf433076d42c32b7d96cc50c8db418052658d9833354ebd124c660bf375a8fe=
4fe956315808b5449c53fc15a9e5f7c6dfa1ec03c775a11ceba73e3557186fcac8276ad1fff=
c1bea70405461dbe104df6df64635439384c124c64eac7514e3dc73fb4413c0c8d57fcda1a7=
99a7b35479692bf59578b689dd831c1295e7544f8928f0f5e774c387663da07d8281a2d5ef5=
24a324ba11c8f749079b85b3c8b23fcf745032c984bc9a5b3bb20c42ed60671e48bb217e5e3=
74fed3d7c38a1e819452779db11f65a66e6c117f4bb727f202081a90699bbf720bc40dbd6fd=
7db62b6fc1dc86970b6a0e8852159003f2d575d175265a4451dfa622ae2098d6e1443dc274f=
6870b1402c02b07fa7608837f3a55ac61c3cd40ea8e24256da49f122b271a3101e41eb916dd=
d7267c1ed0318fa9adc44604851d328d3f8c3662baab909dce2d74dac949324985b50ccb289=
a4d44de80209203e165dff9b71c9d8c71a2c8badae16f61f7ef389567284d44b163620320eb=
825de51f4b78425022f19cf703941d316499c7972e96326f046aa951f5181b02e7ac24cb329=
2cfbee09e8976d4876f68ccf78f6fc802ef920452afb98f05cd0d15c4104c5ae9107ae19e9d=
be37e33279b4469f894a2772aff47a92562d44cce438b7cf624d2dd12f95f52db81f136028f=
c72143359940f694e22b680b756860010bff9b51a7c8ff0a448c54f5490cafa469630ee757f=
d1158255c0649c7c0270e5783ca5b47038d510f2c80cf4f00ea9157b7f96c3c3d25e082b7cf=
0a3ed9f5b4c21f8376c4b14fb61ff160a88cc8ec30f128c2b33a2ebd3d1d4052556553aef35=
d2010b15c105ebfbd7384102052923906bf87ba7dcdd1125ca07641939835d6174a95f9b63b=
12ee8fa23d7d34c7e1bfaeb278a9387aacd4e01bbe86ec7bbe6f9e255f56a9c441330cf947b=
916e8b1e807ccdbfe300283b02356eb5138d8153ab18366e9bd69c0573c1e5ddbde934e4e33=
892bc800817b545db2b54192003892f8b000277fa30e09ee6c90ac7eae605521ec724968439=
188b04d7fa22da24c36860d283765e3ac9fae8ad0a76e65c253a74d8dc8192f6ffeaf804ae0=
b08a54886fb289156c062a461d59e1b701824cedb45694922669d659113177c368142fbf9fa=
af0eddc06e928d7aded58b840e2ef3250433d4e82c0681ecff0916457badb460b43bb27f832=
e0785a0f0becc25789197276b8b80037cb54db8a3899b56468695bc92e7dea61f9c3d64e31a=
481e93081e6a003020117a281de0481db9b2606a032a287d3989d99a68691f0b7bc4df43b6f=
bae0a5a42c3cd069d6cb1437ac745360501c0224e9fab79cb3ba62b2de6af5fa81279701e97=
8f79e0127aab0b8d4f7528c6b733897167abb9be39ed13c245d3bc6dd7d8edf1be5844a3978=
a36e1f06cbc5c91f45e5cdc892a92a83ceca5ad86b50905a135c7f7c295977f837f5824670e=
0ed94d6cfdfe8df17b9b1821fa3728d3d56df9282b18cb9da1f755749bccc6cae0650911a52=
a1466385983467d0c5d814cca39f85adece4a438379f1458d837b1be0764f8b240b16bea9dc=
f84c0ef697ebff179d94e\n", 4096) =3D 2636
open("/proc/fs/nfsd/supported_krb5_enctypes", O_RDONLY) =3D 5
read(5, "18,17,16,23,3,1,2", 4096)      =3D 17
read(5, "", 4096)                       =3D 0
close(5)                                =3D 0
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "2\270?\307;\347\n1 \21\372\267\2460\351\262\270\tB\343", 20) =3D 20
close(5)                                =3D 0
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "\343\370\235>\335d\307\255\377\246\307\242|\213\264\317\336>/\211"=
, 20) =3D 20
close(5)                                =3D 0
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "\311m\315K.d\207hA\321\323H\201\356\246~zQ\346\177", 20) =3D 20
close(5)                                =3D 0
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "\251rhT\356\2263\10\352S\271B\36\301\373\244k\234\221x", 20) =3D 20
close(5)                                =3D 0
open("/etc/krb5.keytab", O_RDONLY)      =3D 5
read(5, "\5\2\0\0\0D\0\2\0\16PC.IITB.FHG.DE\0\4host\0\25vnfsrv.pc.iitb.fhg.=
de\0\0\0\1Q\260nq\2\0\1\0\10\346\2177^\v\302\255\250\0\0\0D\0\2\0\16PC.IITB=
=2EFHG.DE\0\4host\0\25vnfsrv.pc.iitb.fhg.de\0\0\0\1Q\260nq\2\0\3\0\10\346\2=
177^\v\302\255\250\0\0\0L\0\2\0\16PC.IITB.FHG.DE\0\4host\0\25vnfsrv.pc.iitb=
=2Efhg.de\0\0\0\1Q\260nq\2\0\27\0\20\200\205\364\330\203\321\331]\36\16\010=
5'\242\377C\0\0\0005\0\2\0\16PC.IITB.FHG.DE\0\4host\0\6VNFSRV\0\0\0\1Q\260n=
q\2\0\1\0\10\346\2177^\v\302\255\250\0\0\0005\0\2\0\16PC.IITB.FHG.DE\0\4hos=
t\0\6VNFSRV\0\0\0\1Q\260nq\2\0\3\0\10\346\2177^\v\302\255\250\0\0\0=3D\0\2\=
0\16PC.IITB.FHG.DE\0\4host\0\6VNFSRV\0\0\0\1Q\260nq\2\0\27\0\20\200\205\364=
\330\203\321\331]\36\16\0105'\242\377C\0\0\0000\0\1\0\16PC.IITB.FHG.DE\0\7V=
NFSRV$\0\0\0\1Q\260nq\2\0\1\0\10\346\2177^\v\302\255\250\0\0\0000\0\1\0\16P=
C.IITB.FHG.DE\0\7VNFSRV$\0\0\0\1Q\260nq\2\0\3\0\10\346\2177^\v\302\255\250\=
0\0\0008\0\1\0\16PC.IITB.FHG.DE\0\7VNFSRV$\0\0\0\1Q\260nq\2\0\27\0\20\200\2=
05\364\330\203\321\331]\36\16\0105'\242\377C\0\0\0C\0\2\0\16PC.IITB.FHG.DE\=
0\3nfs\0\25vnfsrv.pc.iitb.fhg.de\0\0\0\1Q\260n\231\2\0\1\0\10\346\2177^\v\3=
02\255\250\0\0\0C\0\2\0\16PC.IITB.FHG.DE\0\3nfs\0\25vnfsrv.pc.iitb.fhg.de\0=
\0\0\1Q\260n\231\2\0\3\0\10\346\2177^\v\302\255\250\0\0\0K\0\2\0\16PC.IITB.=
FHG.DE\0\3nfs\0\25vnfsrv.pc.iitb.fhg.de\0\0\0\1Q\260n\231\2\0\27\0\20\200\2=
05\364\330\203\321\331]\36\16\0105'\242\377C\0\0\0004\0\2\0\16PC.IITB.FHG.D=
E\0\3nfs\0\6VNFSRV\0\0\0\1Q\260n\231\2\0\1\0\10\346\2177^\v\302\255\250\0\0=
\0004\0\2\0\16PC.IITB.FHG.DE\0\3nfs\0\6VNFSRV\0\0\0\1Q\260n\232\2\0\3\0\10\=
346\2177^\v\302\255\250\0\0\0<\0\2\0\16PC.IITB.FHG.DE\0\3nfs\0\6VNFSRV\0\0\=
0\1Q\260n\232\2\0\27\0\20\200\205\364\330\203\321\331]\36\16\0105'\242\377C=
", 8192) =3D 966
close(5)                                =3D 0
write(3, "\1\0\0\0\0k\0\0\0HASH:AD338CB0C424A414DBAC3710F3651714 21:VENUS$@=
PC.IITB.FHG.DE 40:nfs/vnfsrv.pc.iitb.fhg.de@PC.IITB.FHG.DE\0E\200\7\0\200e\=
311Q\26\0\0\0VENUS$@PC.IITB.FHG.DE\0)\0\0\0nfs/vnfsrv.pc.iitb.fhg.de@PC.IIT=
B.FHG.DE\0E\200\7\0\200e\311Q", 203) =3D 203
open("/usr/lib/krb5/plugins/authdata", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CL=
OEXEC) =3D -1 ENOENT (No such file or directory)
open("/usr/lib/krb5/plugins/authdata", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CL=
OEXEC) =3D -1 ENOENT (No such file or directory)
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "\362\223F\31\237\250\277iP\200\256\270\251\204>\345\276\376r\230",=
 20) =3D 20
close(5)                                =3D 0
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "\225tEV\331\306\220\305\251!o\316.X\273\v*\312B\345", 20) =3D 20
close(5)                                =3D 0
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "HB.i\335\252\266m\22Vo)\210j\261\177\253\346\303m", 20) =3D 20
close(5)                                =3D 0
read(5, "\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\377\377\377\377\0=
\0\0\0\0\0\0\0\0\0\0\0", 36) =3D 36
close(5)                                =3D 0
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "\366\3\247\370\217\21.\310\335\200\357\350&Z\1\350\304\r2c", 20) =
=3D 20
close(5)                                =3D 0
open("/proc/net/rpc/auth.rpcsec.context/channel", O_WRONLY|O_CREAT|O_TRUNC,=
 0666) =3D 5
write(5, "\\x04000000 1372181158 -1 -1 0 krb5 \\x06000000a6d2c9517da62c3700=
000000120000008b9e7cb53082bca36502670079249e8e2c44aab7f8713ff9b09225c10f6a2=
057 \n", 143) =3D 143
close(5)                                =3D 0
open("/proc/net/rpc/auth.rpcsec.init/channel", O_WRONLY) =3D 5
write(5, "\\x \\x6082051f06092a864886f71201020201006e82050e3082050aa0030201=
05a10302010ea20703050020000000a382040761820403308203ffa003020105a1101b0e504=
32e494954422e4648472e4445a2273025a003020103a11e301c1b036e66731b15766e667372=
762e70632e696974622e6668672e6465a38203bb308203b7a003020117a103020102a28203a=
9048203a569e454c74d63a5e336da118e0d8632d542b66043e3affb1bd63db929ef215409ee=
7741ba6e47d4caf433076d42c32b7d96cc50c8db418052658d9833354ebd124c660bf375a8f=
e4fe956315808b5449c53fc15a9e5f7c6dfa1ec03c775a11ceba73e3557186fcac8276ad1ff=
fc1bea70405461dbe104df6df64635439384c124c64eac7514e3dc73fb4413c0c8d57fcda1a=
799a7b35479692bf59578b689dd831c1295e7544f8928f0f5e774c387663da07d8281a2d5ef=
524a324ba11c8f749079b85b3c8b23fcf745032c984bc9a5b3bb20c42ed60671e48bb217e5e=
374fed3d7c38a1e819452779db11f65a66e6c117f4bb727f202081a90699bbf720bc40dbd6f=
d7db62b6fc1dc86970b6a0e8852159003f2d575d175265a4451dfa622ae2098d6e1443dc274=
f6870b1402c02b07fa7608837f3a55ac61c3cd40ea8e24256da49f122b271a3101e41eb916d=
dd7267c1ed0318fa9adc44604851d328d3f8c3662baab909dce2d74dac949324985b50ccb28=
9a4d44de80209203e165dff9b71c9d8c71a2c8badae16f61f7ef389567284d44b163620320e=
b825de51f4b78425022f19cf703941d316499c7972e96326f046aa951f5181b02e7ac24cb32=
92cfbee09e8976d4876f68ccf78f6fc802ef920452afb98f05cd0d15c4104c5ae9107ae19e9=
dbe37e33279b4469f894a2772aff47a92562d44cce438b7cf624d2dd12f95f52db81f136028=
fc72143359940f694e22b680b756860010bff9b51a7c8ff0a448c54f5490cafa469630ee757=
fd1158255c0649c7c0270e5783ca5b47038d510f2c80cf4f00ea9157b7f96c3c3d25e082b7c=
f0a3ed9f5b4c21f8376c4b14fb61ff160a88cc8ec30f128c2b33a2ebd3d1d4052556553aef3=
5d2010b15c105ebfbd7384102052923906bf87ba7dcdd1125ca07641939835d6174a95f9b63=
b12ee8fa23d7d34c7e1bfaeb278a9387aacd4e01bbe86ec7bbe6f9e255f56a9c441330cf947=
b916e8b1e807ccdbfe300283b02356eb5138d8153ab18366e9bd69c0573c1e5ddbde934e4e3=
3892bc800817b545db2b54192003892f8b000277fa30e09ee6c90ac7eae605521ec72496843=
9188b04d7fa22da24c36860d283765e3ac9fae8ad0a76e65c253a74d8dc8192f6ffeaf804ae=
0b08a54886fb289156c062a461d59e1b701824cedb45694922669d659113177c368142fbf9f=
aaf0eddc06e928d7aded58b840e2ef3250433d4e82c0681ecff0916457badb460b43bb27f83=
2e0785a0f0becc25789197276b8b80037cb54db8a3899b56468695bc92e7dea61f9c3d64e31=
a481e93081e6a003020117a281de0481db9b2606a032a287d3989d99a68691f0b7bc4df43b6=
fbae0a5a42c3cd069d6cb1437ac745360501c0224e9fab79cb3ba62b2de6af5fa81279701e9=
78f79e0127aab0b8d4f7528c6b733897167abb9be39ed13c245d3bc6dd7d8edf1be5844a397=
8a36e1f06cbc5c91f45e5cdc892a92a83ceca5ad86b50905a135c7f7c295977f837f5824670=
e0ed94d6cfdfe8df17b9b1821fa3728d3d56df9282b18cb9da1f755749bccc6cae0650911a5=
2a1466385983467d0c5d814cca39f85adece4a438379f1458d837b1be0764f8b240b16bea9d=
cf84c0ef697ebff179d94e 1372153276 0 0 \\x04000000 \\x60819506092a864886f712=
01020202006f8185308182a003020105a10302010fa2763074a003020117a26d046b7f28020=
fbc8a21e2262984e72f679f2f479ca8f65781d8036441108e5e766292155e35b95496778862=
09f827195b561bda2333f4b66e51805385abbfb1e7ff1b676621aad8408d218530cfde68aaf=
4fc6513f1d07c87a2007b1c5d44c8d2f5d6acb47bc569f9faeff1ac7a \n", 2970) =3D 29=
70
close(5)                                =3D 0
open("/dev/urandom", O_RDONLY)          =3D 5
read(5, "\354\345pp@\231!\215\232r-5>\366\226\306\245\305\363\355", 20) =3D=
 20
close(5)                                =3D 0

--fdj2RfSjLxBAspz7--
