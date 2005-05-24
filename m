From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: Control over RPC retransmissions
Date: Tue, 24 May 2005 22:35:09 +0100
Message-ID: <9E621559095AA746B22B21CD4FAF99A50FA623@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C560A8.75B7F3AB"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dah3Z-0005fL-OQ
	for nfs@lists.sourceforge.net; Tue, 24 May 2005 14:35:21 -0700
Received: from smtp2.dataconnection.com ([192.91.191.8])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Dah3X-0006G7-Rl
	for nfs@lists.sourceforge.net; Tue, 24 May 2005 14:35:21 -0700
To: <nfs@lists.sourceforge.net>
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

------_=_NextPart_001_01C560A8.75B7F3AB
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

The timeo and retrans mount options give control over how RPC =
retransmissions are handled, e.g:
=20
 timeo=3Dn        The value in <http://seth.positivism.org/man.cgi/8/in> =
 tenths of a second before sending the first
                      retransmission after =
<http://seth.positivism.org/man.cgi/n/after>  an RPC timeout.  The =
default  value
                      is  7  tenths of a second.  After the first =
timeout <http://seth.positivism.org/man.cgi/3x/timeout> , the
                      timeout =
<http://seth.positivism.org/man.cgi/3x/timeout>  is doubled after =
<http://seth.positivism.org/man.cgi/n/after>  each successive timeout =
<http://seth.positivism.org/man.cgi/3x/timeout>  until a
                      maximum  timeout =
<http://seth.positivism.org/man.cgi/3x/timeout>   of 60 seconds is =
reached or the enough
                      retransmissions have occured to cause a  major  =
timeout.
                      Then,  if <http://seth.positivism.org/man.cgi/if> =
( 3 <http://seth.positivism.org/man.cgi/3/if> , n =
<http://seth.positivism.org/man.cgi/n/if> ) the filesystem is hard =
mounted, each new time <http://seth.positivism.org/man.cgi/3x/timeout> -
                      out =
<http://seth.positivism.org/man.cgi/3x/timeout>  cascade restarts at =
twice the initial value  of  the
                      previous cascade, again doubling at each =
retransmission.
                      The maximum timeout =
<http://seth.positivism.org/man.cgi/3x/timeout>  is always 60 seconds.  =
Better  over-
                      all  performance may be achieved by increasing the =
time <http://seth.positivism.org/man.cgi/3x/timeout> -
                      out =
<http://seth.positivism.org/man.cgi/3x/timeout>  when mounting on a busy =
network, to a  slow  server,
                      or through several routers or gateways.

       retrans=3Dn      The  number  of  minor timeouts and =
retransmissions that
                      must occur before a major timeout =
<http://seth.positivism.org/man.cgi/3x/timeout>  occurs.   The  default
                      is  3  timeouts.   When a major timeout =
<http://seth.positivism.org/man.cgi/3x/timeout>  occurs, the file =
<http://seth.positivism.org/man.cgi/file> ( 1 =
<http://seth.positivism.org/man.cgi/1/file> , n =
<http://seth.positivism.org/man.cgi/n/file> )
                      operation is either aborted or a "server not =
responding"
                      message =
<http://seth.positivism.org/man.cgi/n/message>  is printed on the =
console.
=20
60s is quite a long time.  I'd like to be able to cap the timeout at a =
lower level. Is there any way of doing this?
=20
Edward.

------_=_NextPart_001_01C560A8.75B7F3AB
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<TITLE>Message</TITLE>

<META content=3D"MSHTML 6.00.2800.1106" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D354233121-24052005><FONT face=3DArial color=3D#ff00ff =
size=3D2>The=20
timeo and retrans mount options give control over how RPC =
retransmissions are=20
handled, e.g:</FONT></SPAN></DIV>
<DIV><SPAN class=3D354233121-24052005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D354233121-24052005>&nbsp;<SPAN=20
class=3Dunderline>timeo=3Dn</SPAN>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; The=20
value <A title=3D"in(8) - fingerd - remote user information server"=20
href=3D"http://seth.positivism.org/man.cgi/8/in">in</A> tenths of a =
second before=20
sending the=20
first<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
retransmission <A=20
title=3D"after(n) - after - Execute a command after a time delay"=20
href=3D"http://seth.positivism.org/man.cgi/n/after">after</A> an RPC=20
timeout.&nbsp; The default&nbsp;=20
value<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
is&nbsp; 7&nbsp; tenths of a second.&nbsp; After the first <A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">timeout</A>,=20
the<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
<A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">timeout</A> is =
doubled <A=20
title=3D"after(n) - after - Execute a command after a time delay"=20
href=3D"http://seth.positivism.org/man.cgi/n/after">after</A> each =
successive <A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">timeout</A> until =

a<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
maximum&nbsp; <A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">timeout</A>&nbsp; =
of 60=20
seconds is reached or the=20
enough<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
retransmissions have occured to cause a&nbsp; major&nbsp;=20
timeout.<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
Then,&nbsp; <SPAN class=3Dcluster><A title=3D"Manual for if"=20
href=3D"http://seth.positivism.org/man.cgi/if">if</A><SPAN =
class=3Dsections>(<A=20
title=3D"if(3) - if - use a Perl module if a condition holds"=20
href=3D"http://seth.positivism.org/man.cgi/3/if">3</A>,<A=20
title=3D"if(n) - if - Execute scripts conditionally"=20
href=3D"http://seth.positivism.org/man.cgi/n/if">n</A>)</SPAN></SPAN> =
the=20
filesystem is hard mounted, each new <A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">time</A>-<BR>&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
<A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">out</A> cascade =
restarts at=20
twice the initial value&nbsp; of&nbsp;=20
the<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
previous cascade, again doubling at each=20
retransmission.<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =

The maximum <A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">timeout</A> is =
always 60=20
seconds.&nbsp; Better&nbsp;=20
over-<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
all&nbsp; performance may be achieved by increasing the <A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">time</A>-<BR>&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
<A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">out</A> when =
mounting on a=20
busy network, to a&nbsp; slow&nbsp;=20
server,<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
or through several routers or=20
gateways.<BR><BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <SPAN=20
class=3Dunderline>retrans=3Dn</SPAN>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
The&nbsp;=20
number&nbsp; of&nbsp; minor timeouts and retransmissions=20
that<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
must occur before a major <A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">timeout</A>=20
occurs.&nbsp;&nbsp; The&nbsp;=20
default<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
is&nbsp; 3&nbsp; timeouts.&nbsp;&nbsp; When a major <A=20
title=3D"timeout(3x) - cbreak, echo, halfdelay, intrflush, keypad, meta, =
nocbreak, nodelay, noecho, noqiflush, noraw, notimeout, qiflush, raw, =
timeout, typeahead, wtimeout - curses input options"=20
href=3D"http://seth.positivism.org/man.cgi/3x/timeout">timeout</A> =
occurs, the=20
<SPAN class=3Dcluster><A title=3D"Manual for file"=20
href=3D"http://seth.positivism.org/man.cgi/file">file</A><SPAN =
class=3Dsections>(<A=20
title=3D"file(1) - file - determine file type"=20
href=3D"http://seth.positivism.org/man.cgi/1/file">1</A>,<A=20
title=3D"file(n) - file - Manipulate file names and attributes"=20
href=3D"http://seth.positivism.org/man.cgi/n/file">n</A>)</SPAN></SPAN><B=
R>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
operation is either aborted or a "server not=20
responding"<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
<A title=3D"message(n) - message - Create and manipulate message =
widgets"=20
href=3D"http://seth.positivism.org/man.cgi/n/message">message</A> is =
printed on=20
the console.</SPAN></DIV>
<DIV><SPAN class=3D354233121-24052005><FONT face=3DArial color=3D#ff00ff =

size=3D2></FONT></SPAN>&nbsp;</DIV><FONT face=3DArial><FONT =
size=3D2><FONT=20
color=3D#ff00ff>
<DIV><SPAN class=3D354233121-24052005>60s is quite a long time.&nbsp; =
I'd like to=20
be able to cap the timeout at a lower level. Is there any way of doing=20
this?</SPAN></DIV>
<DIV><SPAN class=3D354233121-24052005></SPAN>&nbsp;</DIV>
<DIV><SPAN=20
class=3D354233121-24052005>Edward.</DIV></SPAN></BODY></HTML></FONT></FON=
T></FONT>

------_=_NextPart_001_01C560A8.75B7F3AB--


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
