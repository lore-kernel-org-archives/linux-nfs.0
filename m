From: "Murali Bashyam" <mbcoder@gmail.com>
Subject: Re: Improving unfsd scalability
Date: Thu, 30 Nov 2006 10:03:38 -0800
Message-ID: <9c8209a10611301003j5303ccc6r7238c68c44723227@mail.gmail.com>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0195810442=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GpqG7-0006WK-9t
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 10:03:43 -0800
Received: from nf-out-0910.google.com ([64.233.182.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GpqG6-0004Em-H5
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 10:03:44 -0800
Received: by nf-out-0910.google.com with SMTP id c31so5161629nfb
	for <nfs@lists.sourceforge.net>; Thu, 30 Nov 2006 10:03:39 -0800 (PST)
To: "Peter Astrand" <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
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

--===============0195810442==
Content-Type: multipart/alternative;
	boundary="----=_Part_14101_23106462.1164909818960"

------=_Part_14101_23106462.1164909818960
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Peter

The RPC implementation is not thread safe. And neither is the unfsd code
itself, there are unprotected globals such as the file handle cache etc.

Murali

On 11/30/06, Peter Astrand <astrand@cendio.se> wrote:
>
> On Wed, 29 Nov 2006, Murali Bashyam wrote:
>
> > Has anyone attempted to speedup concurrently handling many client NFS
> > requests in unfsd? Any experience regarding multi-threading or running
> > multiple processes within unfsd? Any do's and don'ts?
>
> This is an interesting topic. I guess it depends a lot on which RPC
> library you are using. The "normal" ONC RPC implementation, found in glib=
c
> for example, is as far as I know not thread safe. This might be a problem=
.
> Correct me if I'm wrong.
>
> Regards,
> --
> Peter =C5strand           ThinLinc Chief Developer
> Cendio AB               http://www.cendio.se
> Teknikringen 3
> 583 30 Link=F6ping        Phone: +46-13-21 46 00
>

------=_Part_14101_23106462.1164909818960
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Peter<br><br>The RPC implementation is not thread safe. And neither is the =
unfsd code itself, there are unprotected globals such as the file handle ca=
che etc.<br><br>Murali<br><br><div><span class=3D"gmail_quote">On 11/30/06,=
=20
<b class=3D"gmail_sendername">Peter Astrand</b> &lt;<a href=3D"mailto:astra=
nd@cendio.se">astrand@cendio.se</a>&gt; wrote:</span><blockquote class=3D"g=
mail_quote" style=3D"border-left: 1px solid rgb(204, 204, 204); margin: 0pt=
 0pt 0pt 0.8ex; padding-left: 1ex;">
On Wed, 29 Nov 2006, Murali Bashyam wrote:<br><br>&gt; Has anyone attempted=
 to speedup concurrently handling many client NFS<br>&gt; requests in unfsd=
? Any experience regarding multi-threading or running<br>&gt; multiple proc=
esses within unfsd? Any do's and don'ts?
<br><br>This is an interesting topic. I guess it depends a lot on which RPC=
<br>library you are using. The &quot;normal&quot; ONC RPC implementation, f=
ound in glibc<br>for example, is as far as I know not thread safe. This mig=
ht be a problem.
<br>Correct me if I'm wrong.<br><br>Regards,<br>--<br>Peter =C5strand&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ThinLinc Chief Devel=
oper<br>Cendio AB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; <a href=3D"http://www.cendio.se">http://www.cend=
io.se</a><br>Teknikringen 3<br>583 30 Link=F6ping&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;Phone: +46-13-21 46 00
<br></blockquote></div><br>

------=_Part_14101_23106462.1164909818960--


--===============0195810442==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0195810442==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0195810442==--
