From: Chris Penney <cpenney@gmail.com>
Subject: Re: [CIRCUMVENTED] NFS client got stale NFS handle after server reboot
Date: Thu, 22 Sep 2005 12:27:33 -0400
Message-ID: <111aefd0509220927881ad18@mail.gmail.com>
References: <433027F7.1030702@staff.uni-marburg.de>
	 <4332784C.8040503@staff.uni-marburg.de>
	 <4332C52F.5000908@staff.uni-marburg.de>
	 <200509221720.52412.vincent.roqueta@ext.bull.net>
Reply-To: Chris Penney <cpenney@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_2722_3836150.1127406453708"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EITvv-00012T-KP
	for nfs@lists.sourceforge.net; Thu, 22 Sep 2005 09:28:27 -0700
Received: from xproxy.gmail.com ([66.249.82.205])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EITvu-0003IM-2R
	for nfs@lists.sourceforge.net; Thu, 22 Sep 2005 09:28:27 -0700
Received: by xproxy.gmail.com with SMTP id t10so518189wxc
        for <nfs@lists.sourceforge.net>; Thu, 22 Sep 2005 09:27:33 -0700 (PDT)
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200509221720.52412.vincent.roqueta@ext.bull.net>
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

------=_Part_2722_3836150.1127406453708
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 9/22/05, Vincent Roqueta <vincent.roqueta@ext.bull.net> wrote:
>
> There are several problems using x86_64 linux NFS (v4) machines as server=
,
> and
> it seems to have several problems on 64 bits architectures in general (at
> least with x86_64 and ppc64. Surely other architectures)
>
> For now there are this issue yet known (linux 2.6.13+CITI, Linux
> 2.6.14-rc*
> +CITI)
> -> Socket error -11 closing a big file (server : x86_64, clients: x86,
> ppc64)
> -> wrong lock behaviours (Client PPC64, servers: ppc64, x86)
> -> Input/output error closing a big file (server: ppc64, client x86_64)
> -> Oops (Client x86_64, server x86_64) - Linux 2.6.13+CITI
>
> However, this issues concern NFSv4. I am going to try to reproduce your
> problem with NFSv3 and NFSv4.
>
I've not heard anything negative about x86_64 systems as NFS servers, but
this note is somewhat concerning to me as I've got some new AMD Opteron
hardware coming to replace some Pentium 4 NFS servers. We only use NFS v3
(mainly tcp). Should I be concerned? Should I use i386 mode instead of
x86_64?
  Chris

------=_Part_2722_3836150.1127406453708
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<div><span class=3D"gmail_quote">On 9/22/05, <b class=3D"gmail_sendername">=
Vincent Roqueta</b> &lt;<a href=3D"mailto:vincent.roqueta@ext.bull.net">vin=
cent.roqueta@ext.bull.net</a>&gt; wrote:</span>
<blockquote class=3D"gmail_quote" style=3D"PADDING-LEFT: 1ex; MARGIN: 0px 0=
px 0px 0.8ex; BORDER-LEFT: #ccc 1px solid">There are several problems using=
 x86_64 linux NFS (v4) machines as server, and<br>it seems to have several =
problems on 64 bits architectures in general (at
<br>least with x86_64 and ppc64. Surely other architectures)<br><br>For now=
 there are this issue yet known (linux 2.6.13+CITI, Linux 2.6.14-rc*<br>+CI=
TI)<br>-&gt; Socket error -11 closing a big file (server : x86_64, clients:=
 x86, ppc64)
<br>-&gt; wrong lock behaviours&nbsp;&nbsp;(Client PPC64, servers: ppc64, x=
86)<br>-&gt;&nbsp;&nbsp;Input/output error closing a big file (server: ppc6=
4, client x86_64)<br>-&gt; Oops (Client x86_64, server x86_64) - Linux 2.6.=
13+CITI<br><br>However, this issues concern NFSv4. I am going to try to rep=
roduce your
<br>problem with NFSv3 and NFSv4.<br></blockquote></div>
<div>I've not heard anything negative about x86_64 systems as NFS servers, =
but this note is somewhat concerning to me as I've got some new AMD Opteron=
 hardware coming to replace some Pentium 4 NFS servers.&nbsp; We only use N=
FS v3 (mainly tcp).&nbsp; Should I be concerned?&nbsp; Should I use i386 mo=
de instead of x86_64?=20
</div>
<div>&nbsp;</div>
<div>&nbsp;&nbsp; Chris</div>

------=_Part_2722_3836150.1127406453708--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
