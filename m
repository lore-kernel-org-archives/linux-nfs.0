From: "Thierry Davin" <tdavin@verio.net>
Subject: NFS update on highly accessed files
Date: Wed, 13 Nov 2002 14:13:54 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <PKEAIOMPGLHNCKJKNOOOOEIGDFAA.tdavin@verio.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0026_01C28B1E.E5DF6DA0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dfw-smtpout4.email.verio.net ([129.250.36.44])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18BxLG-00079h-00
	for <nfs@lists.sourceforge.net>; Wed, 13 Nov 2002 05:14:02 -0800
Received: from [129.250.38.63] (helo=dfw-mmp3.email.verio.net)
	by dfw-smtpout4.email.verio.net with esmtp
	id 18BxL9-0003XH-00
	for nfs@lists.sourceforge.net; Wed, 13 Nov 2002 13:13:55 +0000
Received: from [213.96.47.15] (helo=tdavin)
	by dfw-mmp3.email.verio.net with esmtp
	id 18BxK5-00010D-00
	for nfs@lists.sourceforge.net; Wed, 13 Nov 2002 13:12:49 +0000
To: <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.

------=_NextPart_000_0026_01C28B1E.E5DF6DA0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

Hi All,
We have a strange behaviour with our NFS installation. The NFS server runs
on a Network Appliance filer 810.

We have currently 3 clients mounting the same filesystem exported from the
netapp. The clients are web front ends which are all getting their content
from the NFS mount. The web site is heavily loaded.

Updates for the web files are done with FTP  thru one of the web front end.

For the most accessed files (like index.htm), the FTP updates only the
content on the FE where the FTP has been done! On the other Front Ends, the
attributes are correct (date, size, ...) but a "more" on the content of the
file displays the old one.

To manage to see the correct content of the other FE, I have to manually go
to the FE where the file have been uploaded, do a vi and save without
changing anything.

I don't see this behaviour consistent. Do you have any ideas?

Clients are redhat 7.2 with kernel 2.4.18. I tried with wu-ftpd (last
version) and proftpd (last version also).
mount options of the volume are:
(rw,hard,intr,vers=3,proto=udp,rsize=8192,wsize=8192,addr=xx.yy.zz.tt)

Thanks
Thierry Davin
Technical Account Manager
NTT / Verio Spain
Email: tdavin@verio.net
http://www.verio.es

------=_NextPart_000_0026_01C28B1E.E5DF6DA0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1106" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial size=3D2>Hi=20
All,</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial size=3D2>We =
have a strange=20
behaviour with our NFS installation. The NFS server runs on a Network =
Appliance=20
filer 810.</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial size=3D2>We =
have currently 3=20
clients mounting the same filesystem exported from the netapp. The =
clients are=20
web front ends which are all getting their content from the NFS mount. =
The web=20
site is heavily loaded.</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial =
size=3D2>Updates for the web=20
files are done with FTP&nbsp; thru one of the web front =
end.</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial size=3D2>For =
the most=20
accessed files (like index.htm), the FTP updates only the content on the =
FE=20
where the FTP has been done! On the other Front Ends, the attributes are =
correct=20
(date, size, ...) but a "more" on the content of the file displays the =
old=20
one.</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial size=3D2>To =
manage to see the=20
correct content of the other FE, I have to manually go to the FE where =
the file=20
have been uploaded, do a vi and save without changing=20
anything.</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial size=3D2>I =
don't see this=20
behaviour consistent. Do you have any ideas?</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial =
size=3D2>Clients are redhat=20
7.2 with kernel 2.4.18. I tried with wu-ftpd (last version) and proftpd =
(last=20
version also).</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial size=3D2>mount =
options of the=20
volume are:</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial=20
size=3D2>(rw,hard,intr,vers=3D3,proto=3Dudp,rsize=3D8192,wsize=3D8192,add=
r=3Dxx.yy.zz.tt)</FONT></SPAN></DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D125005412-13112002><FONT face=3DArial=20
size=3D2>Thanks</FONT></SPAN></DIV>
<DIV><FONT face=3DArial size=3D2>
<DIV><FONT face=3DArial size=3D2>Thierry Davin</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Technical Account Manager</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>NTT / Verio Spain</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Email: <A=20
href=3D"mailto:tdavin@verio.net">tdavin@verio.net</A></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><A=20
href=3D"http://www.verio.es/">http://www.verio.es</A></FONT></DIV></FONT>=
</DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_0026_01C28B1E.E5DF6DA0--



-------------------------------------------------------
This sf.net email is sponsored by: Are you worried about 
your web server security? Click here for a FREE Thawte 
Apache SSL Guide and answer your Apache SSL security 
needs: http://www.gothawte.com/rd523.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
