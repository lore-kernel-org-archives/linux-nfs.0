From: darren.miller@philips.com
Subject: Re: e1000 intel driver bug (which impacts nfs)
Date: Wed, 5 Jun 2002 16:04:15 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF1365A61C.35388939-ON80256BCF.005285E0@diamond.philips.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 0052D48980256BCF_="
Cc: jason andrade <jason@dstc.edu.au>, nfs@lists.sourceforge.net,
	nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@lists.sourceforge.net
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

This is a multipart message in MIME format.
--=_alternative 0052D48980256BCF_=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I recently have been doing heavy investigation into using Linux for NAS=20
with an Intel E1000 and
Slackware 8.

I found this problem also, however it disappears if you use PowerTweak=20
Daemon and get the latest
driver for the Intel Card.

But PowerTweak cured alot of my issues...

http://powertweak.sourceforge.net/

Hope this helps

Darren

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
Darren Miller=20
Senior Systems Support Engineer
Microsoft Certified Professional
SCO Advanced Certified Engineer=20
Infomation Systems Department (Core Server Support)
Philips Semiconductors,Milbrook Industrial Estate,Southampton,SO15=20
0DJ,England




Thomas Lang=E5s <tlan@stud.ntnu.no>
Sent by: nfs-admin@lists.sourceforge.net
2002-06-02 23:28
Please respond to nfs

=20
        To:     jason andrade <jason@dstc.edu.au>
        cc:     nfs@lists.sourceforge.net
(bcc: Darren Miller/SOU/SC/PHILIPS)
        Subject:        Re: [NFS] e1000 intel driver bug (which impacts nfs)
        Classification:=20



jason andrade:
> I hope this helps anyone else trying to debug mysterious "nfs hangs"=20
under
> 2.4.X.  It doesn't seem to be tickled unless you are doing quite large
> amounts of nfs traffic (we're pushing 1-1.5T a day on this interface)
> and it's quite random (i've had a lockup from 4 hours to 10 days after
> a reboot)

We've also got problems with nfs-hangs when transfering large files (ie.
files around 300-400M, sometime we have to go a bit higher tho, like
2GB-3GB files, but it's always possible to trigger this. However, we
don't need to be jumping through hoops to "fix it", after a min or so,
it's ok again. It seems to me like there's a VM problem or something.

We've got 2GB mem on the machines which are suffering from theese=20
problems.

--=20
Thomas

=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs



--=_alternative 0052D48980256BCF_=
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


<br><font size=3D2 face=3D"sans-serif">I recently have been doing heavy inv=
estigation into using Linux for NAS with an Intel E1000 and</font>
<br><font size=3D2 face=3D"sans-serif">Slackware 8.</font>
<br>
<br><font size=3D2 face=3D"sans-serif">I found this problem also, however i=
t disappears if you use PowerTweak Daemon and get the latest</font>
<br><font size=3D2 face=3D"sans-serif">driver for the Intel Card.</font>
<br>
<br><font size=3D2 face=3D"sans-serif">But PowerTweak cured alot of my issu=
es...</font>
<br>
<br><font size=3D2 face=3D"Courier New">http://powertweak.sourceforge.net/<=
/font>
<br>
<br><font size=3D2 face=3D"sans-serif">Hope this helps</font>
<br>
<br><font size=3D2 face=3D"sans-serif">Darren<br>
<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D<br>
Darren Miller &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp;<br>
Senior Systems Support Engineer<br>
Microsoft Certified Professional<br>
SCO Advanced Certified Engineer &nbsp; &nbsp; &nbsp; &nbsp;<br>
Infomation Systems Department (Core Server Support)<br>
Philips Semiconductors,Milbrook Industrial Estate,Southampton,SO15 0DJ,Engl=
and</font>
<br>
<br>
<br>
<table width=3D100%>
<tr valign=3Dtop>
<td>
<td><font size=3D1 face=3D"sans-serif"><b>Thomas Lang=E5s &lt;tlan@stud.ntn=
u.no&gt;</b></font>
<br><font size=3D1 face=3D"sans-serif">Sent by: nfs-admin@lists.sourceforge=
.net</font>
<p><font size=3D1 face=3D"sans-serif">2002-06-02 23:28</font>
<br><font size=3D1 face=3D"sans-serif">Please respond to nfs</font>
<br>
<td><font size=3D1 face=3D"Arial">&nbsp; &nbsp; &nbsp; &nbsp; </font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; To: &nbs=
p; &nbsp; &nbsp; &nbsp;jason andrade &lt;jason@dstc.edu.au&gt;</font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; cc: &nbs=
p; &nbsp; &nbsp; &nbsp;nfs@lists.sourceforge.net<br>
(bcc: Darren Miller/SOU/SC/PHILIPS)</font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Subject:=
 &nbsp; &nbsp; &nbsp; &nbsp;Re: [NFS] e1000 intel driver bug (which impacts=
 nfs)</font>
<p><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Classific=
ation: &nbsp; &nbsp; &nbsp; &nbsp;</font>
<br></table>
<br>
<br>
<br><font size=3D2 face=3D"Courier New">jason andrade:<br>
&gt; I hope this helps anyone else trying to debug mysterious &quot;nfs han=
gs&quot; under<br>
&gt; 2.4.X. &nbsp;It doesn't seem to be tickled unless you are doing quite =
large<br>
&gt; amounts of nfs traffic (we're pushing 1-1.5T a day on this interface)<=
br>
&gt; and it's quite random (i've had a lockup from 4 hours to 10 days after=
<br>
&gt; a reboot)<br>
<br>
We've also got problems with nfs-hangs when transfering large files (ie.<br>
files around 300-400M, sometime we have to go a bit higher tho, like<br>
2GB-3GB files, but it's always possible to trigger this. However, we<br>
don't need to be jumping through hoops to &quot;fix it&quot;, after a min o=
r so,<br>
it's ok again. It seems to me like there's a VM problem or something.<br>
<br>
We've got 2GB mem on the machines which are suffering from theese <br>
problems.<br>
<br>
-- <br>
Thomas<br>
<br>
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F<br>
<br>
Don't miss the 2002 Sprint PCS Application Developer's Conference<br>
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm<br>
<br>
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F<br>
NFS maillist &nbsp;- &nbsp;NFS@lists.sourceforge.net<br>
https://lists.sourceforge.net/lists/listinfo/nfs<br>
</font>
<br>
<br>
--=_alternative 0052D48980256BCF_=--

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
