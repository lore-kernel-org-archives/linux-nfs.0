From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: performance problem on nfs in kernel v2.4 and v2.6
Date: Wed, 14 Dec 2005 15:16:26 -0800
Message-ID: <43A0A7CA.1020006@citi.umich.edu>
References: <20051214021641.0C18CFB045@gatekeeper.ncic.ac.cn>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000300040903050604010600"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmfrQ-0002FJ-1d
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 15:16:36 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmfrN-0000JJ-EI
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 15:16:35 -0800
To: =?GB2312?B?s8K7tg==?= <huanchen@ncic.ac.cn>
In-Reply-To: <20051214021641.0C18CFB045@gatekeeper.ncic.ac.cn>
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

This is a multi-part message in MIME format.
--------------000300040903050604010600
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable

huanchen-

you tell us which kernels you've tried, but it's not clear
whether you are switching the client or the server kernel.

also, what export options do you use on the server?  and
what file system?



=B3=C2=BB=B6 wrote:
> nfs:
>=20
> =09
> 	I did some test on nfs in linux kernel v2.6 ,but there are some proble=
m i can't solve.
> 	I need your help!
>=20
> 	I run iozone on nfs in kernel v2.4.21 and v2.6.11.12 ,the test result =
is as follows:
> 	v2.4.21:    write performance 106MB/s   (wsize,rsize=3D8192)
> 	v2.6.11.12: write performance 52MB/s ;  (wsize,rsize=3D32768)
>=20
> 	the iozone test command I use is :=20
> 		iozone -c -e -f /mnt/nfs/file1 -s 1g -r 2m -i 0 -w
>=20
> 	My question is why the performance is lower when using v2.6?
>=20
> 	The test platform is :
> 		client: 1G memory,
> 		server: 4G memory, 146G disk. 2cpu.
> 		net: 1000Mb
>=20
> 	When i use the following command to chechk why v2.6 takes much more ti=
me, I found that the fsync operations takes much more time. the command i=
s:
> 	strace -o result -T write, close, fsync ./iozone -c -e -f /mnt/nfs/fil=
e1 -s 1g -r 2m -i 0 -w
> 	the result of this command is that the time of write is 6(ms),while th=
e time of sync before close is 6 (s).
>=20
> 	So what is wrong? how can i see performance improvement of nfs in v2.6=
. Is there any key value I can tune ?    Or the problem relates to the re=
moval of flushd while introducing  pdflush in client memory management ?
>=20
> 	Thank you!  Waiting for your reply!
>=20
>=20
> ------------------------------------------------------------
> National Research Center for Intelligent Computing Systems
> Insitute of Computing Technology
> Chinese Academy of Sciences=A1=A1=A1=A1=A1=A1
> ------------------------------------------------------------
> 	=09
>=20
> =A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1
> =A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1huanchen@ncic.ac.cn
> =A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A12005-12-14
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc. Do you grep through log =
files
> for problems?  Stop!  Download the new AJAX search engine that makes
> searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
> http://ads.osdn.com/?ad_idv37&alloc_id=16865&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


--------------000300040903050604010600
Content-Type: text/x-vcard; charset=utf-8;
 name="cel.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="cel.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6TmV0d29y
ayBBcHBsaWFuY2UsIEluY29ycG9yYXRlZDtPcGVuIFNvdXJjZSBORlMgQ2xpZW50IEVuZ2lu
ZWVyaW5nDQplbWFpbDtpbnRlcm5ldDpjZWxAY2l0aS51bWljaC5lZHUNCnRpdGxlOk1lbWJl
ciBvZiBUZWNobmljYWwgU3RhZmYNCngtbW96aWxsYS1odG1sOkZBTFNFDQp1cmw6aHR0cDov
L3d3dy5tb25rZXkub3JnL35jZWwNCnZlcnNpb246Mi4xDQplbmQ6dmNhcmQNCg0K
--------------000300040903050604010600--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
