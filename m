From: "Murali Bashyam" <mbcoder@gmail.com>
Subject: Re: unfsd strange behaviour ?
Date: Wed, 22 Nov 2006 10:42:41 -0800
Message-ID: <9c8209a10611221042v6d669d3tbabf405022f0efcb@mail.gmail.com>
References: <9c8209a10611212358o75127f4qd433e37c32fefc29@mail.gmail.com>
	<Pine.LNX.4.64.0611221027150.1093@maggie.lkpg.cendio.se>
	<9c8209a10611220835h40af88fdpdb4c36327e674235@mail.gmail.com>
	<Pine.LNX.4.64.0611221804480.28977@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0121585929=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gmx3Y-0005g4-Pm
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 10:42:49 -0800
Received: from nf-out-0910.google.com ([64.233.182.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gmx3Y-0006hB-Cd
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 10:42:50 -0800
Received: by nf-out-0910.google.com with SMTP id c31so967043nfb
	for <nfs@lists.sourceforge.net>; Wed, 22 Nov 2006 10:42:42 -0800 (PST)
To: "Peter Astrand" <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0611221804480.28977@maggie.lkpg.cendio.se>
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

--===============0121585929==
Content-Type: multipart/alternative;
	boundary="----=_Part_12431_6816516.1164220961797"

------=_Part_12431_6816516.1164220961797
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 11/22/06, Peter Astrand <astrand@cendio.se> wrote:
>
>
> > It's not a LOOKUP operation in the NFS sense, actually the FUSE module
> that
> > is handling the operation reports it as a lookup (the unfsd backend cal=
l
> > ends up being handled by a FUSE server that i am developing). What
> actually
> > happens on the FUSE side is a operation (called getattr, not to be
> confused
> > with the NFS getattr) with a path name and the path name happens to be =
a
> > altogether different file name.
>
> The FUSE getattr is probably the result of unfsd doing a normal stat().
> This is expected: When unfsd is "decomposing" a file handle into a path,
> it stat:s every file in the target directory (actually, plausible
> directories), until it finds a file with the correct st_dev and st_ino.
>
>
> > I noticed in the unfsd code that the unfsd is maintaining a file handle
> > cache, and also issues backend operations based on the path name in tha=
t
> > cache, could there be a stale entry in that cache? Is there a way to
> > turn off this file handle caching in unfsd? At this point i am not sure
> > whether FUSE may be causing this behaviour or not.
>
> If you turn off the file handle cache, the number of stat()s will
> increase.


So while performing the stat call, it has to map the file handle which came
in the GETATTR NFS request to a file name, correct? My question was whether
it is  possible that the mapping can become stale, if that mapping is
cached.

Murali

Regards,
> --
> Peter =C5strand           ThinLinc Chief Developer
> Cendio AB               http://www.cendio.se
> Teknikringen 3
> 583 30 Link=F6ping        Phone: +46-13-21 46 00
>

------=_Part_12431_6816516.1164220961797
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<br><br><div><span class=3D"gmail_quote">On 11/22/06, <b class=3D"gmail_sen=
dername">Peter Astrand</b> &lt;<a href=3D"mailto:astrand@cendio.se">astrand=
@cendio.se</a>&gt; wrote:</span><blockquote class=3D"gmail_quote" style=3D"=
border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; paddi=
ng-left: 1ex;">
<br>&gt; It's not a LOOKUP operation in the NFS sense, actually the FUSE mo=
dule that<br>&gt; is handling the operation reports it as a lookup (the unf=
sd backend call<br>&gt; ends up being handled by a FUSE server that i am de=
veloping). What actually
<br>&gt; happens on the FUSE side is a operation (called getattr, not to be=
 confused<br>&gt; with the NFS getattr) with a path name and the path name =
happens to be a<br>&gt; altogether different file name.<br><br>The FUSE get=
attr is probably the result of unfsd doing a normal stat().
<br>This is expected: When unfsd is &quot;decomposing&quot; a file handle i=
nto a path,<br>it stat:s every file in the target directory (actually, plau=
sible<br>directories), until it finds a file with the correct st_dev and st=
_ino.
<br><br><br>&gt; I noticed in the unfsd code that the unfsd is maintaining =
a file handle<br>&gt; cache, and also issues backend operations based on th=
e path name in that<br>&gt; cache, could there be a stale entry in that cac=
he? Is there a way to
<br>&gt; turn off this file handle caching in unfsd? At this point i am not=
 sure<br>&gt; whether FUSE may be causing this behaviour or not.<br><br>If =
you turn off the file handle cache, the number of stat()s will<br>increase.
</blockquote><div><br>So while performing the stat call, it has to map the =
file handle which came in the GETATTR NFS request to a file name, correct? =
My question was whether it is&nbsp; possible that the mapping can become st=
ale, if that mapping is cached.
<br><br>Murali <br></div><br><blockquote class=3D"gmail_quote" style=3D"bor=
der-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-=
left: 1ex;">Regards,<br>--<br>Peter =C5strand&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ThinLinc Chief Developer
<br>Cendio AB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; <a href=3D"http://www.cendio.se">http://www.cendio.s=
e</a><br>Teknikringen 3<br>583 30 Link=F6ping&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;Phone: +46-13-21 46 00<br></blockquote></div><br>

------=_Part_12431_6816516.1164220961797--


--===============0121585929==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0121585929==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0121585929==--
