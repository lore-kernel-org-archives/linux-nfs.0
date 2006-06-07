From: <reservas@morrodaspedras.com>
Subject: Re: [PATCH] NFS server does not update mtime on setattr
	request
Date: Wed, 7 Jun 2006 12:28:29 -0300
Message-ID: <01b801c68a47$07cec3e0$7d01010a@p3>
References: <4485C3FE.5070504@redhat.com> <1149658707.27298.10.camel@localhost>
	<4486E662.5080900@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0053717478=="
Cc: Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fnzxl-0005k5-BJ
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:28:53 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fnzxl-0008W2-3n
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:28:53 -0700
Received: from hm397.locaweb.com.br ([200.234.205.160])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Fnzxb-0007LK-J3
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:28:53 -0700
To: "Peter Staubach" <staubach@redhat.com>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
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

This is a multi-part message in MIME format.

--===============0053717478==
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_01B5_01C68A2D.E1FCA470"

This is a multi-part message in MIME format.

------=_NextPart_000_01B5_01C68A2D.E1FCA470
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Please, dont wright no more for me. Tanks.
  ----- Original Message -----=20
  From: Peter Staubach=20
  To: Trond Myklebust=20
  Cc: Neil Brown ; NFS List ; Linux Kernel Mailing List=20
  Sent: Wednesday, June 07, 2006 11:44 AM
  Subject: Re: [PATCH] NFS server does not update mtime on setattr =
request


  Trond Myklebust wrote:

  >On Tue, 2006-06-06 at 14:05 -0400, Peter Staubach wrote:
  >
  > =20
  >
  >>On the NFS client side, there was an optimization added which =
attempted
  >>to avoid an over the wire call if the size of the file was not going =
to
  >>change.  This would be great, except for the side effect of the =
mtime
  >>on the file needing to change anyway.  The solution is just to issue =
the
  >>over the wire call anyway, which, as a side effect, updates the =
mtime and
  >>ctime fields.
  >>   =20
  >>
  >
  >Vetoed!
  >
  >The current code gets it quite right: if someone calls open(O_TRUNC),
  >then may_open() calls do_truncate() with the ATTR_MTIME|ATTR_CTIME =
flags
  >set. That will cause the client to do the right thing _regardless_ of
  >the size optimisation.
  >
  > =20
  >

  You are right.  My testing originally showed something different, but
  testing again shows the correct semantics.

  I think that the conservative thing to do though, since an over the =
wire
  call is being made anyway, is to remove the optimization and retain =
the
  size change.  The server is already going to have such a check in it
  anyway and issuing the SETATTR with the size change in it may reduce
  some races.

  >>On the NFS server side, there was a change to the routine, =
inode_setattr(),
  >>which now relies upon the caller to set the ATTR_MTIME and =
ATTR_CTIME
  >>flags in ia_valid in addition to the ATTR_SIZE.  Previously, this =
routine
  >>would force these bits on if the size of the file was not changing.  =
Now,
  >>this routine relies upon the caller to specify all of the fields =
which need
  >>to be updated.
  >>   =20
  >>
  >
  >Also wrong.
  >
  >This change causes the server to do entirely the wrong thing for
  >truncate()/ftruncate() calls: in the SuSv3 spec, a call that fails to
  >change the file length is supposed to leave the file entirely =
unchanged:
  >that includes mtime/ctime as well as suid/sgid bits.
  >

  I saw that wording too and assumed what I think that you assumed.  I =
assumed
  that that meant that if the new size is equal to the old size, then =
nothing
  should be changed.  However, that does not seem to be how those words =
are to
  be interpreted.  They are to be interpreted as "if the new length of =
the=20
  file
  can be successfully set, then the mtime/ctime should be changed".  It =
does
  not matter if the new length was the same as the old length or not.  =
Linux
  implements this semantic, as you pointed out above regarding the =
client side
  changes with the passing of ATTR_MTIME|ATTR_CTIME to do_truncate().  =
SunOS
  also implements this semantic.

  Therefore, I believe that this patch should stand because it modifies=20
  the NFS
  server to do the right thing and indeed, to match the current =
semantics of
  do_truncate().  The older version of do_truncate() would have set =
ATTR_MTIME
  and ATTR_CTIME itself if the file size was not actually changing.  =
Clients
  such as SunOS and older versions of Linux will require this change in =
order
  to properly interoperate with a new enough Linux NFS server.

  Neil, can we get these changes integrated, please?

      Thanx...

         ps
  -
  To unsubscribe from this list: send the line "unsubscribe =
linux-kernel" in
  the body of a message to majordomo@vger.kernel.org
  More majordomo info at  http://vger.kernel.org/majordomo-info.html
  Please read the FAQ at  http://www.tux.org/lkml/



  --=20
  No virus found in this incoming message.
  Checked by AVG Free Edition.
  Version: 7.1.394 / Virus Database: 268.8.2/357 - Release Date: =
6/6/2006


------=_NextPart_000_01B5_01C68A2D.E1FCA470
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2900.2873" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DTahoma>Please, dont wright no more for me. =
Tanks.</FONT></DIV>
<BLOCKQUOTE=20
style=3D"PADDING-RIGHT: 0px; PADDING-LEFT: 5px; MARGIN-LEFT: 5px; =
BORDER-LEFT: #000000 2px solid; MARGIN-RIGHT: 0px">
  <DIV style=3D"FONT: 10pt arial">----- Original Message ----- </DIV>
  <DIV=20
  style=3D"BACKGROUND: #e4e4e4; FONT: 10pt arial; font-color: =
black"><B>From:</B>=20
  <A title=3Dstaubach@redhat.com =
href=3D"mailto:staubach@redhat.com">Peter=20
  Staubach</A> </DIV>
  <DIV style=3D"FONT: 10pt arial"><B>To:</B> <A =
title=3Dtrond.myklebust@fys.uio.no=20
  href=3D"mailto:trond.myklebust@fys.uio.no">Trond Myklebust</A> </DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Cc:</B> <A title=3Dneilb@suse.de=20
  href=3D"mailto:neilb@suse.de">Neil Brown</A> ; <A=20
  title=3Dnfs@lists.sourceforge.net =
href=3D"mailto:nfs@lists.sourceforge.net">NFS=20
  List</A> ; <A title=3Dlinux-kernel@vger.kernel.org=20
  href=3D"mailto:linux-kernel@vger.kernel.org">Linux Kernel Mailing =
List</A>=20
</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Sent:</B> Wednesday, June 07, 2006 =
11:44=20
  AM</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Subject:</B> Re: [PATCH] NFS server =
does not=20
  update mtime on setattr request</DIV>
  <DIV><BR></DIV>Trond Myklebust wrote:<BR><BR>&gt;On Tue, 2006-06-06 at =
14:05=20
  -0400, Peter Staubach wrote:<BR>&gt;<BR>&gt;&nbsp; =
<BR>&gt;<BR>&gt;&gt;On the=20
  NFS client side, there was an optimization added which =
attempted<BR>&gt;&gt;to=20
  avoid an over the wire call if the size of the file was not going=20
  to<BR>&gt;&gt;change.&nbsp; This would be great, except for the side =
effect of=20
  the mtime<BR>&gt;&gt;on the file needing to change anyway.&nbsp; The =
solution=20
  is just to issue the<BR>&gt;&gt;over the wire call anyway, which, as a =
side=20
  effect, updates the mtime and<BR>&gt;&gt;ctime=20
  fields.<BR>&gt;&gt;&nbsp;&nbsp;&nbsp;=20
  <BR>&gt;&gt;<BR>&gt;<BR>&gt;Vetoed!<BR>&gt;<BR>&gt;The current code =
gets it=20
  quite right: if someone calls open(O_TRUNC),<BR>&gt;then may_open() =
calls=20
  do_truncate() with the ATTR_MTIME|ATTR_CTIME flags<BR>&gt;set. That =
will cause=20
  the client to do the right thing _regardless_ of<BR>&gt;the size=20
  optimisation.<BR>&gt;<BR>&gt;&nbsp; <BR>&gt;<BR><BR>You are =
right.&nbsp; My=20
  testing originally showed something different, but<BR>testing again =
shows the=20
  correct semantics.<BR><BR>I think that the conservative thing to do =
though,=20
  since an over the wire<BR>call is being made anyway, is to remove the=20
  optimization and retain the<BR>size change.&nbsp; The server is =
already going=20
  to have such a check in it<BR>anyway and issuing the SETATTR with the =
size=20
  change in it may reduce<BR>some races.<BR><BR>&gt;&gt;On the NFS =
server side,=20
  there was a change to the routine, inode_setattr(),<BR>&gt;&gt;which =
now=20
  relies upon the caller to set the ATTR_MTIME and =
ATTR_CTIME<BR>&gt;&gt;flags=20
  in ia_valid in addition to the ATTR_SIZE.&nbsp; Previously, this=20
  routine<BR>&gt;&gt;would force these bits on if the size of the file =
was not=20
  changing.&nbsp; Now,<BR>&gt;&gt;this routine relies upon the caller to =
specify=20
  all of the fields which need<BR>&gt;&gt;to be=20
  updated.<BR>&gt;&gt;&nbsp;&nbsp;&nbsp; =
<BR>&gt;&gt;<BR>&gt;<BR>&gt;Also=20
  wrong.<BR>&gt;<BR>&gt;This change causes the server to do entirely the =
wrong=20
  thing for<BR>&gt;truncate()/ftruncate() calls: in the SuSv3 spec, a =
call that=20
  fails to<BR>&gt;change the file length is supposed to leave the file =
entirely=20
  unchanged:<BR>&gt;that includes mtime/ctime as well as suid/sgid=20
  bits.<BR>&gt;<BR><BR>I saw that wording too and assumed what I think =
that you=20
  assumed.&nbsp; I assumed<BR>that that meant that if the new size is =
equal to=20
  the old size, then nothing<BR>should be changed.&nbsp; However, that =
does not=20
  seem to be how those words are to<BR>be interpreted.&nbsp; They are to =
be=20
  interpreted as "if the new length of the <BR>file<BR>can be =
successfully set,=20
  then the mtime/ctime should be changed".&nbsp; It does<BR>not matter =
if the=20
  new length was the same as the old length or not.&nbsp; =
Linux<BR>implements=20
  this semantic, as you pointed out above regarding the client =
side<BR>changes=20
  with the passing of ATTR_MTIME|ATTR_CTIME to do_truncate().&nbsp;=20
  SunOS<BR>also implements this semantic.<BR><BR>Therefore, I believe =
that this=20
  patch should stand because it modifies <BR>the NFS<BR>server to do the =
right=20
  thing and indeed, to match the current semantics =
of<BR>do_truncate().&nbsp;=20
  The older version of do_truncate() would have set ATTR_MTIME<BR>and =
ATTR_CTIME=20
  itself if the file size was not actually changing.&nbsp; =
Clients<BR>such as=20
  SunOS and older versions of Linux will require this change in =
order<BR>to=20
  properly interoperate with a new enough Linux NFS server.<BR><BR>Neil, =
can we=20
  get these changes integrated, please?<BR><BR>&nbsp;&nbsp;&nbsp;=20
  Thanx...<BR><BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ps<BR>-<BR>To =
unsubscribe=20
  from this list: send the line "unsubscribe linux-kernel" in<BR>the =
body of a=20
  message to <A=20
  =
href=3D"mailto:majordomo@vger.kernel.org">majordomo@vger.kernel.org</A><B=
R>More=20
  majordomo info at&nbsp; <A=20
  =
href=3D"http://vger.kernel.org/majordomo-info.html">http://vger.kernel.or=
g/majordomo-info.html</A><BR>Please=20
  read the FAQ at&nbsp; <A=20
  =
href=3D"http://www.tux.org/lkml/">http://www.tux.org/lkml/</A><BR><BR><BR=
><BR>--=20
  <BR>No virus found in this incoming message.<BR>Checked by AVG Free=20
  Edition.<BR>Version: 7.1.394 / Virus Database: 268.8.2/357 - Release =
Date:=20
  6/6/2006<BR><BR></BLOCKQUOTE></BODY></HTML>

------=_NextPart_000_01B5_01C68A2D.E1FCA470--



--===============0053717478==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0053717478==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0053717478==--
