From: <eh@dataconnection.com>
Subject: RE: Problem with NLM on Fedora
Date: Thu, 14 Apr 2005 11:51:29 +0100
Message-ID: <9E621559095AA746B22B21CD4FAF99A50A4EF1@EDINMAIL1.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C540DF.E99BC627"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DM1wf-0008UL-TY
	for nfs@lists.sourceforge.net; Thu, 14 Apr 2005 03:51:37 -0700
Received: from smtp2.dataconnection.com ([192.91.191.8])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DM1wc-0001hj-Vc
	for nfs@lists.sourceforge.net; Thu, 14 Apr 2005 03:51:37 -0700
To: "Steve Dickson" <SteveD@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
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

------_=_NextPart_001_01C540DF.E99BC627
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Moving my data onto a filer which doesn't expose TCP (and therefore =
forces use of UDP) seems to work fine.
=20
So I'm now convinced this isn't a client-side problem.  However I need =
to work with this particular server, so to work around the server-side =
problem, I'd still like a way to force NLM connections to use UDP rather =
than TCP. =20
=20
Anyone know how to do this?
=20
Edward.

-----Original Message-----
From: Edward Hibbert (eh@dataconnection.com)=20
Sent: 14 April 2005 11:06
To: 'Steve Dickson'
Cc: nfs@lists.sourceforge.net
Subject: RE: [NFS] Problem with NLM on Fedora



Digging a bit deeper, I was wrong to say there are no NLM packets =
flowing.  Sorry.

What I think is happening is that the NLM requests are being lost, and =
the delays I'm seeing are due to retransmission.  One difference that I =
notice from tcpdump trace is that Fedora is using TCP connections for =
the NLM traffic, whereas RedHat 8 (running successfully against the same =
filer) is using UDP.

Although I'd expect TCP to be more reliable, it's possible that the =
filer isn't very good at TCP traffic.  TCP support has recently been =
added to this SNAP model - it only used to use UDP.  So maybe it's =
flakey.

Is it possible to force the NLM traffic over UDP from the client side?

Edward.


-----Original Message-----
From: Steve Dickson [  <mailto:SteveD@redhat.com> =
mailto:SteveD@redhat.com]
Sent: 14 April 2005 00:44
To: Edward Hibbert (eh@dataconnection.com)
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Problem with NLM on Fedora


eh@dataconnection.com wrote:
> I've just installed Fedora, and am having problems with NFS.
>
> What I'm seeing is that NLM requests are not issued to the NFS server
> (which is a SNAP Server).  Instead the application hangs for about 7
> seconds, and then returns successfully (i.e. the locks are ostensibly
> granted).  The delay happens both on locks and unlock requests.  Via
> tcpdump I see NFS requests/responses, but no RPC calls for NLM.
Could you post a bzip2-ed ethereal trace (meaning
tethereal -w /tmp/dump.pcap; bzip2 /tmp/dump.pcap) of this?

There are some know locking issue with FC3
(see:  <https://bugzilla.redhat.com/beta/show_bug.cgi?id=3D150151> =
https://bugzilla.redhat.com/beta/show_bug.cgi?id=3D150151)
but this appears to be a bit different...

steved.



------_=_NextPart_001_01C540DF.E99BC627
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<TITLE></TITLE>

<META content=3D"MSHTML 6.00.2800.1491" name=3DGENERATOR></HEAD>
<BODY>
<DIV><FONT face=3DArial color=3D#ff00ff size=3D2><SPAN =
class=3D531544910-14042005>Moving=20
my data onto a filer which doesn't expose TCP (and therefore forces use =
of UDP)=20
seems to work fine.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#ff00ff size=3D2><SPAN=20
class=3D531544910-14042005></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial color=3D#ff00ff size=3D2><SPAN =
class=3D531544910-14042005>So I'm=20
now convinced this isn't a client-side problem.&nbsp; However I need to =
work=20
with this particular server, so to work around the server-side problem, =
I'd=20
still like a way to force NLM connections to use UDP rather than =
TCP.&nbsp;=20
</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#ff00ff size=3D2><SPAN=20
class=3D531544910-14042005></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial color=3D#ff00ff size=3D2><SPAN =
class=3D531544910-14042005>Anyone=20
know how to do this?</SPAN></FONT></DIV>
<DIV><FONT face=3DArial color=3D#ff00ff size=3D2><SPAN=20
class=3D531544910-14042005></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial color=3D#ff00ff size=3D2><SPAN=20
class=3D531544910-14042005>Edward.</SPAN></FONT></DIV>
<BLOCKQUOTE dir=3Dltr style=3D"MARGIN-RIGHT: 0px">
  <DIV class=3DOutlookMessageHeader dir=3Dltr align=3Dleft><FONT =
face=3DTahoma=20
  size=3D2>-----Original Message-----<BR><B>From:</B> Edward Hibbert=20
  (eh@dataconnection.com) <BR><B>Sent:</B> 14 April 2005 =
11:06<BR><B>To:</B>=20
  'Steve Dickson'<BR><B>Cc:</B> =
nfs@lists.sourceforge.net<BR><B>Subject:</B> RE:=20
  [NFS] Problem with NLM on Fedora<BR><BR></FONT></DIV>
  <P><FONT size=3D2><FONT face=3DArial color=3D#ff00ff>Digging a bit =
deeper, I was=20
  wrong to say there are no NLM packets flowing.&nbsp; =
Sorry.</FONT></FONT></P>
  <P><FONT face=3DArial color=3D#ff00ff size=3D2>What I think is =
happening is that the=20
  NLM requests are being lost, and the delays I'm seeing are due to=20
  retransmission.&nbsp; One difference that I notice from tcpdump trace =
is that=20
  Fedora is using TCP connections for the NLM traffic, whereas RedHat 8 =
(running=20
  successfully against the same filer) is using UDP.</FONT></P>
  <P><FONT face=3DArial color=3D#ff00ff size=3D2>Although I'd expect TCP =
to be more=20
  reliable, it's possible that the filer isn't very good at TCP=20
  traffic.&nbsp;&nbsp;TCP support&nbsp;has recently been added to this =
SNAP=20
  model - it only used to use UDP.&nbsp; So maybe it's =
flakey.</FONT></P>
  <P><FONT face=3DArial color=3D#ff00ff size=3D2>Is it possible to force =
the NLM=20
  traffic over UDP from the client side?</FONT></P>
  <P><FONT face=3DArial color=3D#ff00ff size=3D2>Edward.</FONT></P>
  <P><FONT size=3D2><FONT face=3DArial =
color=3D#ff00ff></FONT><BR>-----Original=20
  Message-----<BR>From: Steve Dickson [</FONT><A=20
  href=3D"mailto:SteveD@redhat.com"><FONT=20
  size=3D2>mailto:SteveD@redhat.com</FONT></A><FONT size=3D2>]<BR>Sent: =
14 April=20
  2005 00:44<BR>To: Edward Hibbert (eh@dataconnection.com)<BR>Cc:=20
  nfs@lists.sourceforge.net<BR>Subject: Re: [NFS] Problem with NLM on=20
  Fedora<BR><BR><BR>eh@dataconnection.com wrote:<BR>&gt; I've just =
installed=20
  Fedora, and am having problems with NFS.<BR>&gt;<BR>&gt; What I'm =
seeing is=20
  that NLM requests are not issued to the NFS server<BR>&gt; (which is a =
SNAP=20
  Server).&nbsp; Instead the application hangs for about 7<BR>&gt; =
seconds, and=20
  then returns successfully (i.e. the locks are ostensibly<BR>&gt;=20
  granted).&nbsp; The delay happens both on locks and unlock =
requests.&nbsp;=20
  Via<BR>&gt; tcpdump I see NFS requests/responses, but no RPC calls for =

  NLM.<BR>Could you post a bzip2-ed ethereal trace (meaning<BR>tethereal =
-w=20
  /tmp/dump.pcap; bzip2 /tmp/dump.pcap) of this?<BR><BR>There are some =
know=20
  locking issue with FC3<BR>(see: </FONT><A=20
  href=3D"https://bugzilla.redhat.com/beta/show_bug.cgi?id=3D150151"=20
  target=3D_blank><FONT=20
  =
size=3D2>https://bugzilla.redhat.com/beta/show_bug.cgi?id=3D150151</FONT>=
</A><FONT=20
  size=3D2>)<BR>but this appears to be a bit=20
different...<BR><BR>steved.<BR></P></BLOCKQUOTE></FONT></BODY></HTML>

------_=_NextPart_001_01C540DF.E99BC627--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
