From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: tcp over nfs for redhat 9 kernel 2.4.20-31.9
Date: Mon, 7 Jun 2004 13:12:53 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E21D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C44CCB.D0716ACF"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXQUT-0000LD-Ad
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 13:13:05 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXQUS-0001eJ-QW
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 13:13:04 -0700
To: "Enils Bashi" <EBashi@chesapeakebay.net>
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

------_=_NextPart_001_01C44CCB.D0716ACF
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

make sure you have enabled CONFIG_EXPERIMENTAL.  it's the very first
menu item in "make xconfig".
=20

-----Original Message-----
From: Enils Bashi [mailto:EBashi@chesapeakebay.net]=20
Sent: Monday, June 07, 2004 4:04 PM
To: nfs@lists.sourceforge.net
Subject: [NFS] tcp over nfs for redhat 9 kernel 2.4.20-31.9



Hi,

=20

I had posted something about this earlier one of the responses I
received was that my nfs server does not support tcp over nfs since the
output of rpcinfo -p looked like the following:

=20

[root@client linux-2.4]# rpcinfo -p server

   program vers proto   port

    100000    2   tcp    111  portmapper

    100000    2   udp    111  portmapper

    100024    1   udp  32768  status

    100024    1   tcp  32768  status

    391002    2   tcp  32769  sgi_fam

    100011    1   udp    705  rquotad

    100011    2   udp    705  rquotad

    100011    1   tcp    708  rquotad

    100011    2   tcp    708  rquotad

    100003    2   udp   2049  nfs

    100003    3   udp   2049  nfs

    100021    1   udp  33050  nlockmgr

    100021    3   udp  33050  nlockmgr

    100021    4   udp  33050  nlockmgr

    100005    1   udp  33051  mountd

    100005    1   tcp  40931  mountd

    100005    2   udp  33051  mountd

    100005    2   tcp  40931  mountd

    100005    3   udp  33051  mountd

    100005    3   tcp  40931  mountd

=20

Just for kicks I installed Fedora Core 2 on one of my nfs client
machines. I mounted all drives with proto=3Dtcp and nfsvers=3D3 and
everything worked great. I ran some tests and I got very good results.
Nfs on Fedora was at least 100% faster than on Redhat. All this done
using the same nfs server located on a Redhat 9 Server. My other Redhat
9 clients all with Kernel 2.4.20-31.9 fail to mount with proto=3Dtcp. =
From
the reading I have done most  kernels above 2.4.19 are supposed to have
nfs over tcp support. I tried recompiling the kernel on one of the
Redhat nfs clients using xconfig; but under the Network File System
options tcp support for nfs was grayed out (disabled). I am not sure
whether this means that is already installed. I have noticed that other
people have had similar problems but I don't see a straight answer on
the forum.

=20

Any and all feedback would be greatly appreciated.

=20

Enils


------_=_NextPart_001_01C44CCB.D0716ACF
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML xmlns=3D"http://www.w3.org/TR/REC-html40" xmlns:o =3D=20
"urn:schemas-microsoft-com:office:office" xmlns:w =3D=20
"urn:schemas-microsoft-com:office:word"><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<TITLE>Message</TITLE>

<META content=3D"MSHTML 6.00.2800.1400" name=3DGENERATOR>
<STYLE>@page Section1 {size: 8.5in 11.0in; margin: 1.0in 1.25in 1.0in =
1.25in; }
P.MsoNormal {
	FONT-SIZE: 12pt; MARGIN: 0in 0in 0pt; FONT-FAMILY: "Times New Roman"
}
LI.MsoNormal {
	FONT-SIZE: 12pt; MARGIN: 0in 0in 0pt; FONT-FAMILY: "Times New Roman"
}
DIV.MsoNormal {
	FONT-SIZE: 12pt; MARGIN: 0in 0in 0pt; FONT-FAMILY: "Times New Roman"
}
A:link {
	COLOR: blue; TEXT-DECORATION: underline
}
SPAN.MsoHyperlink {
	COLOR: blue; TEXT-DECORATION: underline
}
A:visited {
	COLOR: purple; TEXT-DECORATION: underline
}
SPAN.MsoHyperlinkFollowed {
	COLOR: purple; TEXT-DECORATION: underline
}
SPAN.EmailStyle17 {
	COLOR: windowtext; FONT-FAMILY: Arial; mso-style-type: personal-compose
}
DIV.Section1 {
	page: Section1
}
</STYLE>
</HEAD>
<BODY lang=3DEN-US vLink=3Dpurple link=3Dblue>
<DIV><SPAN class=3D382111220-07062004><FONT face=3DArial color=3D#0000ff =
size=3D2>make=20
sure you have enabled CONFIG_EXPERIMENTAL.&nbsp; it's the very first =
menu item=20
in "make xconfig".</FONT></SPAN></DIV>
<DIV><SPAN class=3D382111220-07062004></SPAN>&nbsp;</DIV>
<BLOCKQUOTE dir=3Dltr=20
style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px =
solid; MARGIN-RIGHT: 0px">
  <DIV></DIV>
  <DIV class=3DOutlookMessageHeader lang=3Den-us dir=3Dltr =
align=3Dleft><FONT=20
  face=3DTahoma size=3D2>-----Original Message-----<BR><B>From:</B> =
Enils Bashi=20
  [mailto:EBashi@chesapeakebay.net] <BR><B>Sent:</B> Monday, June 07, =
2004 4:04=20
  PM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] =
tcp over=20
  nfs for redhat 9 kernel 2.4.20-31.9<BR><BR></FONT></DIV>
  <DIV class=3DSection1>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial">Hi,<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial"><o:p>&nbsp;</o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">I had posted something =
about this=20
  earlier one of the responses I received was that my nfs server does =
not=20
  support tcp over nfs since the output of rpcinfo &#8211;p looked like =
the=20
  following:<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial"><o:p>&nbsp;</o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">[root@client linux-2.4]# =
rpcinfo=20
  -p server<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp; program =
vers=20
  proto&nbsp;&nbsp; port<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 111&nbsp; =

  portmapper<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 111&nbsp; =

  portmapper<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32768&nbsp;=20
  status<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp; 32768&nbsp;=20
  status<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  391002&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp; 32769&nbsp;=20
  sgi_fam<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 705&nbsp; =

  rquotad<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 705&nbsp; =

  rquotad<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 708&nbsp; =

  rquotad<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 708&nbsp; =

  rquotad<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp;=20
  nfs<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp;=20
  nfs<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 33050&nbsp;=20
  nlockmgr<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp; 33050&nbsp;=20
  nlockmgr<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; udp&nbsp; 33050&nbsp;=20
  nlockmgr<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 33051&nbsp;=20
  mountd<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp; 40931&nbsp;=20
  mountd<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp; 33051&nbsp;=20
  mountd<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp; 40931&nbsp;=20
  mountd<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp; 33051&nbsp;=20
  mountd<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">&nbsp;&nbsp;&nbsp;=20
  100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp; 40931&nbsp;=20
  mountd<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial"><o:p>&nbsp;</o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">Just for kicks I =
installed Fedora=20
  Core 2 on one of my nfs client machines. I mounted all drives with =
proto=3Dtcp=20
  and nfsvers=3D3 and everything worked great. I ran some tests and I =
got very=20
  good results. Nfs on Fedora was at least 100% faster than on Redhat. =
All this=20
  done using the same nfs server located on a Redhat 9 Server. My other =
Redhat 9=20
  clients all with Kernel 2.4.20-31.9 fail to mount with proto=3Dtcp. =
>From the=20
  reading I have done most &nbsp;kernels above 2.4.19 are supposed to =
have nfs=20
  over tcp support. I tried recompiling the kernel on one of the Redhat =
nfs=20
  clients using xconfig; but under the Network File System options tcp =
support=20
  for nfs was grayed out (disabled). I am not sure whether this means =
that is=20
  already installed. I have noticed that other people have had similar =
problems=20
  but I don&#8217;t see a straight answer on the =
forum.<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial"><o:p>&nbsp;</o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Arial">Any and all feedback =
would be=20
  greatly appreciated.<o:p></o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial"><o:p>&nbsp;</o:p></SPAN></FONT></P>
  <P class=3DMsoNormal><FONT face=3DArial size=3D2><SPAN=20
  style=3D"FONT-SIZE: 10pt; FONT-FAMILY: =
Arial">Enils<o:p></o:p></SPAN></FONT></P></DIV></BLOCKQUOTE></BODY></HTML=
>

------_=_NextPart_001_01C44CCB.D0716ACF--


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
