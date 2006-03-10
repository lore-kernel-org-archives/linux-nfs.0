From: "Vijay Chauhan" <kernel.vijay@gmail.com>
Subject: Re: NFS mount error
Date: Fri, 10 Mar 2006 16:53:17 +0530
Message-ID: <a9ed420f0603100323s539429d4n565a4292aefbfe82@mail.gmail.com>
References: <a9ed420f0603080059n65c8ee01t978a5e9f58ddcbd9@mail.gmail.com>
	 <440F06BB.1090802@citi.umich.edu>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_15283_19493057.1141989797054"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHfiI-0003wo-O6
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 03:23:18 -0800
Received: from xproxy.gmail.com ([66.249.82.192])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FHfiI-0004oZ-Dt
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 03:23:18 -0800
Received: by xproxy.gmail.com with SMTP id t5so483203wxc
        for <nfs@lists.sourceforge.net>; Fri, 10 Mar 2006 03:23:17 -0800 (PST)
To: cel@citi.umich.edu
In-Reply-To: <440F06BB.1090802@citi.umich.edu>
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

------=_Part_15283_19493057.1141989797054
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Thanks for ur explained reply.

- Vijay


On 3/8/06, Chuck Lever <cel@citi.umich.edu> wrote:
>
> Vijay Chauhan wrote:
> > hi,
> > im doing mount/unmount in an infinte loop
> > while [ "a" =3D=3D "a" ];
> > do
> > mount -t nfs -o tcp server:/filepath /mount-point
> > unmount -at nfs
> > done
> >
> > after some successful mount/unmount its giving error message like
> >
> > RPC: can't bind to reserved port.
> >
> > what does it means?
> >
> > TIA,
> > Vijay
>
> there are a limited number of reserved ports on every host.  each mount
> operation takes up to 5 ports (5 sockets for contacting the server's
> portmapper, mount daemon, and so on).  when each mount is finished, it
> leaves 4 sockets in TIME_WAIT and one, to the NFS server, is ESTABLISHED.
>
> after about 120 seconds the TIME_WAIT sockets will go away, freeing
> those ports.  but if you mount in a tight loop, you are not giving these
> sockets long enough to time out.  so all the reserved ports are used up
> with TIME_WAIT sockets.  you can see this with the "netstat" command.
>
> if you wait a few minutes, you will find that the ports free up and you
> can do more mounts.  or you can add a "sleep" in your loop.
>
> there has been some mitigation in later kernels.
>
> 1.  port numbers can be reused immediately in some circumstances.
>
> 2.  steve d has reduced the number of sockets used for a mount request.
>
> 3.  NFSv4 can usually skip the portmapper query.
>
> 4.  the RPC client will attempt to connect to the default port first,
> and use the portmapper only if the requested service isn't available on
> the default port.
>
> but a tight loop like yours will still probably consume all the reserved
> ports available on a client.
>
>
>

------=_Part_15283_19493057.1141989797054
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<div>Thanks for ur explained reply.</div>
<div>&nbsp;</div>
<div>- Vijay<br><br>&nbsp;</div>
<div><span class=3D"gmail_quote">On 3/8/06, <b class=3D"gmail_sendername">C=
huck Lever</b> &lt;<a href=3D"mailto:cel@citi.umich.edu">cel@citi.umich.edu=
</a>&gt; wrote:</span>
<blockquote class=3D"gmail_quote" style=3D"PADDING-LEFT: 1ex; MARGIN: 0px 0=
px 0px 0.8ex; BORDER-LEFT: #ccc 1px solid">Vijay Chauhan wrote:<br>&gt; hi,=
<br>&gt; im doing mount/unmount in an infinte loop<br>&gt; while [ &quot;a&=
quot; =3D=3D &quot;a&quot; ];
<br>&gt; do<br>&gt; mount -t nfs -o tcp server:/filepath /mount-point<br>&g=
t; unmount -at nfs<br>&gt; done<br>&gt;<br>&gt; after some successful mount=
/unmount its giving error message like<br>&gt;<br>&gt; RPC: can't bind to r=
eserved port.
<br>&gt;<br>&gt; what does it means?<br>&gt;<br>&gt; TIA,<br>&gt; Vijay<br>=
<br>there are a limited number of reserved ports on every host.&nbsp;&nbsp;=
each mount<br>operation takes up to 5 ports (5 sockets for contacting the s=
erver's
<br>portmapper, mount daemon, and so on).&nbsp;&nbsp;when each mount is fin=
ished, it<br>leaves 4 sockets in TIME_WAIT and one, to the NFS server, is E=
STABLISHED.<br><br>after about 120 seconds the TIME_WAIT sockets will go aw=
ay, freeing
<br>those ports.&nbsp;&nbsp;but if you mount in a tight loop, you are not g=
iving these<br>sockets long enough to time out.&nbsp;&nbsp;so all the reser=
ved ports are used up<br>with TIME_WAIT sockets.&nbsp;&nbsp;you can see thi=
s with the &quot;netstat&quot; command.
<br><br>if you wait a few minutes, you will find that the ports free up and=
 you<br>can do more mounts.&nbsp;&nbsp;or you can add a &quot;sleep&quot; i=
n your loop.<br><br>there has been some mitigation in later kernels.<br><br=
>1.&nbsp;&nbsp;port numbers can be reused immediately in some circumstances=
.
<br><br>2.&nbsp;&nbsp;steve d has reduced the number of sockets used for a =
mount request.<br><br>3.&nbsp;&nbsp;NFSv4 can usually skip the portmapper q=
uery.<br><br>4.&nbsp;&nbsp;the RPC client will attempt to connect to the de=
fault port first,<br>and use the portmapper only if the requested service i=
sn't available on
<br>the default port.<br><br>but a tight loop like yours will still probabl=
y consume all the reserved<br>ports available on a client.<br><br><br></blo=
ckquote></div><br>

------=_Part_15283_19493057.1141989797054--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
