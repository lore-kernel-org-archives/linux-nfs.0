From: Jerome Warnier <jwarnier@beeznest.net>
Subject: Re: Re: performance problem on nfs in kernel v2.4 and v2.6
Date: Thu, 15 Dec 2005 10:08:24 +0100
Message-ID: <1134637704.15949.2.camel@mobj>
References: <20051215011405.3037CFB047@gatekeeper.ncic.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emp6M-0007F8-NF
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 01:08:38 -0800
Received: from relay.be.colt.net ([212.35.96.70])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Emp6K-0003De-UG
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 01:08:38 -0800
Received: from localhost
	([127.0.0.1] helo=mobj ident=jwarnier)
	by sharonstone.beeznest.net with esmtp (Exim 3.36 #1 (Debian))
	id 1Emp6G-0005MG-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Dec 2005 10:08:32 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20051215011405.3037CFB047@gatekeeper.ncic.ac.cn>
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

Le jeudi 15 d=C3=A9cembre 2005 =C3=A0 09:12 +0800, =E9=99=88=E6=AC=A2 a =C3=
=A9crit :
> Chuck Lever,=E6=82=A8=E5=A5=BD=EF=BC=81
>=20
> 	when i did test on kernel 2.4.21, both client and server are of that ker=
nel version. So i did on kernel 2.6.11.12.
>=20
> 	the export option i use is : 	(rw,async,wdelay,hide,nocrossmnt,secure,no=
_root_squash,no_all_squash,subtree_check,secure_locks,mapping=3Didentity,an=
onuid=3D-2,anongid=3D-2)
>=20
> 	the filesystem is ext2.
>=20
> 	why i can't test the good performance i expected on v2.6.?
Did you try playing with the "rsize" and "wsize" options?

[..]

--=20
J=C3=A9r=C3=B4me Warnier
FLOSS Consultant
http://beeznest.net



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
