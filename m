From: "max williams" <max.williams@alliedtelesis.co.nz>
Subject: Strange NFS behaviour, working directory disappears
Date: Fri, 15 Sep 2006 14:19:59 +1200
Message-ID: <450AB68E.4A67.0005.0@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1017015102=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GO3JT-00039S-FP
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 19:20:19 -0700
Received: from gate.alliedtelesyn.co.nz ([202.49.72.33] ident=proxyuser)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GO3JT-000084-AH
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 19:20:20 -0700
To: <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1017015102==
Content-Type: multipart/alternative; boundary="=__PartF5D1B7DF.0__="

--=__PartF5D1B7DF.0__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi,
I have a strange issue on a number of PCs that mount /home via NFS. This =
started after upgrading the NFS server from Redhat 9 to Fedora Core 4. Ve=
ry occasionally the current working directory or a particular file "disap=
pears". When I say disappears I mean the client returns an odd error when=
=20running "ls -l" but on the NFS server the file/directory is fine.
Example:
=20
[root@tb39 maxw]# ls -l
ls: log.txt: No such file or directory
total 346704
-rw-r--r--    1 root     root         2605 Sep  4 12:03 b2l2.cfg
-rw-r--r--    1 root     root      8872116 Sep  4 11:19 b2l2issue.pcap
drwxrwxr-x    6 2997     2997         4096 May 12 14:59 bridge-utils-1.1
-rw-r--r--    1 root     root         2880 Sep  1 16:45 capture.pcap
-rw-------    1 root     root      1495040 Sep 11 10:18 core
drwxr-xr-x   17 10200    users        4096 May 17 10:16 dhcp-3.0.4
-rwxr--r--    1 root     root         1502 Jun 29 10:21 ixiacard.tcl
drwxr-xr-x    3 maxw     systest      4096 Jul 27 11:50 mrt
drwxr-xr-x    6 maxw     systest      4096 Sep 15 12:22 tests
drwxr--r--    2 maxw     systest      4096 Sep  5 10:19 tools
[root@tb39 maxw]#
=20
Or.....

[root@tb39 src]# ls -l
ls: .: No such file or directory
[root@tb39 src]#
=20
Usually you can fix it by "cd .." and then cd back into the same director=
y and then all is fine but we run a lot of automated scripts that are fai=
ling because of this issue. I have found it very hard to reproduce but it=
=20usually happens after a number of files have been created.
=20
Some info about my setup: The clients are running a customised version of=
=20Redhat 7.3 with mount version 2.12p and the server is running Fedora C=
ore 4. It worked fine when the NFS server for /home was running on Redhat=
=209. There are approx 180 clients all of which are diskless and use an N=
FS root file system.
=20
I have tried combinations of changing between V1, V2, V3, rsize/wsize, no=
lock, tcp/udp, nolock and hard/soft with no luck!
Any ideas????? or is there a way to get debug type output from NFS client=
s or servers?
Any help would be greatly appreciated!!
Thanks
=20
=20
=20
=20
=20
Max Williams
Technical Support Engineer
Allied Telesis Labs Limited
PO Box 8011, Christchurch
DDI: +64 3 339 9624

NOTICE: This message contains privileged and confidential
information intended only for the use of the addressee
named above. If you are not the intended recipient of
this message you are hereby notified that you must not
disseminate, copy or take any action in reliance on it.
If you have received this message in error please
notify Allied Telesis Labs Ltd immediately.
Any views expressed in this message are those of the
individual sender, except where the sender has the
authority to issue and specifically states them to
be the views of Allied Telesis Labs.

--=__PartF5D1B7DF.0__=
Content-Type: text/html; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Description: HTML

<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; charset=3Diso-8859-=
15">
<META content=3D"MSHTML 6.00.2900.2963" name=3DGENERATOR></HEAD>
<BODY style=3D"MARGIN: 4px 4px 1px; FONT: 10pt Tahoma">
<DIV>Hi,</DIV>
<DIV>I have a strange issue on a number of PCs that mount /home via NFS. =
This started&nbsp;after upgrading the NFS server from Redhat 9 to Fedora =
Core 4. Very occasionally the current working directory or a particular f=
ile&nbsp;"disappears". When I say disappears I mean the client returns an=
=20odd error when running "ls -l" but on the NFS server the file/director=
y is fine.</DIV>
<DIV>Example:</DIV>
<DIV>&nbsp;</DIV>
<DIV>[root@tb39 maxw]# ls -l<BR><STRONG><FONT color=3D#0000ff><FONT color=
=3D#ff0000>ls: log.txt: No such file or directory</FONT><BR></FONT></STRO=
NG>total 346704<BR>-rw-r--r--&nbsp;&nbsp;&nbsp; 1 root&nbsp;&nbsp;&nbsp;&=
nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2605 Sep&nbsp;=
=204 12:03 b2l2.cfg<BR>-rw-r--r--&nbsp;&nbsp;&nbsp; 1 root&nbsp;&nbsp;&nb=
sp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 8872116 Sep&nbsp; 4 11:19 b2=
l2issue.pcap<BR>drwxrwxr-x&nbsp;&nbsp;&nbsp; 6 2997&nbsp;&nbsp;&nbsp;&nbs=
p; 2997&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4096 May 12 14:59=
=20bridge-utils-1.1<BR>-rw-r--r--&nbsp;&nbsp;&nbsp; 1 root&nbsp;&nbsp;&nb=
sp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2880 Sep&n=
bsp; 1 16:45 capture.pcap<BR>-rw-------&nbsp;&nbsp;&nbsp; 1 root&nbsp;&nb=
sp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1495040 Sep 11 10:18 c=
ore<BR>drwxr-xr-x&nbsp;&nbsp; 17 10200&nbsp;&nbsp;&nbsp; users&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4096 May 17 10:16 dhcp-3.0.4<BR>-rwxr--r-=
-&nbsp;&nbsp;&nbsp; 1 root&nbsp;&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1502 Jun 29 10:21 ixiacard.tcl<BR>drwxr-xr=
-x&nbsp;&nbsp;&nbsp; 3 maxw&nbsp;&nbsp;&nbsp;&nbsp; systest&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; 4096 Jul 27 11:50 mrt<BR>drwxr-xr-x&nbsp;&nbsp;&nbsp; 6 =
maxw&nbsp;&nbsp;&nbsp;&nbsp; systest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4096 S=
ep 15 12:22 tests<BR>drwxr--r--&nbsp;&nbsp;&nbsp; 2 maxw&nbsp;&nbsp;&nbsp=
;&nbsp; systest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4096 Sep&nbsp; 5 10:19 tool=
s<BR>[root@tb39 maxw]#</DIV>
<DIV>&nbsp;</DIV>
<DIV>Or.....</DIV>
<DIV><BR>[root@tb39 src]# ls -l<BR><STRONG><FONT color=3D#ff0000>ls: .: N=
o such file or directory</FONT></STRONG><BR>[root@tb39 src]#</DIV>
<DIV>&nbsp;</DIV>
<DIV>Usually you can fix it by "cd .." and then cd back into the same dir=
ectory and then all is fine but we run a lot of automated scripts that ar=
e failing because of this issue. I have found it&nbsp;very hard to reprod=
uce but it usually happens after a number of files have been created.</DI=
V>
<DIV>&nbsp;</DIV>
<DIV>Some info about my setup: The clients are running a customised versi=
on of Redhat 7.3 with mount version 2.12p and&nbsp;the server is running =
Fedora Core 4. It worked fine when the NFS server for /home was running o=
n Redhat 9. There are approx 180 clients all of which&nbsp;are diskless a=
nd&nbsp;use an NFS root file system.</DIV>
<DIV>&nbsp;</DIV>
<DIV>I have tried combinations of changing between V1, V2,&nbsp;V3, rsize=
/wsize, nolock, tcp/udp, nolock and&nbsp;hard/soft with no luck!</DIV>
<DIV>Any ideas????? or is there a way to get debug type output from NFS c=
lients or servers?</DIV>
<DIV>Any help would be greatly appreciated!!</DIV>
<DIV>Thanks</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DTahoma size=3D2>Max Williams</FONT></DIV>
<DIV><FONT face=3DTahoma size=3D2>
<HR>
<FONT color=3D#808080 size=3D1>Technical Support Engineer<BR>Allied Teles=
is Labs Limited<BR>PO Box 8011, Christchurch<BR>DDI: +64 3 339 9624</FONT=
></FONT></DIV>
<BR>NOTICE: This message contains privileged and=20
confidential<BR>information intended only for the use of the addressee<BR=
>named=20
above. If you are not the intended recipient of<BR>this message you are h=
ereby=20
notified that you must not<BR>disseminate, copy or take any action in rel=
iance=20
on it.<BR>If you have received this message in error please<BR>notify All=
ied=20
Telesis&nbsp;Labs Ltd immediately.<BR>Any views expressed in this message=
=20are=20
those of the<BR>individual sender, except where the sender has the<BR>aut=
hority=20
to issue and specifically states them to<BR>be the views of Allied Telesi=
s=20
Labs.
</BODY></HTML>

--=__PartF5D1B7DF.0__=--


--===============1017015102==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1017015102==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1017015102==--
