From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Corrupt Data when using NFS on Linux
Date: Mon, 28 Oct 2002 12:48:14 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D54FE2@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C27EC3.55E21E80"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186GoJ-000345-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 12:48:31 -0800
To: "'Alan Witz'" <awitz@magstarinc.com>
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C27EC3.55E21E80
Content-Type: text/plain;
	charset="iso-8859-1"

hi alan-
 
that information is crap, and should be removed from whereever you found it.
 
the problem is that typical file systems used on *Linux* NFS servers (like ext2) can't
store time stamps with sub-second resolution.  this is not a problem with typical
commercial NFS servers like Solaris or NetApp filers.  i'm not aware of any plan to
address this specific problem in 2.5, but that doesn't mean it won't be.
 
can you tell us more about your environment, especially which kernel is running
on your clients and what mount options you're using?
 

-----Original Message-----
From: Alan Witz [mailto:awitz@magstarinc.com]
Sent: Monday, October 28, 2002 3:07 PM
To: nfs@lists.sourceforge.net
Subject: [NFS] Corrupt Data when using NFS on Linux


I work for a small software company that recently began using NFS to implement a solution using a lesser-known database (Appgen).  The problem is that we're getting lots of corrupt database files in those files modified via NFS.  The on-line manual on linux.org makes the following reference which I think may be relevant:
 


SYMPTOM107.10. File Corruption When Using Multiple Clients


If a file has been modified within one second of its previous modification and left the same size, it will continue to generate the same inode number. Because of this, constant reads and writes to a file by multiple clients may cause file corruption. Fixing this bug requires changes deep within the filesystem layer, and therefore it is a 2.5 item. 

I was wondering if someone could clarify what is meant by this.  What is the relevance of the inode number?  And doesn't the inode of the file stay the same even if it is being modified?  Any help would be greatly appreciated.  Even some direction as to where else I might look would be helpful.  Thanks,

Alan Witz


------_=_NextPart_001_01C27EC3.55E21E80
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">


<META content="MSHTML 6.00.2800.1106" name=GENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=#ffffff>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff size=2>hi 
alan-</FONT></SPAN></DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff size=2>that 
information is crap, and should be removed from whereever you found 
it.</FONT></SPAN></DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff size=2>the 
problem is that typical file systems used on *Linux* NFS servers (like 
ext2)&nbsp;can't</FONT></SPAN></DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff size=2>store 
time stamps with sub-second resolution.&nbsp; this is not a problem with 
typical</FONT></SPAN></DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff 
size=2>commercial NFS servers like Solaris or NetApp filers.&nbsp; i'm not aware 
of any plan to</FONT></SPAN></DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff 
size=2>address this specific problem in 2.5, but that doesn't mean it won't 
be.</FONT></SPAN></DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff size=2>can 
you tell us more about your environment, especially which kernel is 
running</FONT></SPAN></DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff size=2>on 
your clients and what mount options you're using?</FONT></SPAN></DIV>
<DIV><SPAN class=529184420-28102002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<BLOCKQUOTE dir=ltr 
style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px solid; MARGIN-RIGHT: 0px">
  <DIV class=OutlookMessageHeader dir=ltr align=left><FONT face=Tahoma 
  size=2>-----Original Message-----<BR><B>From:</B> Alan Witz 
  [mailto:awitz@magstarinc.com]<BR><B>Sent:</B> Monday, October 28, 2002 3:07 
  PM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] Corrupt 
  Data when using NFS on Linux<BR><BR></FONT></DIV>
  <DIV>
  <DIV><FONT face=Arial size=2>I work for a small software company that recently 
  began using NFS to implement a solution using&nbsp;a lesser-known database 
  (Appgen).&nbsp; The problem is that we're getting lots of corrupt database 
  files in those files modified via NFS.&nbsp;&nbsp;The on-line manual&nbsp;on 
  linux.org makes the following reference which I think may be 
  relevant:</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV class=SECT2>
  <BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
    <H2 class=SECT2><A name=SYMPTOM10><FONT face=Arial size=2>7.10. File 
    Corruption When Using Multiple Clients</FONT></H2>
    <P><FONT face=Arial size=2>If a file has been modified within one second of 
    its previous modification and left the same size, it will continue to 
    generate the same inode number. Because of this, constant reads and writes 
    to a file by multiple clients may cause file corruption. Fixing this bug 
    requires changes deep within the filesystem layer, and therefore it is a 2.5 
    item. </FONT></P></BLOCKQUOTE>
  <P><FONT face=Arial size=2>I was wondering if someone could clarify what is 
  meant by this.&nbsp; What is the relevance of the inode number?&nbsp; And 
  doesn't the inode of the file stay the same even if it is being 
  modified?&nbsp; Any help would be greatly appreciated.&nbsp; Even some 
  direction as to where else I might look would be helpful.&nbsp; 
  Thanks,</FONT></P></DIV>
  <DIV><FONT face=Arial size=2>Alan 
Witz</FONT></DIV></A></DIV></BLOCKQUOTE></BODY></HTML>

------_=_NextPart_001_01C27EC3.55E21E80--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
