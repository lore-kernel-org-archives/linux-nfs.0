From: "=?GB2312?Q?=B3=C2=BB=B6?=" <huanchen@ncic.ac.cn>
Subject: Re: Re: Re: performance problem on nfs in kernel v2.4 and v2.6
Date: Thu, 15 Dec 2005 17:16:2 +0800
Message-ID: <20051215091751.7DE11FB046@gatekeeper.ncic.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain;
      charset="GB2312"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmpDq-0007kq-Dr
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 01:16:22 -0800
Received: from gatekeeper.ncic.ac.cn ([159.226.41.188] helo=ncic.ac.cn)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EmpDo-0007Ta-LX
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 01:16:22 -0800
To: Jerome Warnier <jwarnier@beeznest.net>,
	nfs@lists.sourceforge.net <nfs@lists.sourceforge.net>
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

Jerome Warnier,=C4=FA=BA=C3=A3=A1

=09yes, I did have do that .
=09in case 2.6.11, I tried rsize,wsize=3D8192/16384/32768, however,=
 the results were bad.

=3D=3D=3D=3D=3D=3D=3D 2005-12-15 10:08:00 =C4=FA=D4=DA=C0=B4=D0=C5=D6=D0=D0=B4=B5=C0=A3=BA=3D=3D=3D=3D=3D=3D=3D

>Le jeudi 15 d=A8=A6cembre 2005 =A8=A4 09:12 +0800, =B3=C2=BB=B6 a =A8=A6crit :
>> Chuck Lever,=C4=FA=BA=C3=A3=A1
>> 
>> =09when i did test on kernel 2.4.21, both client and server are=
 of that kernel version. So i did on kernel 2.6.11.12.
>> 
>> =09the export option i use is :=
 =09(rw,async,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_s=
quash,subtree_check,secure_locks,mapping=3Didentity,anonuid=3D-2,anon=
gid=3D-2)
>> 
>> =09the filesystem is ext2.
>> 
>> =09why i can't test the good performance i expected on v2.6.?
>Did you try playing with the "rsize" and "wsize" options?
>
>[..]
>
>-- 
>J=A8=A6r?me Warnier
>FLOSS Consultant
>http://beeznest.net
>
>
>
>-------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc. Do you grep=
 through log files
>for problems?  Stop!  Download the new AJAX search engine that=
 makes
>searching your log files as easy as surfing the  web.  DOWNLOAD=
 SPLUNK!
>http://ads.osdn.com/?ad_idv37&alloc_id=16865&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

=3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D =3D
=09=09=09

=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=D6=C2
=C0=F1=A3=A1
 
=09=09=09=09 
=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=B3=C2=BB=B6
=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1huanchen@ncic.ac.cn
=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A12005-12-15





-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
