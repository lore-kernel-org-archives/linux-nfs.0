From: "Matt Heaton" <admin@0catch.com>
Subject: NFS Performance issues...
Date: Fri, 15 Mar 2002 16:44:27 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <038201c1cc7b$5c8be400$2651a641@laptop>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_037F_01C1CC40.ABDAC8E0"
Received: from dns1.hawaiian.net ([12.36.97.1])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16m1NI-0001VS-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 15:44:40 -0800
Received: from laptop (ip12-36-108-34.dial.hawaiian.net [12.36.108.34])
	by dns1.hawaiian.net (8.11.6/8.11.6) with SMTP id g2FNjIl62454
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 13:45:19 -1000 (HST)
	(envelope-from admin@0catch.com)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_037F_01C1CC40.ABDAC8E0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I run a fairly large free/paid hosting service.  We have about 8 =
webservers (NFS Clients) that hook up to a single NFS server box.  We
are having SEVERE performance issues.  The clients are READ ONLY =
clients.  We have set the rsize to 8192 bytes, but otherwise
are using the standard setup.  The NFS server seems to be able to only =
serve about 11 Mbits of data before it dies?  Is this typical
performace?  We are mostly serving web pages so most files are small =
although some are bigger (3-5 megabytes).  Both the clients
are the server are redhat 7.2  (NFS 3)

I AM LOOKING FOR SOME COMMERCIAL SUPPORT or some guru I can pay to help =
with these issues.  PLEASE give me a call
at (801) 361-1177 if you would be able to help.  We will pay for the =
support we need.

Thanks,
Matt Heaton

------=_NextPart_000_037F_01C1CC40.ABDAC8E0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2713.1100" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>I run a fairly large free/paid hosting=20
service.&nbsp; We have about 8 webservers (NFS Clients) that hook up to =
a single=20
NFS server box.&nbsp; We</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>are having SEVERE performance =
issues.&nbsp; The=20
clients are READ ONLY clients.&nbsp; We have set the rsize to 8192 =
bytes, but=20
otherwise</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>are using the standard setup.&nbsp; The =
NFS server=20
seems to be able to only serve about 11 Mbits of data before it =
dies?&nbsp; Is=20
this typical</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>performace?&nbsp; We are mostly serving =
web pages=20
so most files are small although some are bigger (3-5 megabytes).&nbsp; =
Both the=20
clients</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>are the server are redhat 7.2&nbsp; =
(NFS=20
3)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I AM LOOKING FOR SOME COMMERCIAL =
SUPPORT or some=20
guru I can pay to help with these issues.&nbsp; PLEASE give me a=20
call</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>at (801) 361-1177 if you would be able =
to=20
help.&nbsp; We will pay for the support we need.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Thanks,<BR>Matt =
Heaton</FONT></DIV></BODY></HTML>

------=_NextPart_000_037F_01C1CC40.ABDAC8E0--


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
