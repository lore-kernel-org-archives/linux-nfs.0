From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: quick connection then wait but for what?
Date: Mon, 29 Mar 2004 06:09:07 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DDFA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C41597.663B779F"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7xRz-00079h-5G
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 06:09:15 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B7xRy-0005oG-Rn
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 06:09:14 -0800
To: "beooi alex" <beooia@yahoo.fr>
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

------_=_NextPart_001_01C41597.663B779F
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

hi alex-
=20
can you share with us a network trace captured during a data transfer
that shows this performance anomaly?
=20

-----Original Message-----
From: beooi alex [mailto:beooia@yahoo.fr]=20
Sent: Sunday, March 28, 2004 5:00 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] quick connection then wait but for what?


hello,

first of all excuse me for my poor english :)

this is our lvs cluster:

                             director
                                  |
                              switch
                                  |
            ----------------------------------------------
           |                                              |
web/mailserver                          webmailserver
           |                                              |
            ----------------------------------------------
                                  |
                              switch
                                  |
            ----------------------------------------------
           |                                              |
     fileserver                              databaseserver

we have a strange problem:
we don't use nor identd nor hostnamelookup but we have those symptoms...

when you request a page, the result is the same with a 1ko page or a 10 =
mo one,
you see connection, opening, then you wait between 1 and 3 seconds,
then everything appear very fast

we didn't have this problem before we "clustered" our installation
and dedicated a server for the files.
we add a smart array 641 controller with 4 discs (raid10) for the =
fileserver.

we tried quite all combinaisons of rsize, wsize, tcp, udp, version 2; =
version 3.

we don't understand how this cluster can respond slower than before.
(before we just used one server)

can it be the default stripe size of the file server (128 ko for =
raid10)?
...?

thanks a lot in advance for your responses/help. :)

alex.



  _____ =20

Yahoo! Mail : votre e-mail personnel et gratuit qui vous suit partout !=20
Cr=E9ez  =
<http://fr.rd.yahoo.com/mail/taglines/*http://fr.rd.yahoo.com/mail/mail_t=
aglines/default/*http://fr.benefits.yahoo.com/> votre Yahoo! Mail=20

Dialoguez en direct avec vos amis gr=E2ce =E0 Yahoo!  =
<http://fr.rd.yahoo.com/mail/taglines/*http://fr.rd.yahoo.com/messenger/m=
ail_taglines/default/*http://fr.messenger.yahoo.com/> Messenger !


------_=_NextPart_001_01C41597.663B779F
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<TITLE>Message</TITLE>

<META content=3D"MSHTML 6.00.2800.1276" name=3DGENERATOR></HEAD>
<BODY>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN =
class=3D778070714-29032004>hi=20
alex-</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN=20
class=3D778070714-29032004></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN =
class=3D778070714-29032004>can=20
you share with us a network trace captured during a data =
</SPAN></FONT><FONT=20
face=3DArial color=3D#0000ff size=3D2><SPAN=20
class=3D778070714-29032004>transfer</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN =
class=3D778070714-29032004>that=20
shows this performance anomaly?</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#0000ff size=3D2><SPAN=20
class=3D778070714-29032004></SPAN></FONT>&nbsp;</DIV>
<BLOCKQUOTE=20
style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px =
solid; MARGIN-RIGHT: 0px">
  <DIV></DIV>
  <DIV class=3DOutlookMessageHeader lang=3Den-us dir=3Dltr =
align=3Dleft><FONT=20
  face=3DTahoma size=3D2>-----Original Message-----<BR><B>From:</B> =
beooi alex=20
  [mailto:beooia@yahoo.fr] <BR><B>Sent:</B> Sunday, March 28, 2004 5:00=20
  AM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] =
quick=20
  connection then wait but for what?<BR><BR></FONT></DIV>
  <DIV>hello,<BR><BR>first of all excuse me for my poor english =
:)<BR><BR>this=20
  is our lvs=20
  =
cluster:<BR><BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
director<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
|<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
switch<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
|<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
----------------------------------------------<BR>&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
|<BR>web/mailserver&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;=20
  =
webmailserver<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;=20
  =
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
|<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
----------------------------------------------<BR>&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
|<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
switch<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
|<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
----------------------------------------------<BR>&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  |<BR>&nbsp;&nbsp;&nbsp;&nbsp;=20
  =
fileserver&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  databaseserver<BR><BR>we have a strange problem:<BR>we don't use nor =
identd=20
  nor hostnamelookup but we have those symptoms...<BR><BR>when you =
request a=20
  page, the result is the same with a 1ko page or a 10 mo one,<BR>you =
see=20
  connection, opening, then you wait between 1 and 3 seconds,<BR>then =
everything=20
  appear very fast<BR><BR>we didn't have this problem before we =
"clustered" our=20
  installation</DIV>
  <DIV>and dedicated a server for the files.<BR>we add a smart array 641 =

  controller with 4 discs (raid10) for the fileserver.<BR></DIV>
  <DIV>we tried quite all combinaisons of rsize, wsize, tcp, udp, =
version 2;=20
  version 3.</DIV>
  <DIV><BR>we don't understand how this cluster can respond slower than=20
  before.</DIV>
  <DIV>(before we just used one server)<BR><BR>can it be the default =
stripe size=20
  of the file server (128 ko for raid10)?<BR>...?<BR><BR>thanks a lot in =
advance=20
  for your responses/help. :)<BR><BR>alex.</DIV>
  <P>
  <HR SIZE=3D1>
  Yahoo! Mail : votre e-mail personnel et gratuit qui vous suit partout =
! <BR><A=20
  =
href=3D"http://fr.rd.yahoo.com/mail/taglines/*http://fr.rd.yahoo.com/mail=
/mail_taglines/default/*http://fr.benefits.yahoo.com/">Cr=E9ez=20
  votre Yahoo! Mail</A> <BR><BR>Dialoguez en direct avec vos amis =
gr=E2ce =E0 <A=20
  =
href=3D"http://fr.rd.yahoo.com/mail/taglines/*http://fr.rd.yahoo.com/mess=
enger/mail_taglines/default/*http://fr.messenger.yahoo.com/">Yahoo!=20
  Messenger !</A></BLOCKQUOTE></BODY></HTML>

------_=_NextPart_001_01C41597.663B779F--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
