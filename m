From: Robin Soper <rsoperuk@yahoo.co.uk>
Subject: Bad write performance, Linux NFS client & Solaris NFS server
Date: Sat, 5 Feb 2005 22:37:33 +0000 (GMT)
Message-ID: <20050205223733.13270.qmail@web26510.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-1775321649-1107643053=:13258"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CxYYf-0006it-8Q
	for nfs@lists.sourceforge.net; Sat, 05 Feb 2005 14:37:41 -0800
Received: from web26510.mail.ukl.yahoo.com ([217.146.176.47])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CxYYd-0006hQ-Su
	for nfs@lists.sourceforge.net; Sat, 05 Feb 2005 14:37:40 -0800
To: nfs@lists.sourceforge.net
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

--0-1775321649-1107643053=:13258
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,
=20
I hope you can help, trying to use a Linux system as an NFS client to a S=
olaris server, read performance is great, but write performance is dreadf=
ully slow. I have tried everything I can try & searched the web where I s=
ee this probem reported frequently but never a real solution.
=20
Here's what I have:
=20
Client: Xeon 3.6Ghz, 4Gb RAM, Redhat Enterprise workstation update 3, Net=
work interface at 100 Mbit Full duplex forced
Sever: Sun V880, 6Gb RAM, Solaris 8,Gigabit interface, huge fast LSI disk=
 array system on fibre channel.
=20
The test I am running involves copying a 500Mbyte file to and from the se=
rver, which I believe is representitive of an application performance pro=
blem I am seeing. All I'm doing is copying the file from the server to th=
e client /tmp directory and then copying it back to another filesystem on=
 the server. Here's what I see: 45 sec to read the file from the server, =
1min:15 to copy the file back to the server.=20
=20
Using the same file and directories I used FTP to put and get the file an=
d got indentical times for read and write of 46 seconds. So I know my net=
work and filesystems are not the bottle neck, it seems to be specific to =
NFS write.
=20
I have tried every mount option available, tcp,udp, v2,v3, I have changed=
 rsize and wsize from 8192 to 32768. I have changed buffer sizes etc but =
it makes no difference to the problem.=20
=20
I repeated the tests with a Solaris client system and it took identical t=
imes for both read and write tests, 50 seconds. And this is an old Ultra =
60 system with 1Gb of RAM.
=20
I repeated the tests but this time using a Linux system as the NFS server=
 and write performance was great, read and write took the same time.
=20
What gives, are Linux and Solaris incompatible from and NFS performance s=
tandpoint?
Surely I can't be the first person to encounter this problem. I tried log=
ging a call with RedHat but they said they didn't support using Linux  as=
 an NFS client to Solaris...
=20
I would really appreciate any advice on this one
=20
Regards
Robin
=20

	=09
---------------------------------
 ALL-NEW Yahoo! Messenger - all new features - even more fun! =20
--0-1775321649-1107643053=:13258
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<DIV>Hi,</DIV>
<DIV>&nbsp;</DIV>
<DIV>I hope you can help, trying to use a Linux system as an NFS client t=
o a Solaris server, read performance is great, but write performance is d=
readfully slow. I have tried everything I can try &amp;&nbsp;searched the=
 web where I see this probem reported frequently but never a real solutio=
n.</DIV>
<DIV>&nbsp;</DIV>
<DIV>Here's what I have:</DIV>
<DIV>&nbsp;</DIV>
<DIV>Client: Xeon 3.6Ghz, 4Gb RAM, Redhat Enterprise workstation update 3=
, Network interface at 100 Mbit Full duplex forced</DIV>
<DIV>Sever: Sun V880, 6Gb RAM, Solaris 8,Gigabit interface, huge fast LSI=
 disk array system on fibre channel.</DIV>
<DIV>&nbsp;</DIV>
<DIV>The test I am running involves copying a 500Mbyte file to and from t=
he server, which I believe is representitive of an application performanc=
e problem I am seeing. All I'm doing is&nbsp;copying the file from the se=
rver to the client /tmp directory and then copying it back to another fil=
esystem on the server. Here's what I see: 45 sec to read the file from th=
e server, 1min:15 to copy the file back to the server. </DIV>
<DIV>&nbsp;</DIV>
<DIV>Using the same file and directories I used FTP to put and get the fi=
le and got indentical times for read and write of 46 seconds. So I know m=
y network and filesystems are not the bottle neck, it seems to be specifi=
c to NFS&nbsp;write.</DIV>
<DIV>&nbsp;</DIV>
<DIV>I&nbsp;have tried every mount option available, tcp,udp, v2,v3, I ha=
ve changed rsize and wsize from 8192 to 32768. I have changed buffer size=
s etc but it makes no difference to the problem. </DIV>
<DIV>&nbsp;</DIV>
<DIV>I repeated the tests with a Solaris client system and it took identi=
cal times for both read and write tests, 50 seconds. And this is an old U=
ltra 60 system with 1Gb of RAM.</DIV>
<DIV>&nbsp;</DIV>
<DIV>I repeated the tests but this time using a Linux system as&nbsp;the =
NFS server and write performance was great, read and write took the same =
time.</DIV>
<DIV>&nbsp;</DIV>
<DIV>What gives, are Linux and Solaris incompatible from and NFS performa=
nce standpoint?</DIV>
<DIV>Surely I can't be the first person to encounter this problem. I trie=
d logging a call with RedHat but they said they didn't support using Linu=
x&nbsp; as an NFS client to Solaris...</DIV>
<DIV>&nbsp;</DIV>
<DIV>I would really appreciate any&nbsp;advice on this one</DIV>
<DIV>&nbsp;</DIV>
<DIV>Regards</DIV>
<DIV>Robin</DIV>
<DIV>&nbsp;</DIV><p>
		<hr size=3D1> <font size=3D"2" face=3D"Verdana, Arial, Helvetica, sans-=
serif"><a href=3D"http://uk.rd.yahoo.com/mail/taglines/default/messenger/=
*http://uk.messenger.yahoo.com"><strong><font face=3D"Arial, Helvetica, s=
ans-serif">ALL-NEW=20
Yahoo! Messenger</font></strong></a><font face=3D"Arial, Helvetica, sans-=
serif"><strong>=20
- all new features - even more fun!</strong></font><strong><font color=3D=
"#FF9900">=20
</font></strong></font>=20
--0-1775321649-1107643053=:13258--


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
