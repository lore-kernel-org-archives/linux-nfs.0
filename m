From: "Ijaaz A. Ullah" <ijaaz@raidzone.com>
Subject: NFS sync options
Date: Wed, 30 Apr 2003 15:46:42 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <01da01c30f51$39f17940$3702a8c0@jazzy>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_01DB_01C30F2F.B2DFD940"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from fep02-mail.bloor.is.net.cable.rogers.com ([66.185.86.72])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AxXd-0003Vs-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 12:46:57 -0700
Received: from jazzy ([24.102.132.240])
          by fep02-mail.bloor.is.net.cable.rogers.com
          (InterMail vM.5.01.05.12 201-253-122-126-112-20020820) with ESMTP
          id <20030430194649.KNWS4545.fep02-mail.bloor.is.net.cable.rogers.com@jazzy>
          for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 15:46:49 -0400
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

------=_NextPart_000_01DB_01C30F2F.B2DFD940
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've been playing with the sync option to make sure that my data is
securely written to my server.  I've noticed that there are multiple
ways of specifying sync and each way gives a different performance hit.

 

1. sync on the server

2. sync on the client

3. sync on both server and client

 

I've noticed that writes are faster using the first option and get
progressively slower as I get to option 3, which drop transfers down
from megabytes per second to bytes per second (over 100mbit).  

 

Can someone explain what the difference is between the three options and
how safe each option is?

 

Thanks,

Ijaaz Ullah


------=_NextPart_000_01DB_01C30F2F.B2DFD940
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<TITLE>Message</TITLE>

<META content=3D"MSHTML 6.00.2800.1126" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D678564119-30042003><FONT face=3DArial>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt">I&#8217;ve=20
been playing with the sync option to make sure that my data is securely =
written=20
to my server.<SPAN style=3D"mso-spacerun: yes">&nbsp; </SPAN>I&#8217;ve =
noticed that=20
there are multiple ways of specifying sync and each way gives a =
different=20
performance hit.<?xml:namespace prefix =3D o ns =3D=20
"urn:schemas-microsoft-com:office:office" /><o:p></o:p></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt"><o:p>&nbsp;</o:p></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt">1.=20
sync on the server<o:p></o:p></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt">2.=20
sync on the client<o:p></o:p></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt">3.=20
sync on both server and client<o:p></o:p></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt"><o:p>&nbsp;</o:p></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt">I&#8217;ve=20
noticed that writes are faster using the first option and get =
progressively=20
slower as I get to option 3, which drop transfers down from megabytes =
per second=20
to bytes per second (over 100mbit).<SPAN =
class=3D678564119-30042003>&nbsp;=20
</SPAN></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt"><o:p>&nbsp;</o:p></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt">Can=20
someone explain what the difference is between the three options and how =
safe=20
each option is?</SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt"><FONT=20
size=3D2></FONT></SPAN>&nbsp;</P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt"><o:p><SPAN=20
class=3D678564119-30042003>Thanks,</SPAN></o:p></SPAN></P>
<P class=3DMsoNormal style=3D"MARGIN: 0cm 0cm 0pt"><SPAN=20
style=3D"FONT-SIZE: 10pt; FONT-FAMILY: Verdana; mso-bidi-font-size: =
14.0pt"><o:p><SPAN=20
class=3D678564119-30042003>Ijaaz=20
Ullah</SPAN></o:p></SPAN></FONT></SPAN></P></DIV></BODY></HTML>

------=_NextPart_000_01DB_01C30F2F.B2DFD940--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
