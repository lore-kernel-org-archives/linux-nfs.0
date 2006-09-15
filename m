From: "max williams" <max.williams@alliedtelesis.co.nz>
Subject: Re: Strange NFS behaviour, working directory disappears
Date: Fri, 15 Sep 2006 17:56:48 +1200
Message-ID: <450AE960.4A67.0005.0@alliedtelesis.co.nz>
References: <450AB68E.4A67.0005.0@alliedtelesis.co.nz>
	<1158298749.5533.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0994888602=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GO6hF-0003ps-Sx
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 22:57:05 -0700
Received: from gate.alliedtelesyn.co.nz ([202.49.72.33] ident=proxyuser)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GO6hF-00087t-2j
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 22:57:06 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <1158298749.5533.3.camel@lade.trondhjem.org>
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

--===============0994888602==
Content-Type: multipart/alternative; boundary="=__PartD7F395B0.0__="

--=__PartD7F395B0.0__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

How can I forget that!?
Server (FC4) is running 2.6.11-1.1369.
Clients are running 2.6.12.
Do you think I should upgrade the server kernel version?
Cheers
Max

>>> Trond Myklebust <trond.myklebust@fys.uio.no> 15/09/2006 5:39 p.m. >>>=

On Fri, 2006-09-15 at 14:19 +1200, max williams wrote:
> Hi,
> I have a strange issue on a number of PCs that mount /home via NFS.
> This started after upgrading the NFS server from Redhat 9 to Fedora
> Core 4. Very occasionally the current working directory or a
> particular file "disappears". When I say disappears I mean the client
> returns an odd error when running "ls -l" but on the NFS server the
> file/directory is fine.
> Example:
> =20
> [root@tb39 maxw]# ls -l
> ls: log.txt: No such file or directory
> total 346704

You don't mention which kernel you are using. The latest FC4 kernel is
2.6.17 based: is that still giving you trouble?

Cheers,
=20 Trond


-------------------------------------------------------------------------=

Using Tomcat but need to do more? Need to support web services, security?=

Get stuff done quickly with pre-integrated technology to make your job ea=
sier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronim=
o
http://sel.as ( http://sel.as/ )-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709=
&bid=3D263057&dat=3D121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net=20
https://lists.sourceforge.net/lists/listinfo/nfs

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

--=__PartD7F395B0.0__=
Content-Type: text/html; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Description: HTML

<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; charset=3Diso-8859-=
15">
<META content=3D"MSHTML 6.00.2900.2963" name=3DGENERATOR></HEAD>
<BODY style=3D"MARGIN: 4px 4px 1px; FONT: 10pt Tahoma">
<DIV>How can I forget that!?</DIV>
<DIV>Server (FC4) is running 2.6.11-1.1369.</DIV>
<DIV>Clients are running 2.6.12.</DIV>
<DIV>Do you think I should upgrade the server kernel version?</DIV>
<DIV>Cheers</DIV>
<DIV>Max<BR></DIV>
<DIV><BR>&gt;&gt;&gt; Trond Myklebust &lt;trond.myklebust@fys.uio.no&gt; =
15/09/2006 5:39 p.m. &gt;&gt;&gt;<BR>On Fri, 2006-09-15 at 14:19 +1200, m=
ax williams wrote:<BR>&gt; Hi,<BR>&gt; I have a strange issue on a number=
=20of PCs that mount /home via NFS.<BR>&gt; This started after upgrading =
the NFS server from Redhat 9 to Fedora<BR>&gt; Core 4. Very occasionally =
the current working directory or a<BR>&gt; particular file "disappears". =
When I say disappears I mean the client<BR>&gt; returns an odd error when=
=20running "ls -l" but on the NFS server the<BR>&gt; file/directory is fi=
ne.<BR>&gt; Example:<BR>&gt;&nbsp; <BR>&gt; [root@tb39 maxw]# ls -l<BR>&g=
t; ls: log.txt: No such file or directory<BR>&gt; total 346704<BR><BR>You=
=20don't mention which kernel you are using. The latest FC4 kernel is<BR>=
2.6.17 based: is that still giving you trouble?<BR><BR>Cheers,<BR>&nbsp; =
Trond<BR><BR><BR>--------------------------------------------------------=
-----------------<BR>Using Tomcat but need to do more? Need to support we=
b services, security?<BR>Get stuff done quickly with pre-integrated techn=
ology to make your job easier<BR>Download IBM WebSphere Application Serve=
r v.1.0.1 based on Apache Geronimo<BR><A href=3D"http://sel.as/">http://s=
el.as</A>-us.falkag.net/sel?cmd=3Dlnk&amp;kid=3D120709&amp;bid=3D263057&a=
mp;dat=3D121642<BR>_______________________________________________<BR>NFS=
=20maillist&nbsp; -&nbsp; NFS@lists.sourceforge.net<BR><A href=3D"https:/=
/lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/=
lists/listinfo/nfs</A><BR></DIV>
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

--=__PartD7F395B0.0__=--


--===============0994888602==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============0994888602==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0994888602==--
