From: "Venkatesh KS" <venkatesh.ks@gmail.com>
Subject: Re: linux nfs client tcp timeout
Date: Tue, 17 Apr 2007 22:49:13 +0530
Message-ID: <4cf2912c0704171019t46a53362h284f8088b4113c48@mail.gmail.com>
References: <4cf2912c0704060910n33a269f3xcce6967a3abafc92@mail.gmail.com>
	<1175980671.20878.7.camel@heimdal.trondhjem.org>
	<20070417153043.GA9616@pcnocjb.dlan.cinetic.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1127226364=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdrKn-00053j-Oq
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 10:19:20 -0700
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdrKo-00031i-AN
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 10:19:20 -0700
Received: by ug-out-1314.google.com with SMTP id z38so195663ugc
	for <nfs@lists.sourceforge.net>; Tue, 17 Apr 2007 10:19:17 -0700 (PDT)
In-Reply-To: <20070417153043.GA9616@pcnocjb.dlan.cinetic.de>
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

--===============1127226364==
Content-Type: multipart/alternative;
	boundary="----=_Part_6417_898358.1176830353316"

------=_Part_6417_898358.1176830353316
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

My tests have shown no correlation between what the manpage says
and nfs client behaviour.  Worse still after timeout, write system calls
returns with 1024 as the number of bytes written while it should be 0.

Will update with more data once I run more tests in about a week.

-venkatesh

On 4/17/07, Jens Beyer <jbe@webde.de> wrote:
>
>
> Hi,
>
> I am trying to figure this out by myself, so...
>
> On Sat, Apr 07, 2007 at 05:17:51PM -0400, Trond Myklebust wrote:
> > On Fri, 2007-04-06 at 21:40 +0530, Venkatesh KS wrote:
> > > Hi,
> > >
> > > I lost trace of a machine which was hung for 2 hours. The only
> > > culprits I can see are nfs write requests.
> > > The mount is for tcp, soft, retrans=3D4. Unfortunately I couldnt gath=
er
> > > much information.
> > >
> ...
> > >
> > > When I ran tests against a dead server, I saw timeouts of about 3
> > > minutes consistently.
> > > Only the first request took about 18mins to timeout.
> > >
> > > So what is the timeout characteristics for tcp in linux nfs client an=
d
> > > what parameters
> > > can influence it?
> >
> > man 5 nfs. You'll find a description of the 'timeo' and 'retrans'
> > options.
> >
>
> Looking at my manpage it tells me:
>
> timeo=3Dn        The  value  in  tenths  of  a second before sending the
> first
>                 retransmission after an RPC timeout.  The default value
> is  7
>                 tenths  of a second.  After the first timeout, the timeou=
t
> is
>                 doubled after each successive timeout until a maximum
> timeout
>                 of  60  seconds is reached or the enough retransmissions
> have
>                 occured to cause a major timeout.
>                 (Removed text related to 'hard' mounts)
>                 The  maximum  timeout is always 60 seconds.
>                 ...
>
> retrans=3Dn      The number of minor timeouts
> and  retransmissions  that  must
>                 occur  before a major timeout occurs.  The default is 3
> time=AD
>                 outs.  When a major timeout
> occurs,  the  file  operation  is
>                 either  aborted  or  a  "server  not  responding"  messag=
e
> is
>                 printed on the console.
>
> Thus in the mentioned case (retrans=3D4) I have to expect 4 minor timeout=
s
> based on 'timeo=3D7 (default)' values. If I get an RPC timeout (first min=
or
> timeout) retransmission starts after .7 s, again an RPC timeout (2nd mino=
r
> timeout) results in retransmission after 1.4 s and so on.
>
> This would lead to an major timeout after 4 * RPC-timeout + 10.5 s, for
> retrans=3D4.  (I thought the retrans and timeo values are those rpc-timeo=
uts
> but I am unsure for now).
>
> (Btw: it seems that the timeo is in units of seconds - at least on my
> machine)
>
> What I do not understand is how timeouts are coupled for one mount and
> different progs accessing this (failed) nfs-mount:
> I start 2 progs with an open() with a time shift of 10 s and they both
> fail at the same time after a time out of (x) and (x - 10 s). Anyone can
> explain this ?
>
> Doing consecutive open() with one program on a failed mount I get
> timeouts (retrans=3D3,timeo=3D1) :
>   run | timeout [s]
> -----+------------
>    1  |    6
>    2  |   12
>    3  |   24
>    4  |   48
>    5  |   60
>    6  |    6
>    7  |   12
>      ...
> after a while (??) the timeout stabilizes at 60 s.
>
> If i open() a file (nfs-mount working) waiting a moment while the mount
> fails I get after some write() on close() an I/O error after 3 s. This
> value
> seems to change depending how many calls (open, write, close etc) at whic=
h
> packetsize (writesize <> wsize) where made to the failed mount; after a
> while (cache flush ?) calls seems to get near to the above timeout table.
>
> Last mentioned a recovered nfs-mount takes a while to be recognized as
> recovered - depending on similar timeout-cascades as above.
>
> I would appreciate it, if someone could explain me the above behaviour to
> get a more deterministic view....
>
> Kind regards,
> Jens
>
> PS: my tests where made on 2.6.20.2/6
>
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>

------=_Part_6417_898358.1176830353316
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

My tests have shown no correlation between what the manpage says<br>and nfs=
 client behaviour.&nbsp; Worse still after timeout, write system calls<br>r=
eturns with 1024 as the number of bytes written while it should be 0.<br><b=
r>
Will update with more data once I run more tests in about a week.<br><br>-v=
enkatesh<br><br><div><span class=3D"gmail_quote">On 4/17/07, <b class=3D"gm=
ail_sendername">Jens Beyer</b> &lt;<a href=3D"mailto:jbe@webde.de">jbe@webd=
e.de
</a>&gt; wrote:</span><blockquote class=3D"gmail_quote" style=3D"border-lef=
t: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1=
ex;"><br>Hi,<br><br>I am trying to figure this out by myself, so...<br><br>
On Sat, Apr 07, 2007 at 05:17:51PM -0400, Trond Myklebust wrote:<br>&gt; On=
 Fri, 2007-04-06 at 21:40 +0530, Venkatesh KS wrote:<br>&gt; &gt; Hi,<br>&g=
t; &gt;<br>&gt; &gt; I lost trace of a machine which was hung for 2 hours. =
The only
<br>&gt; &gt; culprits I can see are nfs write requests.<br>&gt; &gt; The m=
ount is for tcp, soft, retrans=3D4. Unfortunately I couldnt gather<br>&gt; =
&gt; much information.<br>&gt; &gt;<br>...<br>&gt; &gt;<br>&gt; &gt; When I=
 ran tests against a dead server, I saw timeouts of about 3
<br>&gt; &gt; minutes consistently.<br>&gt; &gt; Only the first request too=
k about 18mins to timeout.<br>&gt; &gt;<br>&gt; &gt; So what is the timeout=
 characteristics for tcp in linux nfs client and<br>&gt; &gt; what paramete=
rs
<br>&gt; &gt; can influence it?<br>&gt;<br>&gt; man 5 nfs. You&#39;ll find =
a description of the &#39;timeo&#39; and &#39;retrans&#39;<br>&gt; options.=
<br>&gt;<br><br>Looking at my manpage it tells me:<br><br> timeo=3Dn&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The&nbsp;&nbsp;value&nbsp;&nbsp;in=
&nbsp;&nbsp;tenths&nbsp;&nbsp;of&nbsp;&nbsp;a second before sending the fir=
st
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;retransmission after an RPC timeout.&nbsp;&nbsp;Th=
e default value is&nbsp;&nbsp;7<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tenths&nbsp;&nbsp;o=
f a second.&nbsp;&nbsp;After the first timeout, the timeout is<br>&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;doubled after each successive timeout until a maximum timeout
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;of&nbsp;&nbsp;60&nbsp;&nbsp;seconds is reached or =
the enough retransmissions have<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;occured to cause a =
major timeout.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Removed text related to &#39;hard&#=
39; mounts)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The&nbsp;&nbsp;maximum&nbsp;&nbsp;timeo=
ut is always 60 seconds.
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;...<br><br> retrans=3Dn&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;The number of minor timeouts and&nbsp;&nbsp;retransmissions&nbsp;&=
nbsp;that&nbsp;&nbsp;must<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;occur&nbsp;&nbsp;before a=
 major timeout occurs.&nbsp;&nbsp;The default is 3 time=AD<br>&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;outs.&nbsp;&nbsp;When a major timeout occurs,&nbsp;&nbsp;the&nbsp;&=
nbsp;file&nbsp;&nbsp;operation&nbsp;&nbsp;is
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;either&nbsp;&nbsp;aborted&nbsp;&nbsp;or&nbsp;&nbsp=
;a&nbsp;&nbsp;&quot;server&nbsp;&nbsp;not&nbsp;&nbsp;responding&quot;&nbsp;=
&nbsp;message is<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;printed on the console.<br><br>Thu=
s in the mentioned case (retrans=3D4) I have to expect 4 minor timeouts<br>=
based on &#39;timeo=3D7 (default)&#39; values. If I get an RPC timeout (fir=
st minor
<br>timeout) retransmission starts after .7 s, again an RPC timeout (2nd mi=
nor<br>timeout) results in retransmission after 1.4 s and so on.<br><br>Thi=
s would lead to an major timeout after 4 * RPC-timeout + 10.5 s, for<br>
retrans=3D4.&nbsp;&nbsp;(I thought the retrans and timeo values are those r=
pc-timeouts<br>but I am unsure for now).<br><br>(Btw: it seems that the tim=
eo is in units of seconds - at least on my<br>machine)<br><br>What I do not=
 understand is how timeouts are coupled for one mount and
<br>different progs accessing this (failed) nfs-mount:<br>I start 2 progs w=
ith an open() with a time shift of 10 s and they both<br>fail at the same t=
ime after a time out of (x) and (x - 10 s). Anyone can<br>explain this ?
<br><br>Doing consecutive open() with one program on a failed mount I get<b=
r>timeouts (retrans=3D3,timeo=3D1) :<br>&nbsp;&nbsp;run | timeout [s]<br> -=
----+------------<br>&nbsp;&nbsp; 1&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;6<b=
r>&nbsp;&nbsp; 2&nbsp;&nbsp;|&nbsp;&nbsp; 12<br>&nbsp;&nbsp; 3&nbsp;&nbsp;|=
&nbsp;&nbsp; 24<br>&nbsp;&nbsp; 4&nbsp;&nbsp;|&nbsp;&nbsp; 48<br>
&nbsp;&nbsp; 5&nbsp;&nbsp;|&nbsp;&nbsp; 60<br>&nbsp;&nbsp; 6&nbsp;&nbsp;|&n=
bsp;&nbsp;&nbsp;&nbsp;6<br>&nbsp;&nbsp; 7&nbsp;&nbsp;|&nbsp;&nbsp; 12<br>&n=
bsp;&nbsp;&nbsp;&nbsp; ...<br>after a while (??) the timeout stabilizes at =
60 s.<br><br>If i open() a file (nfs-mount working) waiting a moment while =
the mount<br>fails I get after some write() on close() an I/O error after 3=
 s. This value
<br>seems to change depending how many calls (open, write, close etc) at wh=
ich<br>packetsize (writesize &lt;&gt; wsize) where made to the failed mount=
; after a<br>while (cache flush ?) calls seems to get near to the above tim=
eout table.
<br><br>Last mentioned a recovered nfs-mount takes a while to be recognized=
 as<br>recovered - depending on similar timeout-cascades as above.<br><br>I=
 would appreciate it, if someone could explain me the above behaviour to
<br>get a more deterministic view....<br><br>Kind regards,<br>Jens<br><br>P=
S: my tests where made on <a href=3D"http://2.6.20.2/6">2.6.20.2/6</a><br><=
br><br>--------------------------------------------------------------------=
-----
<br>This SF.net email is sponsored by DB2 Express<br>Download DB2 Express C=
 - the FREE version of DB2 express and take<br>control of your XML. No limi=
ts. Just data. Click to get it now.<br><a href=3D"http://sourceforge.net/po=
werbar/db2/">
http://sourceforge.net/powerbar/db2/</a><br>_______________________________=
________________<br>NFS maillist&nbsp;&nbsp;-&nbsp;&nbsp;<a href=3D"mailto:=
NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a><br><a href=3D"http=
s://lists.sourceforge.net/lists/listinfo/nfs">
https://lists.sourceforge.net/lists/listinfo/nfs</a><br></blockquote></div>=
<br>

------=_Part_6417_898358.1176830353316--


--===============1127226364==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1127226364==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1127226364==--
