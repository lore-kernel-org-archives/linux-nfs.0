From: Tatyaso Babar <tatyaso_slash@yahoo.com>
Subject: NFS & name resolution
Date: Mon, 24 Sep 2007 22:36:50 -0700 (PDT)
Message-ID: <53700.99778.qm@web58115.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0276957073=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ia36N-0000YG-0q
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 22:37:04 -0700
Received: from web58115.mail.re3.yahoo.com ([68.142.236.138])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Ia36Q-0002I7-3C
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 22:36:59 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0276957073==
Content-Type: multipart/alternative; boundary="0-1353290781-1190698610=:99778"
Content-Transfer-Encoding: 7bit

--0-1353290781-1190698610=:99778
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

  Hi All,
    I had a problem mounting NFS mount on client. The error was :
  mount: mount to NFS server failed: timed out (retrying)
  mount: mount to NFS server failed: timed out (retrying)
  mount: mount to NFS server failed: timed out (retrying)
  mount: mount to NFS server failed: timed out (retrying)
  mount: mount to NFS server failed: timed out (giving up)
    I tried many possibilities as per troubleshooting information at http=
://nfs.sourceforge.net/nfs-howto/ar01s07.html. Googled with no luck....
  Finally the problem found was wrong nameserver in /etc/resolv.conf. I h=
ave not found any location mentioning to check the name lookup to trouble=
shoot the NFS issue.
  I think it should be documented at http://nfs.sourceforge.net/nfs-howto=
/ar01s07.html.
     I wanted to know why does NFS need the name lookup & how does NFS us=
e it?
      Regards,
Tatyaso
 =20
      =20
---------------------------------
Don't let your dream ride pass you by.    Make it a reality with Yahoo! A=
utos.=20
--0-1353290781-1190698610=:99778
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

  <div class=3D"MsoNormal"><span style=3D"font-size: 10pt; font-family: A=
rial;">Hi All,<o:p></o:p></span></div>    <div class=3D"MsoNormal"><span =
style=3D"font-size: 10pt; font-family: Arial;"><o:p></o:p>I had a problem=
 mounting NFS mount on client. The error was :<o:p></o:p></span></div>  <=
div style=3D"font-style: italic;" class=3D"MsoNormal">mount: mount to NFS=
 server failed: timed out (retrying)<o:p></o:p></div>  <div style=3D"font=
-style: italic;" class=3D"MsoNormal">mount: mount to NFS server failed: t=
imed out (retrying)<o:p></o:p></div>  <div style=3D"font-style: italic;" =
class=3D"MsoNormal">mount: mount to NFS server failed: timed out (retryin=
g)<o:p></o:p></div>  <div style=3D"font-style: italic;" class=3D"MsoNorma=
l">mount: mount to NFS server failed: timed out (retrying)<o:p></o:p></di=
v>  <div style=3D"font-style: italic;" class=3D"MsoNormal">mount: mount t=
o NFS server failed: timed out (giving up)<o:p></o:p></div>    <div class=
=3D"MsoNormal"><span style=3D"font-size: 10pt; font-family:
 Arial;"><o:p></o:p>I tried many possibilities as per troubleshooting inf=
ormation at <a href=3D"http://nfs.sourceforge.net/nfs-howto/ar01s07.html"=
>http://nfs.sourceforge.net/nfs-howto/ar01s07.html</a>. Googled with no l=
uck....<o:p></o:p></span></div>  <div class=3D"MsoNormal"><span style=3D"=
font-size: 10pt; font-family: Arial;">Finally the problem found was wrong=
 nameserver in /etc/resolv.conf. I have not found any location mentioning=
 to check the name lookup to troubleshoot the NFS issue.<o:p></o:p></span=
></div>  <div class=3D"MsoNormal"><span style=3D"font-size: 10pt; font-fa=
mily: Arial;">I think it should be documented at <a href=3D"http://nfs.so=
urceforge.net/nfs-howto/ar01s07.html">http://nfs.sourceforge.net/nfs-howt=
o/ar01s07.html</a>.<o:p></o:p></span></div>    <div class=3D"MsoNormal"><=
span style=3D"font-size: 10pt; font-family: Arial;"><o:p>&nbsp;</o:p>I wa=
nted to know why does NFS need the name lookup &amp; how does NFS use it?=
<o:p></o:p></span></div>      <div
 class=3D"MsoNormal"><span style=3D"font-size: 10pt; font-family: Arial;"=
><o:p></o:p></span><a name=3D"_MailAutoSig"><span style=3D"font-size: 10p=
t; font-family: Arial;">Regards,</span></a><br><span style=3D""><span sty=
le=3D"font-size: 10pt; font-family: Arial;">Tatyaso</span></span><o:p></o=
:p></div>  <p>&#32;
      <hr size=3D1>Don't let your dream ride pass you by.  <a href=3D"htt=
p://us.rd.yahoo.com/evt=3D51200/*http://autos.yahoo.com/index.html;_ylc=3D=
X3oDMTFibjNlcHF0BF9TAzk3MTA3MDc2BHNlYwNtYWlsdGFncwRzbGsDYXV0b3MtZHJlYW1jY=
XI-">  Make it a reality</a> with Yahoo! Autos.



=20


--0-1353290781-1190698610=:99778--


--===============0276957073==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0276957073==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0276957073==--
