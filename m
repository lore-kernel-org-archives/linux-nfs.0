From: Emanuel.Quass@temic.com
Subject: Antwort: what is dump ?
Date: Fri, 23 May 2003 13:52:15 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF2BB3F38D.F3E3370F-ONC1256D2F.003B6C4D-C2256D2F.003BB7E8@temic.de>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 003BB7DDC2256D2F_="
Cc: nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: "jacky" <jacky.xia@raidtec.ie>
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

This is a multipart message in MIME format.
--=_alternative 003BB7DDC2256D2F_=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi Jacky,

this is a normal behavior. This simply means someone is doing a "showmount =

-e <servername>"
I asume you have some solaris boxes as nfs clients (or linux with autofs).

I don't know where to stop this messages, but you can safely ignore this=20
messages (as far as I know)

Best wishes=20

        Emanuel Quass

--

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

 - Continental Automotive Systems -
=20
Conti TEMIC microelectronic GmbH
Dipl.Inf.(FH) Emanuel Quass
FIE1.1/IN, Abteilung M-CAD/CAE
Ringlerstra=DFe 17
D-85057 Ingolstadt
E-Mail :  emanuel.quass@temic.com=20

Besuchen Sie unsere Web-Seite:
http://www.temic.com
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D





"jacky" <jacky.xia@raidtec.ie>
Gesendet von: nfs-admin@lists.sourceforge.net
23.05.2003 13:28

=20
        An:     <nfs@lists.sourceforge.net>
        Kopie:=20
        Thema:  [NFS] what is dump ?


Since I've installed and run and NFS, I've my log=20
flooded with this message=20
(every 10 seconds) :=20
---=20
Feb 24 12:03:50 [rpc.mountd] dump request from 1.2.3.4=20
Feb 24 12:03:53 [rpc.mountd] dump request from 1.2.3.4=20
Feb 24 12:03:56 [rpc.mountd] dump request from 1.2.3.4=20
Feb 24 12:03:59 [rpc.mountd] dump request from 1.2.3.4=20
Feb 24 12:04:02 [rpc.mountd] dump request from 1.2.3.4=20
---=20
(where 1.2.3.4 is the fixed ip of the NFS server).=20

Therefore I have 2 questions:=20
- What's this dump request ? (can I safely turn it off=20
(and how) ?)=20
- If it's normal feature where can I specify that I=20
don't want such logging=20
(especially every 10 seconds) ?=20




-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




--=_alternative 003BB7DDC2256D2F_=
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


<br><font size=3D2 face=3D"sans-serif">Hi Jacky,</font>
<br>
<br><font size=3D2 face=3D"sans-serif">this is a normal behavior. This simp=
ly means someone is doing a &quot;showmount -e &lt;servername&gt;&quot;</fo=
nt>
<br><font size=3D2 face=3D"sans-serif">I asume you have some solaris boxes =
as nfs clients (or linux with autofs).</font>
<br>
<br><font size=3D2 face=3D"sans-serif">I don't know where to stop this mess=
ages, but you can safely ignore this messages (as far as I know)</font>
<br>
<br><font size=3D2 face=3D"sans-serif">Best wishes </font>
<br>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Emanuel =
Quass</font>
<br><font size=3D2 face=3D"sans-serif"><br>
--<br>
<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
<br>
 - Continental Automotive Systems -<br>
 <br>
Conti TEMIC microelectronic GmbH<br>
Dipl.Inf.(FH) Emanuel Quass<br>
FIE1.1/IN, Abteilung M-CAD/CAE<br>
Ringlerstra=DFe 17<br>
D-85057 Ingolstadt<br>
E-Mail : &nbsp;emanuel.quass@temic.com <br>
<br>
Besuchen Sie unsere Web-Seite:<br>
http://www.temic.com<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
</font>
<br>
<br>
<br>
<table width=3D100%>
<tr valign=3Dtop>
<td>
<td><font size=3D1 face=3D"sans-serif"><b>&quot;jacky&quot; &lt;jacky.xia@r=
aidtec.ie&gt;</b></font>
<br><font size=3D1 face=3D"sans-serif">Gesendet von: nfs-admin@lists.source=
forge.net</font>
<p><font size=3D1 face=3D"sans-serif">23.05.2003 13:28</font>
<br>
<td><font size=3D1 face=3D"Arial">&nbsp; &nbsp; &nbsp; &nbsp; </font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; An: &nbs=
p; &nbsp; &nbsp; &nbsp;&lt;nfs@lists.sourceforge.net&gt;</font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Kopie: &=
nbsp; &nbsp; &nbsp; &nbsp;</font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Thema: &=
nbsp; &nbsp; &nbsp; &nbsp;[NFS] what is dump ?</font></table>
<br>
<br>
<br><font size=3D2 face=3D"Courier New">Since I've installed and run and NF=
S, I've my log <br>
flooded with this message <br>
(every 10 seconds) : <br>
--- <br>
Feb 24 12:03:50 [rpc.mountd] dump request from 1.2.3.4 <br>
Feb 24 12:03:53 [rpc.mountd] dump request from 1.2.3.4 <br>
Feb 24 12:03:56 [rpc.mountd] dump request from 1.2.3.4 <br>
Feb 24 12:03:59 [rpc.mountd] dump request from 1.2.3.4 <br>
Feb 24 12:04:02 [rpc.mountd] dump request from 1.2.3.4 <br>
--- <br>
(where 1.2.3.4 is the fixed ip of the NFS server). <br>
<br>
Therefore I have 2 questions: <br>
- What's this dump request ? (can I safely turn it off <br>
(and how) ?) <br>
- If it's normal feature where can I specify that I <br>
don't want such logging <br>
(especially every 10 seconds) ? <br>
<br>
<br>
<br>
<br>
-------------------------------------------------------<br>
This SF.net email is sponsored by: ObjectStore.<br>
If flattening out C++ or Java code to make your application fit in a<br>
relational database is painful, don't do it! Check out ObjectStore.<br>
Now part of Progress Software. http://www.objectstore.net/sourceforge<br>
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F<br>
NFS maillist &nbsp;- &nbsp;NFS@lists.sourceforge.net<br>
https://lists.sourceforge.net/lists/listinfo/nfs<br>
<br>
</font>
<br>
<br>
--=_alternative 003BB7DDC2256D2F_=--


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
