From: "Alan Witz" <awitz@magstarinc.com>
Subject: Re: Corrupt Data when using NFS on Linux
Date: Mon, 28 Oct 2002 18:05:06 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <007601c27ed6$74986240$2864a8c0@alanw>
References: <6440EA1A6AA1D5118C6900902745938E07D54FE2@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0073_01C27EAC.8B9C34A0"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail4.uunet.ca ([209.167.141.34])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186Iwd-0007kM-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 15:05:15 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_0073_01C27EAC.8B9C34A0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Thanks for your quick response.

The operating environment is Red Hat Linux 2.4.18-17.7.xsmp.  We are =
running NFS version 3.  We have implemented some of our own rudimentary =
file locking techniques to try and circumvent the problem.  This =
consists of creating a lock file which acts as a flag which tells the =
other clients not to access the file.  Basically, if the lock file =
exists then the other clients will wait until the file is cleared before =
writing to the database file.  To ensure that this works properly the =
"lock" flag is being created using the "ln" command so that the process =
of checking for a lock and setting a lock is essentially done in one =
step (thus eliminating the possibility of another client setting the =
lock after the current client has checked for the lock but before it can =
set the lock itself).  We are also running NFS in synchronous mode to =
try and reduce the chances of data corruption due to multiple clients.  =
The mount options are as follows:

    rsize=3D8192,wsize=3D8192,noac,hard,sync,nfsvers=3D3

Any thoughts would be greatly appreciated.

        Alan Witz


  ----- Original Message -----=20
  From: Lever, Charles=20
  To: 'Alan Witz'=20
  Cc: nfs@lists.sourceforge.net=20
  Sent: Monday, October 28, 2002 3:48 PM
  Subject: RE: [NFS] Corrupt Data when using NFS on Linux


  hi alan-

  that information is crap, and should be removed from whereever you =
found it.

  the problem is that typical file systems used on *Linux* NFS servers =
(like ext2) can't
  store time stamps with sub-second resolution.  this is not a problem =
with typical
  commercial NFS servers like Solaris or NetApp filers.  i'm not aware =
of any plan to
  address this specific problem in 2.5, but that doesn't mean it won't =
be.

  can you tell us more about your environment, especially which kernel =
is running
  on your clients and what mount options you're using?

    -----Original Message-----
    From: Alan Witz [mailto:awitz@magstarinc.com]
    Sent: Monday, October 28, 2002 3:07 PM
    To: nfs@lists.sourceforge.net
    Subject: [NFS] Corrupt Data when using NFS on Linux


    I work for a small software company that recently began using NFS to =
implement a solution using a lesser-known database (Appgen).  The =
problem is that we're getting lots of corrupt database files in those =
files modified via NFS.  The on-line manual on linux.org makes the =
following reference which I think may be relevant:

      7.10. File Corruption When Using Multiple Clients
      If a file has been modified within one second of its previous =
modification and left the same size, it will continue to generate the =
same inode number. Because of this, constant reads and writes to a file =
by multiple clients may cause file corruption. Fixing this bug requires =
changes deep within the filesystem layer, and therefore it is a 2.5 =
item.=20

    I was wondering if someone could clarify what is meant by this.  =
What is the relevance of the inode number?  And doesn't the inode of the =
file stay the same even if it is being modified?  Any help would be =
greatly appreciated.  Even some direction as to where else I might look =
would be helpful.  Thanks,

    Alan Witz
------=_NextPart_000_0073_01C27EAC.8B9C34A0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1106" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Thanks for your quick =
response.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>The operating environment is Red Hat =
Linux=20
2.4.18-17.7.xsmp.&nbsp; We are running NFS version 3.&nbsp; We have =
implemented=20
some of our own rudimentary file locking techniques to try and =
circumvent the=20
problem.&nbsp; This consists of creating a lock file which acts as a =
flag which=20
tells the other clients not to access the file.&nbsp; Basically, if the =
lock=20
file exists then the other clients will wait until the file is cleared =
before=20
writing to the database file.&nbsp; To ensure that this works properly =
the=20
"lock" flag is being created using the "ln" command so that the process =
of=20
checking for a lock and setting a lock is essentially done in one step =
(thus=20
eliminating the possibility of another client setting the lock after the =
current=20
client has checked for the lock but before it can set the lock =
itself).&nbsp; We=20
are also running NFS in synchronous mode to try and reduce the chances =
of data=20
corruption due to multiple clients.&nbsp; The mount options are as=20
follows:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp;=20
rsize=3D8192,wsize=3D8192,noac,hard,sync,nfsvers=3D3</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Any thoughts would be greatly=20
appreciated.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial =
size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Alan=20
Witz</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<BLOCKQUOTE dir=3Dltr=20
style=3D"PADDING-RIGHT: 0px; PADDING-LEFT: 5px; MARGIN-LEFT: 5px; =
BORDER-LEFT: #000000 2px solid; MARGIN-RIGHT: 0px">
  <DIV style=3D"FONT: 10pt arial">----- Original Message ----- </DIV>
  <DIV=20
  style=3D"BACKGROUND: #e4e4e4; FONT: 10pt arial; font-color: =
black"><B>From:</B>=20
  <A title=3DCharles.Lever@netapp.com=20
  href=3D"mailto:Charles.Lever@netapp.com">Lever, Charles</A> </DIV>
  <DIV style=3D"FONT: 10pt arial"><B>To:</B> <A =
title=3Dawitz@magstarinc.com=20
  href=3D"mailto:awitz@magstarinc.com">'Alan Witz'</A> </DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Cc:</B> <A =
title=3Dnfs@lists.sourceforge.net=20
  =
href=3D"mailto:nfs@lists.sourceforge.net">nfs@lists.sourceforge.net</A> =
</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Sent:</B> Monday, October 28, 2002 =
3:48=20
  PM</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Subject:</B> RE: [NFS] Corrupt Data =
when=20
  using NFS on Linux</DIV>
  <DIV><BR></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff size=3D2>hi=20
  alan-</FONT></SPAN></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff=20
  size=3D2></FONT></SPAN>&nbsp;</DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff size=3D2>that=20
  information is crap, and should be removed from whereever you found=20
  it.</FONT></SPAN></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff=20
  size=3D2></FONT></SPAN>&nbsp;</DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff size=3D2>the=20
  problem is that typical file systems used on *Linux* NFS servers (like =

  ext2)&nbsp;can't</FONT></SPAN></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff=20
  size=3D2>store time stamps with sub-second resolution.&nbsp; this is =
not a=20
  problem with typical</FONT></SPAN></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff=20
  size=3D2>commercial NFS servers like Solaris or NetApp filers.&nbsp; =
i'm not=20
  aware of any plan to</FONT></SPAN></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff=20
  size=3D2>address this specific problem in 2.5, but that doesn't mean =
it won't=20
  be.</FONT></SPAN></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff=20
  size=3D2></FONT></SPAN>&nbsp;</DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff size=3D2>can=20
  you tell us more about your environment, especially which kernel is=20
  running</FONT></SPAN></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff size=3D2>on=20
  your clients and what mount options you're using?</FONT></SPAN></DIV>
  <DIV><SPAN class=3D529184420-28102002><FONT face=3DArial =
color=3D#0000ff=20
  size=3D2></FONT></SPAN>&nbsp;</DIV>
  <BLOCKQUOTE dir=3Dltr=20
  style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px =
solid; MARGIN-RIGHT: 0px">
    <DIV class=3DOutlookMessageHeader dir=3Dltr align=3Dleft><FONT =
face=3DTahoma=20
    size=3D2>-----Original Message-----<BR><B>From:</B> Alan Witz=20
    [mailto:awitz@magstarinc.com]<BR><B>Sent:</B> Monday, October 28, =
2002 3:07=20
    PM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] =
Corrupt=20
    Data when using NFS on Linux<BR><BR></FONT></DIV>
    <DIV>
    <DIV><FONT face=3DArial size=3D2>I work for a small software company =
that=20
    recently began using NFS to implement a solution using&nbsp;a =
lesser-known=20
    database (Appgen).&nbsp; The problem is that we're getting lots of =
corrupt=20
    database files in those files modified via NFS.&nbsp;&nbsp;The =
on-line=20
    manual&nbsp;on linux.org makes the following reference which I think =
may be=20
    relevant:</FONT></DIV>
    <DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
    <DIV class=3DSECT2>
    <BLOCKQUOTE dir=3Dltr style=3D"MARGIN-RIGHT: 0px">
      <H2 class=3DSECT2><A name=3DSYMPTOM10><FONT face=3DArial =
size=3D2>7.10. File=20
      Corruption When Using Multiple Clients</FONT></H2>
      <P><FONT face=3DArial size=3D2>If a file has been modified within =
one second=20
      of its previous modification and left the same size, it will =
continue to=20
      generate the same inode number. Because of this, constant reads =
and writes=20
      to a file by multiple clients may cause file corruption. Fixing =
this bug=20
      requires changes deep within the filesystem layer, and therefore =
it is a=20
      2.5 item. </FONT></P></BLOCKQUOTE>
    <P><FONT face=3DArial size=3D2>I was wondering if someone could =
clarify what is=20
    meant by this.&nbsp; What is the relevance of the inode =
number?&nbsp; And=20
    doesn't the inode of the file stay the same even if it is being=20
    modified?&nbsp; Any help would be greatly appreciated.&nbsp; Even =
some=20
    direction as to where else I might look would be helpful.&nbsp;=20
    Thanks,</FONT></P></DIV>
    <DIV><FONT face=3DArial size=3D2>Alan=20
Witz</FONT></DIV></A></DIV></BLOCKQUOTE></BLOCKQUOTE></BODY></HTML>

------=_NextPart_000_0073_01C27EAC.8B9C34A0--




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
