From: "=?GB2312?Q?=B3=C2=BB=B6?=" <huanchen@ncic.ac.cn>
Subject: Re: Re: performance problem on nfs in kernel v2.4 and v2.6
Date: Thu, 15 Dec 2005 9:12:20 +0800
Message-ID: <20051215011405.3037CFB047@gatekeeper.ncic.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain;
      charset="GB2312"
Cc: nfs@lists.sourceforge.net <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmhfZ-000218-ID
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 17:12:29 -0800
Received: from gatekeeper.ncic.ac.cn ([159.226.41.188] helo=ncic.ac.cn)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EmhfX-0004nM-K0
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 17:12:29 -0800
To: cel@citi.umich.edu <cel@citi.umich.edu>
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

Chuck Lever,=C4=FA=BA=C3=A3=A1

=09when i did test on kernel 2.4.21, both client and server are of=
 that kernel version. So i did on kernel 2.6.11.12.

=09the export option i use is :=
 =09(rw,async,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_s=
quash,subtree_check,secure_locks,mapping=3Didentity,anonuid=3D-2,anon=
gid=3D-2)

=09the filesystem is ext2.

=09why i can't test the good performance i expected on v2.6.?

=3D=3D=3D=3D=3D=3D=3D 2005-12-14 15:16:00 =C4=FA=D4=DA=C0=B4=D0=C5=D6=D0=D0=B4=B5=C0=A3=BA=3D=3D=3D=3D=3D=3D=3D

>huanchen-
>
>you tell us which kernels you've tried, but it's not clear
>whether you are switching the client or the server kernel.
>
>also, what export options do you use on the server?  and
>what file system?
>
>
>
>=B3=C2=BB=B6 wrote:
>> nfs:
>> 
>> =09
>> =09I did some test on nfs in linux kernel v2.6 ,but there are=
 some problem i can't solve.
>> =09I need your help!
>> 
>> =09I run iozone on nfs in kernel v2.4.21 and v2.6.11.12 ,the=
 test result is as follows:
>> =09v2.4.21:    write performance 106MB/s   (wsize,rsize=3D8192)
>> =09v2.6.11.12: write performance 52MB/s ;  (wsize,rsize=3D32768)
>> 
>> =09the iozone test command I use is : 
>> =09=09iozone -c -e -f /mnt/nfs/file1 -s 1g -r 2m -i 0 -w
>> 
>> =09My question is why the performance is lower when using v2.6?
>> 
>> =09The test platform is :
>> =09=09client: 1G memory,
>> =09=09server: 4G memory, 146G disk. 2cpu.
>> =09=09net: 1000Mb
>> 
>> =09When i use the following command to chechk why v2.6 takes=
 much more time, I found that the fsync operations takes much=
 more time. the command is:
>> =09strace -o result -T write, close, fsync ./iozone -c -e -f=
 /mnt/nfs/file1 -s 1g -r 2m -i 0 -w
>> =09the result of this command is that the time of write is=
 6(ms),while the time of sync before close is 6 (s).
>> 
>> =09So what is wrong? how can i see performance improvement of=
 nfs in v2.6. Is there any key value I can tune ?    Or the=
 problem relates to the removal of flushd while introducing =
 pdflush in client memory management ?
>> 
>> =09Thank you!  Waiting for your reply!
>> 
>> 
>> ------------------------------------------------------------
>> National Research Center for Intelligent Computing Systems
>> Insitute of Computing Technology
>> Chinese Academy of Sciences=A1=A1=A1=A1=A1=A1
>> ------------------------------------------------------------
>> =09=09
>> 
>> =A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1
>> =A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1huanchen@ncic.ac.cn
>> =A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A12005-12-14
>> 
>> 
>> 
>> 
>> -------------------------------------------------------
>> This SF.net email is sponsored by: Splunk Inc. Do you grep=
 through log files
>> for problems?  Stop!  Download the new AJAX search engine that=
 makes
>> searching your log files as easy as surfing the  web. =
 DOWNLOAD SPLUNK!
>> http://ads.osdn.com/?ad_idv37&alloc_id=16865&op=3Dclick
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs

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
