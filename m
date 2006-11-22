From: "Murali Bashyam" <mbcoder@gmail.com>
Subject: Re: unfsd strange behaviour ?
Date: Wed, 22 Nov 2006 08:35:47 -0800
Message-ID: <9c8209a10611220835h40af88fdpdb4c36327e674235@mail.gmail.com>
References: <9c8209a10611212358o75127f4qd433e37c32fefc29@mail.gmail.com>
	<Pine.LNX.4.64.0611221027150.1093@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1312951289=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gmv4i-00083d-Gc
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 08:35:53 -0800
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gmv4i-0001p2-3a
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 08:35:53 -0800
Received: by nf-out-0910.google.com with SMTP id c31so911553nfb
	for <nfs@lists.sourceforge.net>; Wed, 22 Nov 2006 08:35:47 -0800 (PST)
To: "Peter Astrand" <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0611221027150.1093@maggie.lkpg.cendio.se>
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

--===============1312951289==
Content-Type: multipart/alternative;
	boundary="----=_Part_10140_9656475.1164213347521"

------=_Part_10140_9656475.1164213347521
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

It's not a LOOKUP operation in the NFS sense, actually the FUSE module that
is handling the operation reports it as a lookup (the unfsd backend call
ends up being handled by a FUSE server that i am developing). What actually
happens on the FUSE side is a operation (called getattr, not to be confused
with the NFS getattr) with a path name and the path name happens to be a
altogether different file name. I noticed in the unfsd code that the unfsd
is maintaining a file handle cache, and also issues backend operations base=
d
on the path name in that cache, could there be a stale entry in that cache?
Is there a way to turn off this file handle caching in unfsd? At this point
i am not sure whether FUSE may be causing this behaviour or not.

Thx,
Murali

On 11/22/06, Peter Astrand <astrand@cendio.se> wrote:
>
> On Tue, 21 Nov 2006, Murali Bashyam wrote:
>
> > I am running unfsd 0.9.16 on a linux 2.6 machine. I notice that from a
> > client machine while reading a file (say  XYZ)  the NFS client does
> GETATTR
> > using a file handle corresponding to that file, and unfsd after
> processing
> > that request initiates a LOOKUP operation for another file in the same
> > directory. ?
>
> You are saying that unfsd initiates a LOOKUP operation on itself? That
> doesn't make sense. I suggest that you give us access to a tcp dump,
> Wireshark screenshot or something like that.
>
> Regards,
> --
> Peter =C5strand           ThinLinc Chief Developer
> Cendio AB               http://www.cendio.se
> Teknikringen 3
> 583 30 Link=F6ping        Phone: +46-13-21 46 00
>

------=_Part_10140_9656475.1164213347521
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

It's not a LOOKUP operation in the NFS sense, actually the FUSE module that=
 is handling the operation reports it as a lookup (the unfsd backend call e=
nds up being handled by a FUSE server that i am developing). What actually =
happens on the FUSE side is a operation (called getattr, not to be confused=
 with the NFS getattr) with a path name and the path name happens to be a a=
ltogether different file name. I noticed in the unfsd code that the unfsd i=
s maintaining a file handle cache, and also issues backend operations based=
 on the path name in that cache, could there be a stale entry in that cache=
? Is there a way to turn off this file handle caching in unfsd? At this poi=
nt i am not sure whether FUSE may be causing this behaviour or not.
<br><br>Thx,<br>Murali<br><br><div><span class=3D"gmail_quote">On 11/22/06,=
 <b class=3D"gmail_sendername">Peter Astrand</b> &lt;<a href=3D"mailto:astr=
and@cendio.se">astrand@cendio.se</a>&gt; wrote:</span><blockquote class=3D"=
gmail_quote" style=3D"border-left: 1px solid rgb(204, 204, 204); margin: 0p=
t 0pt 0pt 0.8ex; padding-left: 1ex;">
On Tue, 21 Nov 2006, Murali Bashyam wrote:<br><br>&gt; I am running unfsd 0=
.9.16 on a linux 2.6 machine. I notice that from a<br>&gt; client machine w=
hile reading a file (say&nbsp;&nbsp;XYZ)&nbsp;&nbsp;the NFS client does GET=
ATTR<br>&gt; using a file handle corresponding to that file, and unfsd afte=
r processing
<br>&gt; that request initiates a LOOKUP operation for another file in the =
same<br>&gt; directory. ?<br><br>You are saying that unfsd initiates a LOOK=
UP operation on itself? That<br>doesn't make sense. I suggest that you give=
 us access to a tcp dump,
<br>Wireshark screenshot or something like that.<br><br>Regards,<br>--<br>P=
eter =C5strand&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
ThinLinc Chief Developer<br>Cendio AB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href=3D"http://www.cendio=
.se">http://www.cendio.se</a><br>Teknikringen 3
<br>583 30 Link=F6ping&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Phone=
: +46-13-21 46 00<br></blockquote></div><br>

------=_Part_10140_9656475.1164213347521--


--===============1312951289==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1312951289==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1312951289==--
