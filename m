From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: nfs-utils mount build fails due to missing fsloc.h
Date: Fri, 2 Mar 2007 14:40:34 -0800
Message-ID: <01AE8AF878612047A442668306EAEB055C3FE2@SACEXMV01.hq.netapp.com>
References: <E1HNG8e-0000Y8-Ha@externalmx-1.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0086016035=="
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HNGQd-00086r-1W
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 14:40:43 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HNGQe-0006ev-Rz
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 14:40:45 -0800
Received: from svlexc03.hq.netapp.com (svlexc03.corp.netapp.com
	[10.57.156.149])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l22MebPO025770
	for <nfs@lists.sourceforge.net>; Fri, 2 Mar 2007 14:40:37 -0800 (PST)
In-Reply-To: <E1HNG8e-0000Y8-Ha@externalmx-1.sourceforge.net>
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

This is a multi-part message in MIME format.

--===============0086016035==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C75D1B.F387A944"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C75D1B.F387A944
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi all,
=20
When I pull nfs-utils from the git repository, mountd fails to build due
to a missing .h file (fsloc.h).  This has been the case for some time
now.  I originally thought I had just pulled at a bad time (in the
middle of an update), but when I pulled a 1.0.12+ branch today, I hit
the same problem.
=20
I'm just doing:
=20
    git clone git://git.linux-nfs.org/nfs-utils
    sh autogen.sh=20
    ./configure=20
    make
=20
The dependencies I currently have listed for building/running nfs-utils
are: libevent (1.3a), libnfsidmap (0.19), libgssapi (0.10), librpcsecgss
(0.14), and various Kerberos bits (1.6 from MIT).
=20
Is there something else I need to do/undo to get the latest tree to
build?
=20
  -Dan
=20
=20
=20

------_=_NextPart_001_01C75D1B.F387A944
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML xmlns:o =3D "urn:schemas-microsoft-com:office:office" xmlns:st1 =
=3D=20
"urn:schemas-microsoft-com:office:smarttags"><HEAD><TITLE>9-15 =
&#20449;&#32440;</TITLE>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii"><BASE=20
href=3D"file://C:\Documents and Settings\china user\Application =
Data\Microsoft\Stationery\">
<META content=3D"MSHTML 6.00.2900.3059" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY style=3D"FONT-SIZE: 9pt; COLOR: #000000; FONT-FAMILY: =
&#23435;&#20307;" bgColor=3D#ffffff=20
background=3D"">
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT =
size=3D3>Hi=20
all,</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT=20
size=3D3></FONT></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT =
size=3D3>When I pull=20
nfs-utils from the git repository, mountd fails to build due to a =
missing .h=20
file (fsloc.h).&nbsp; This has been the case for some time now.&nbsp; I=20
originally thought I had just pulled at&nbsp;a bad time (in the middle =
of an=20
update), but&nbsp;when I pulled&nbsp;a 1.0.12+ branch today, I hit the =
same=20
problem.</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT=20
size=3D3></FONT></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT =
size=3D3>I'm just=20
doing:</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT=20
size=3D3></FONT></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT=20
size=3D3>&nbsp;&nbsp;&nbsp; git clone=20
git://git.linux-nfs.org/nfs-utils</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT=20
size=3D3>&nbsp;&nbsp;&nbsp; sh autogen.sh </FONT></DIV>
<DIV dir=3Dltr><FONT size=3D3><SPAN =
class=3D196092822-02032007>&nbsp;&nbsp;&nbsp;=20
</SPAN>./configure </FONT></DIV>
<DIV dir=3Dltr><FONT size=3D3><SPAN =
class=3D196092822-02032007>&nbsp;&nbsp;&nbsp;=20
</SPAN>make</FONT></DIV>
<DIV dir=3Dltr><FONT size=3D3></FONT>&nbsp;</DIV>
<DIV dir=3Dltr><SPAN class=3D196092822-02032007><FONT size=3D3>The =
dependencies I=20
currently have listed for building/running nfs-utils are: libevent =
(1.3a),=20
libnfsidmap (0.19), libgssapi (0.10), librpcsecgss (0.14), and various =
Kerberos=20
bits (1.6 from MIT).</FONT></SPAN></DIV>
<DIV dir=3Dltr><SPAN class=3D196092822-02032007><FONT=20
size=3D3></FONT></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr><SPAN class=3D196092822-02032007><FONT size=3D3>Is there =
something else=20
I need to do/undo to get the latest tree to build?</FONT></SPAN></DIV>
<DIV dir=3Dltr><SPAN class=3D196092822-02032007><FONT=20
size=3D3></FONT></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr><SPAN class=3D196092822-02032007><FONT size=3D3>&nbsp;=20
-Dan</FONT></SPAN></DIV>
<DIV dir=3Dltr align=3Dleft></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><SPAN class=3D196092822-02032007><FONT=20
size=3D2></FONT></SPAN>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C75D1B.F387A944--


--===============0086016035==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0086016035==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0086016035==--
