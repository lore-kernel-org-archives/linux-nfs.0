From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: "reply ERR" tcpdump output means what (TCP mounts over WAN)
Date: Mon, 15 Sep 2003 08:49:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127F08@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19yvc7-0000yW-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Sep 2003 08:50:07 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19yvc6-0001Dj-Jg
	for nfs@lists.sourceforge.net; Mon, 15 Sep 2003 08:50:06 -0700
To: "Scott Mcdermott" <smcdermott@questra.com>
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

hi scott-

can you provide a pcap format tcpdump?  the text output below
omits most of the details we need to help you with your problem.

on your client:

   su
   tcpdump -s0 -w/tmp/dump.pcap host name-of-your-server-here

i've found that on slow asymmetric WAN links, using the "sync"
mount option on the client helps performance, and prevents
your NFS client from hogging all available network bandwidth
at the expense of other (interactive) sessions.

you can also try fiddling with your client's read ahead
parameters (see "sysctl" to tune vm.min-readahead and
vm.max-readahead).


> -----Original Message-----
> From: Scott Mcdermott [mailto:smcdermott@questra.com]
> Sent: Friday, September 12, 2003 5:47 PM
> To: nfs@lists.sourceforge.net
> Cc: Scott McDermott
> Subject: [NFS] "reply ERR" tcpdump output means what (TCP mounts over
> WAN)
>=20
>=20
> I'm mounting a v3 export from a 2.4.22-rc2 server to a
> 2.4.22-pre4 client, over a WAN connection (it's over an
> IPSEC tunnel, 1.5Mbits server -> client and 128Kbits client
> -> server, 90ms round trip).  I simply mounted -o rw,tcp.  I
> used a reliable transport because I thought it would be more
> approporate over a link like this.
>=20
> It works fine, but it's REALLY slow.
>=20
> Here's some output from loading a Maildir-format spool (the
> below is from the server)
>=20
> 17:22:31.910279 10.20.8.30.2049 > 10.0.0.8.1698577506: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:32.029639 10.20.8.30.2049 > 10.0.0.8.544434554: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:32.159093 10.20.8.30.2049 > 10.0.0.8.2848670243: reply=20
> ok 236 (DF) [tos 0x2,ECT]
> 17:22:32.260640 10.20.8.30.2049 > 10.0.0.8.2865447459: reply=20
> ok 1376 (DF) [tos 0x2,ECT]
> 17:22:32.260679 10.20.8.30.2049 > 10.0.0.8.1026770003: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:32.370613 10.20.8.30.2049 > 10.0.0.8.1634623304: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:32.370638 10.20.8.30.2049 > 10.0.0.8.2002875168: reply=20
> ERR 68 (DF) [tos 0x2,ECT]
> 17:22:32.589138 10.20.8.30.2049 > 10.0.0.8.2899001891: reply=20
> ok 1376 (DF) [tos 0x2,ECT]
> 17:22:32.809437 10.20.8.30.2049 > 10.0.0.8.2932556323: reply=20
> ok 1376 (DF) [tos 0x2,ECT]
> 17:22:32.809484 10.20.8.30.2049 > 10.0.0.8.1733515061: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:32.919132 10.20.8.30.2049 > 10.0.0.8.1229416566: reply=20
> ERR 100 (DF) [tos 0x2,ECT]
> 17:22:33.020512 10.20.8.30.2049 > 10.0.0.8.2949333539: reply=20
> ok 736 (DF) [tos 0x2,ECT]
> 17:22:33.121527 10.20.8.30.2049 > 10.0.0.8.2966110755: reply=20
> ok 236 (DF) [tos 0x2,ECT]
> 17:22:33.218590 10.20.8.30.2049 > 10.0.0.8.2982887971: reply=20
> ok 1376 (DF) [tos 0x2,ECT]
> 17:22:33.218627 10.20.8.30.2049 > 10.0.0.8.1932422757: reply=20
> ERR 816 (DF) [tos 0x2,ECT]
> 17:22:33.342968 10.20.8.30.2049 > 10.0.0.8.2999665187: reply=20
> ok 236 (DF) [tos 0x2,ECT]
> 17:22:33.437201 10.20.8.30.2049 > 10.0.0.8.3016442403: reply=20
> ok 1376 (DF) [tos 0x2,ECT]
> 17:22:33.437239 10.20.8.30.2049 > 10.0.0.8.812402511: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.547541 10.20.8.30.2049 > 10.0.0.8.896350316: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.547566 10.20.8.30.2049 > 10.0.0.8.1112298345: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.659641 10.20.8.30.2049 > 10.0.0.8.927545443: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.698638 10.20.8.30.2049 > 10.0.0.8.943937290: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.707383 10.20.8.30.nfs > 10.0.0.8.798: . ack=20
> 1967536866 win 22512 <nop,nop,timestamp 244760041 7925237> (DF)
> 17:22:33.718735 10.20.8.30.nfs > 10.0.0.8.798: . ack 129 win=20
> 22512 <nop,nop,timestamp 244760042 7925237> (DF)
> 17:22:33.769462 10.20.8.30.2049 > 10.0.0.8.1111057268: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.769492 10.20.8.30.2049 > 10.0.0.8.894593401: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.818440 10.20.8.30.2049 > 10.0.0.8.1295467855: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.881110 10.20.8.30.2049 > 10.0.0.8.1647340856: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.919503 10.20.8.30.2049 > 10.0.0.8.946622820: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.965985 10.20.8.30.2049 > 10.0.0.8.1314288944: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:33.990356 10.20.8.30.2049 > 10.0.0.8.1448767600: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:34.029968 10.20.8.30.2049 > 10.0.0.8.794908245: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
> 17:22:34.102846 10.20.8.30.2049 > 10.0.0.8.1181575987: reply=20
> ERR 608 (DF) [tos 0x2,ECT]
> 17:22:34.217498 10.20.8.30.nfs > 10.0.0.8.798: . ack 545 win=20
> 22512 <nop,nop,timestamp 244760092 7925288> (DF)
> 17:22:34.224557 10.20.8.30.2049 > 10.0.0.8.3117105699: reply=20
> ok 1376 (DF) [tos 0x2,ECT]
> 17:22:34.442064 10.20.8.30.2049 > 10.0.0.8.3150660131: reply=20
> ok 1376 (DF) [tos 0x2,ECT]
> 17:22:34.442103 10.20.8.30.2049 > 10.0.0.8.1935897193: reply=20
> ERR 1376 (DF) [tos 0x2,ECT]
>=20
> what are these ERRs and how to avoid them? I assume they're
> not normal?
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
