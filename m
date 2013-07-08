Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:47227 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220Ab3GHIII (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 04:08:08 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<lists@fuchsschwanzdomain.de>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Uw6UQ-0005Xx-CC
	for linux-nfs@vger.kernel.org; Mon, 08 Jul 2013 10:08:07 +0200
Date: Mon, 8 Jul 2013 10:08:05 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130708080803.GB29990@geggus.net>
References: <20130620080354.GA5591@geggus.net>
 <20130620144955.GB11728@fieldses.org>
 <20130620145209.GC11728@fieldses.org>
 <20130621083221.GA4103@geggus.net>
 <20130624215408.GD23596@fieldses.org>
 <20130625094612.GA2186@geggus.net>
 <20130701205234.GF19945@fieldses.org>
 <20130702080530.GA17953@geggus.net>
 <20130705181859.GA8288@fieldses.org>
 <20130705203435.GE8288@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
In-Reply-To: <20130705203435.GE8288@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Monday Monday, so good to me :)

On Friday, 5. Jul 2013 22:34, J. Bruce Fields wrote:

> Hm, might be interesting to see what mountd's doing too:
> 
> 	strace -p $(pidof rpc.svcgssd) -s4096 -e trace=open,close,read,write

OK, output attached. While reading this output I recogniced, that I
overlooked the following error-messages from rpc.svcgssd and rpc.mountd:

Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: WARN: failed to free lucid sec context
Jul  8 09:53:38 vnfsrv rpc.mountd[2927]: qword_eol: fprintf failed: errno 22 (Invalid argument)

> Hm, maybe this gid upcall?  Does the following (probably not completely
> right) help?

Yes, we are getting there. While the strange messages from rpc.svcgssd
persist, the mount now seems to work again after your patch has been
applied.

Regards

Sven

-- 
"Remember, democracy never lasts long. It soon wastes itself,
exhausts and murders itself. There never was a democracy yet
that did not commit suicide." (John Quincy Adams)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="strace-output-rpc.svcgssd"
Content-Transfer-Encoding: quoted-printable

read(4, "\\x \\x6082051f06092a864886f71201020201006e82050e3082050aa00302010=
5a10302010ea20703050020000000a382040761820403308203ffa003020105a1101b0e5043=
2e494954422e4648472e4445a2273025a003020103a11e301c1b036e66731b15766e6673727=
62e70632e696974622e6668672e6465a38203bb308203b7a003020117a103020102a28203a9=
048203a5c0be536630d9eddaa21dcaa5c68959ddcb5da7ea2ea2dbf2e641bd866fc5c5d1c0c=
21e261366d40775d8e8cec0c403f73255555ff92a20b373a778819bb1fa891e9ccfd6622a68=
3e5a3c466e731f5b884ed79ff25f44bbcf20b493753de50b0cb7b2dc25266427bf658db58a5=
1daba1339897c4d6709bb8cf220384faa7203bf9a92cfa2391d10eb3cf58a31aed3921b23cf=
1e49e0b91b615b51fea8d2c10307eec97ae4c8b5a0305105f1e5532f5f38dfc3ba6bd1f9667=
a5abd83fda0efaea4b532a5962c01a46fe8306072d3bc6d62062b10e73c0efe03316b3f9b81=
81b67d87fbc62cb371755b888e941cbd105d47e92b69439a87c36e438e5a0ee64f832efb8b4=
6f0c4c65222721a06bb29456a744df5fe56f6b91c2d947e7f41b15ed46dc73d19c5a11974cc=
50d5faa53ffd27014aba6b69adf28d8e9efa4630c595477246f2d1be456b9fa446b55ef4182=
dd5f0e1bd0f418ce1bca9181759e68424ca9c55c9a17e62ab19d84be413615f650bb0ba10d1=
fc938b81cda4623f113dbf74cab8254f5e7e3e6a16a86efb140c1abedc65176795067bf52bb=
3d273b0833859878e9b51894689d24080929b57763a507e7435effb351f6ac4f2658fd92ab5=
1c6b2b0b234ff413cbaf05e150ad19b220a8d63244bc6ebf601bc3ed3e5f5665c35b4bcb569=
6f8b5bcaff5ea829cd1cadb8ad1de0010e36fb8bf10305b396614d7bc483e2318391278c3c1=
04a8d49c52b0c64091f4771b9aa05a710273c0a9fc074577b0fd7ad076fb14ba7760c8a95ff=
a49e52c33520420304d90d1dbe1c7d4960ef19fec74dd1af6ec7da006ac0dbf7aea78520c7e=
e0a378e4ac1cbe84b40b6d7e6aa43a2dcdc059acd71292590993b403f10f54c9f003996fe58=
b135dd2a3c1e23c6c39414a7a06de39e1625e209c1f23004a413577bd4aa9456107158a2e44=
490aad8a6db67a0672eb7ae51e1b01c0bf4ce63cc5e4fdfeced6eb753f76f0940366c4c577a=
c6794030d8850f12c2052ee20fdbea7b0bcc10392d8bb96a114088787dc1183bfa9bb86f0cb=
5872a0087b9234015ccd9bc33ea7f415e3d4669197cc036e9cbc4849eb08e4e91e1d7c75158=
51c3e473ac1e92076f2b4ad549a99ca0c4b50431bc5f6e6693f3c5697f96168f91221e991f0=
8b0820d795d24b9caf587d70916c0e1b90fd51c6e615631039c1e748a841e349eb6d5272216=
bd2eec53ad09826e12a701886c46656627a1379f48e8b79592c2fd424b2b29414dec3d11093=
f618af48fa912105fd163c9b76df3a6f5a2608629b27e25b7476cc80cff8d8fdd466d5ff7fa=
481e93081e6a003020117a281de0481db5d54a6ca5f33bcd5f204274dc255945eb2ee22e465=
7eeae001d53df27a8bbdaf247e598050e5e9957588aad75de62ec64aaf586aed86cc173ce41=
ff9a590d5ac5588166cb2904470731606da0e29a16174ef44dab40383ba76f849994653073b=
94c1b50463cfb9e24068e07d93effa65ebd95ebb33a812a412fc6367d71dbcba30f7e95365f=
d787c00e23c98f4fb10a8bfc292426bad83305778d58e43758cd4b5005672c494812521d29c=
355a03e5e046927b5aff8ff12d7d9f07e70a4d3e8b7859fe9d8ae56595a3e89cb289f4f720e=
c28fbe179a160afcb2b4b\n", 4096) =3D 2636
open("/proc/fs/nfsd/supported_krb5_enctypes", O_RDONLY) =3D 13
read(13, "18,17,16,23,3,1,2", 4096)     =3D 17
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "=3D\255\177\337\3\32\23\234\363\336\6\221\"7b\232\177\272\35\255\=
10\317e\226\330\257\1\2\271\33(\303\r\247^\1\233\234>\372\26.\210\207\255]X=
\365\225\357<7t\22\34\243yp\327\325UvZ\4", 64) =3D 64
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "#\261\\\233\220\376I\227\27@\326c&\177\f\372 \371)B\1\237\302!\37=
3\375\215\3502\316\325|71\320\275\275\340\237\375\353RAR\256\307\222\254'\2=
07{&\265\36d\n6\244Y\36`C\246\345", 64) =3D 64
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "\352\224\336\fM\36Ys\2319)\333\10\256Pa8S?\274\215x\10I\5\270u\22=
5\21\206\370\314\343R\214\341\25eM\322\233\267\304cj\347\323dqH~\37\241?r\1=
7\330\0j\226<o\262{", 64) =3D 64
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "\362\0071\321\233\241\241\22\207[\363\352\314\327\2\273\265\1Q\36=
\215\205\355\255:\355\327\16\30\237\365\241\t\243}=3D\277O\220\v'P\202\254\=
36\203\212\317\26\311\360\377n\246\242\27\7\325\241\311\332\33V\257", 64) =
=3D 64
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "Lp\354\0\375\202\232:c\360F\262\2\272\226\212\261\311|1b\241\322\=
250\365\257M\260\302O\276\316\24B)A\265e\342\235\234\254\32\246\311\2.n[\31=
5\205\332[\354\244M\225\271n\317*l\207x", 64) =3D 64
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "Y\375\23\321>\315pb(\2427f\350|\367\311\377WEg\v\1\272Ff`\224\364=
\273?9\370\245\202\271\213\216\311\240\27 \10;\375+U>\273\317\307u0[\303[YL=
\237\331\236\262\27\2031", 64) =3D 64
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "\312F\336\211n_s\340\311\270\376=3D\212w\347\f\237\17E%\306\236t\=
5\2558\341\252c\250\366\4\356T\323\353\0\242A\24g\34\n\244ct<\17E\336\303\2=
328\341\301\274\3612v-X5\324)", 64) =3D 64
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "\357OB\240\217 }_\304gQ\363Al\245\36Y\345\317\244iBu\n\271\266\1z=
j\350rfV\373\244\261\373jz\225[\226\367\1\340\27\331\352\213U\337\370\17ZWu=
s\234!\337\272\372\341O", 64) =3D 64
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "\224\341\263\4\305\264\266\327T\20\243g\343Q\32t\3CPA/_Jt\352O\20=
5\376\225\330\365^]\214\242\214\212\200?s\315>\312W\7\373\0\343)b\244\230\2=
50v\6\24265\324\317\21\26\346\212", 64) =3D 64
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "\304\t\10Xm\320\304\273\371\327\333@\307\332\362\251j\246\356\347=
P\256\3238H\16\337\226\342\361\317\5\34\241\314W\205\333e\33@)n%z\2178\314\=
215\0374\204\0070Qd\v\374,\213z\360\212\376", 64) =3D 64
close(13)                               =3D 0
open("/etc/krb5.keytab", O_RDONLY)      =3D 13
read(13, "\5\2\0\0\0D\0\2\0\16PC.IITB.FHG.DE\0\4host\0\25vnfsrv.pc.iitb.fhg=
=2Ede\0\0\0\1Q\260nq\2\0\1\0\10\346\2177^\v\302\255\250\0\0\0D\0\2\0\16PC.I=
ITB.FHG.DE\0\4host\0\25vnfsrv.pc.iitb.fhg.de\0\0\0\1Q\260nq\2\0\3\0\10\346\=
2177^\v\302\255\250\0\0\0L\0\2\0\16PC.IITB.FHG.DE\0\4host\0\25vnfsrv.pc.iit=
b.fhg.de\0\0\0\1Q\260nq\2\0\27\0\20\200\205\364\330\203\321\331]\36\16\0105=
'\242\377C\0\0\0005\0\2\0\16PC.IITB.FHG.DE\0\4host\0\6VNFSRV\0\0\0\1Q\260nq=
\2\0\1\0\10\346\2177^\v\302\255\250\0\0\0005\0\2\0\16PC.IITB.FHG.DE\0\4host=
\0\6VNFSRV\0\0\0\1Q\260nq\2\0\3\0\10\346\2177^\v\302\255\250\0\0\0=3D\0\2\0=
\16PC.IITB.FHG.DE\0\4host\0\6VNFSRV\0\0\0\1Q\260nq\2\0\27\0\20\200\205\364\=
330\203\321\331]\36\16\0105'\242\377C\0\0\0000\0\1\0\16PC.IITB.FHG.DE\0\7VN=
FSRV$\0\0\0\1Q\260nq\2\0\1\0\10\346\2177^\v\302\255\250\0\0\0000\0\1\0\16PC=
=2EIITB.FHG.DE\0\7VNFSRV$\0\0\0\1Q\260nq\2\0\3\0\10\346\2177^\v\302\255\250=
\0\0\0008\0\1\0\16PC.IITB.FHG.DE\0\7VNFSRV$\0\0\0\1Q\260nq\2\0\27\0\20\200\=
205\364\330\203\321\331]\36\16\0105'\242\377C\0\0\0C\0\2\0\16PC.IITB.FHG.DE=
\0\3nfs\0\25vnfsrv.pc.iitb.fhg.de\0\0\0\1Q\260n\231\2\0\1\0\10\346\2177^\v\=
302\255\250\0\0\0C\0\2\0\16PC.IITB.FHG.DE\0\3nfs\0\25vnfsrv.pc.iitb.fhg.de\=
0\0\0\1Q\260n\231\2\0\3\0\10\346\2177^\v\302\255\250\0\0\0K\0\2\0\16PC.IITB=
=2EFHG.DE\0\3nfs\0\25vnfsrv.pc.iitb.fhg.de\0\0\0\1Q\260n\231\2\0\27\0\20\20=
0\205\364\330\203\321\331]\36\16\0105'\242\377C\0\0\0004\0\2\0\16PC.IITB.FH=
G.DE\0\3nfs\0\6VNFSRV\0\0\0\1Q\260n\231\2\0\1\0\10\346\2177^\v\302\255\250\=
0\0\0004\0\2\0\16PC.IITB.FHG.DE\0\3nfs\0\6VNFSRV\0\0\0\1Q\260n\232\2\0\3\0\=
10\346\2177^\v\302\255\250\0\0\0<\0\2\0\16PC.IITB.FHG.DE\0\3nfs\0\6VNFSRV\0=
\0\0\1Q\260n\232\2\0\27\0\20\200\205\364\330\203\321\331]\36\16\0105'\242\3=
77C", 8192) =3D 966
close(13)                               =3D 0
write(3, "\1\0\0\0\0k\0\0\0HASH:1112FD81D4B188BCA77FFDC69D0C32FF 21:VENUS$@=
PC.IITB.FHG.DE 40:nfs/vnfsrv.pc.iitb.fhg.de@PC.IITB.FHG.DE\0\214#\1\0\274m\=
332Q\26\0\0\0VENUS$@PC.IITB.FHG.DE\0)\0\0\0nfs/vnfsrv.pc.iitb.fhg.de@PC.IIT=
B.FHG.DE\0\214#\1\0\274m\332Q", 203) =3D 203
open("/usr/lib/x86_64-linux-gnu/krb5/plugins/authdata", O_RDONLY|O_NONBLOCK=
|O_DIRECTORY|O_CLOEXEC) =3D -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/krb5/plugins/authdata", O_RDONLY|O_NONBLOCK=
|O_DIRECTORY|O_CLOEXEC) =3D -1 ENOENT (No such file or directory)
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "w\253\244\312k\341q\342\251I:\33b34\322\210\32\213\246\225@\25\20=
4\25?\t\344\321\0038\322$:|s\177\30$\232\21B\203\23\331\320\327\310\34W\24x=
\2520\2\355~\251_\376x\304\262\36", 64) =3D 64
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "*xH\\0b|J\265\276\233o\253\320\352\212\364;\263\214\376#\n\16\254=
\363Qp\371\342.\370>\2348W\325\276xF\345q\21\334v\255\244\232d:\237\366~\31=
3\360h\210A\4s\314,\365\201", 64) =3D 64
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "!\237\364Z\310\305\221)\201[\313\253\277R\276P1\273\304\23\31\222=
T\266\2635(\2775\213\312\342\300M\272_\21\211x\301_HD\242\314bW\315A\200\25=
VQ\2113\340\233\n\5\3062\335T_", 64) =3D 64
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "\333-)\377\31^\347_\311\307\300\257\254\211\221\361}\251\371 \346=
\253\363J\267\33-\24\316\331=3D\250\233S\277\326h\0229l\355\242-\310\3630\v=
\4]\315\22\222\2454z\312\32\\\r\3t\312\2\f", 64) =3D 64
close(13)                               =3D 0
write(2, "rpc.svcgssd: ", 13)           =3D 13
write(2, "ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_C=
ONTEXT (No context has been established) - Unknown error\n", 122) =3D 122
write(2, "\n", 1)                       =3D 1
write(2, "rpc.svcgssd: ", 13)           =3D 13
write(2, "WARN: failed to free lucid sec context\n", 39) =3D 39
write(2, "\n", 1)                       =3D 1
open("/proc/net/rpc/auth.rpcsec.context/channel", O_WRONLY|O_CREAT|O_TRUNC,=
 0666) =3D 13
write(13, "\\x02000000 1373304166 -1 -1 0 krb5 \\x0600000066f5da51fe3cc6150=
00000001200000078e144e1ed0b6788fa4c4482792932f76ebdf8af531067a24badeb53eba8=
d9bd \n", 143) =3D 143
close(13)                               =3D 0
open("/proc/net/rpc/auth.rpcsec.init/channel", O_WRONLY) =3D 13
write(13, "\\x \\x6082051f06092a864886f71201020201006e82050e3082050aa003020=
105a10302010ea20703050020000000a382040761820403308203ffa003020105a1101b0e50=
432e494954422e4648472e4445a2273025a003020103a11e301c1b036e66731b15766e66737=
2762e70632e696974622e6668672e6465a38203bb308203b7a003020117a103020102a28203=
a9048203a5c0be536630d9eddaa21dcaa5c68959ddcb5da7ea2ea2dbf2e641bd866fc5c5d1c=
0c21e261366d40775d8e8cec0c403f73255555ff92a20b373a778819bb1fa891e9ccfd6622a=
683e5a3c466e731f5b884ed79ff25f44bbcf20b493753de50b0cb7b2dc25266427bf658db58=
a51daba1339897c4d6709bb8cf220384faa7203bf9a92cfa2391d10eb3cf58a31aed3921b23=
cf1e49e0b91b615b51fea8d2c10307eec97ae4c8b5a0305105f1e5532f5f38dfc3ba6bd1f96=
67a5abd83fda0efaea4b532a5962c01a46fe8306072d3bc6d62062b10e73c0efe03316b3f9b=
8181b67d87fbc62cb371755b888e941cbd105d47e92b69439a87c36e438e5a0ee64f832efb8=
b46f0c4c65222721a06bb29456a744df5fe56f6b91c2d947e7f41b15ed46dc73d19c5a11974=
cc50d5faa53ffd27014aba6b69adf28d8e9efa4630c595477246f2d1be456b9fa446b55ef41=
82dd5f0e1bd0f418ce1bca9181759e68424ca9c55c9a17e62ab19d84be413615f650bb0ba10=
d1fc938b81cda4623f113dbf74cab8254f5e7e3e6a16a86efb140c1abedc65176795067bf52=
bb3d273b0833859878e9b51894689d24080929b57763a507e7435effb351f6ac4f2658fd92a=
b51c6b2b0b234ff413cbaf05e150ad19b220a8d63244bc6ebf601bc3ed3e5f5665c35b4bcb5=
696f8b5bcaff5ea829cd1cadb8ad1de0010e36fb8bf10305b396614d7bc483e2318391278c3=
c104a8d49c52b0c64091f4771b9aa05a710273c0a9fc074577b0fd7ad076fb14ba7760c8a95=
ffa49e52c33520420304d90d1dbe1c7d4960ef19fec74dd1af6ec7da006ac0dbf7aea78520c=
7ee0a378e4ac1cbe84b40b6d7e6aa43a2dcdc059acd71292590993b403f10f54c9f003996fe=
58b135dd2a3c1e23c6c39414a7a06de39e1625e209c1f23004a413577bd4aa9456107158a2e=
44490aad8a6db67a0672eb7ae51e1b01c0bf4ce63cc5e4fdfeced6eb753f76f0940366c4c57=
7ac6794030d8850f12c2052ee20fdbea7b0bcc10392d8bb96a114088787dc1183bfa9bb86f0=
cb5872a0087b9234015ccd9bc33ea7f415e3d4669197cc036e9cbc4849eb08e4e91e1d7c751=
5851c3e473ac1e92076f2b4ad549a99ca0c4b50431bc5f6e6693f3c5697f96168f91221e991=
f08b0820d795d24b9caf587d70916c0e1b90fd51c6e615631039c1e748a841e349eb6d52722=
16bd2eec53ad09826e12a701886c46656627a1379f48e8b79592c2fd424b2b29414dec3d110=
93f618af48fa912105fd163c9b76df3a6f5a2608629b27e25b7476cc80cff8d8fdd466d5ff7=
fa481e93081e6a003020117a281de0481db5d54a6ca5f33bcd5f204274dc255945eb2ee22e4=
657eeae001d53df27a8bbdaf247e598050e5e9957588aad75de62ec64aaf586aed86cc173ce=
41ff9a590d5ac5588166cb2904470731606da0e29a16174ef44dab40383ba76f84999465307=
3b94c1b50463cfb9e24068e07d93effa65ebd95ebb33a812a412fc6367d71dbcba30f7e9536=
5fd787c00e23c98f4fb10a8bfc292426bad83305778d58e43758cd4b5005672c494812521d2=
9c355a03e5e046927b5aff8ff12d7d9f07e70a4d3e8b7859fe9d8ae56595a3e89cb289f4f72=
0ec28fbe179a160afcb2b4b 1373269499 0 0 \\x02000000 \\x60819506092a864886f71=
201020202006f8185308182a003020105a10302010fa2763074a003020117a26d046b60bea1=
3089ec0fa390c0936703f608842069597bfeff00469419cdb6aab8b3e02ad15174806fe8401=
2f2dc84cbd5304bbde04675c75eae472674609cf97a75a7a96306123387c70be8993a170c31=
c5f6ef6850d4905121272725e6ad523a10fd2f7ed0f5c76c4535f41421 \n", 2970) =3D 2=
970
close(13)                               =3D 0
open("/etc/krb5.conf", O_RDONLY)        =3D 13
read(13, "[libdefaults]\n  default_realm =3D PC.IITB.FHG.DE\n  default_tkt_=
enctypes =3D arcfour-hmac-md5\n  default_tgs_enctypes =3D arcfour-hmac-md5\=
n\t\n  forwardable =3D true\n\n[realms]\n  PC.IITB.FHG.DE =3D {\n    kdc =
=3D pcdc1.pc.iitb.fhg.de\n    kdc =3D pcdc2.pc.iitb.fhg.de\n  }\n\n[domain_=
realm]\n  pc.iitb.fhg.de =3D PC.IITB.FHG.DE\n  .pc.iitb.fhg.de =3D PC.IITB.=
FHG.DE\n\n\n", 4096) =3D 338
read(13, "", 4096)                      =3D 0
close(13)                               =3D 0
open("/dev/urandom", O_RDONLY)          =3D 13
read(13, "\347Y\373\4\247\233\30m\346\257\237\222\313\3318\35fJ\241\37I\350=
\374\366\276\333\2214\375\371l(\344\6\274\362\221\205U\213}\266\325\n;[\267=
\255X\360ogO6\24\247\30\242\333\322$\31;!", 64) =3D 64
close(13)                               =3D 0

--2oS5YaxWCcQjTEyO--
