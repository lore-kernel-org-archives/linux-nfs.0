From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Caching
Date: Fri, 29 Mar 2002 12:48:31 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CE25@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C1D763.15E703C0"
Cc: nfs@lists.sourceforge.net
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16r3Ig-0007Au-00
	for <nfs@lists.sourceforge.net>; Fri, 29 Mar 2002 12:48:42 -0800
To: "'Matt Heaton'" <admin@0catch.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C1D763.15E703C0
Content-Type: text/plain;
	charset="iso-8859-1"

hi matt-
 
fsync() or close() will push the writes to the server immediately.  you can
also mount
the file system with the "sync" option to cause all write operations to push
the data
to the server before returning to your application.

-----Original Message-----
From: Matt Heaton [mailto:admin@0catch.com]
Sent: Friday, March 29, 2002 6:39 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] Caching


I have an NFS server that is 99% reads and 1% writes.   When I do writes the
NFS server (Or maybe the client) seems to cache files so that when a
write occurs my NFS clients don't get the updated files for a while.  Is
there some way to expire the cache whenever a write occurs for a specific
file?  I want the cache to be in place as 99% of all NFS service is reads on
my network, I just want updates available right away for the writes?  Any
clues?  I am running 2.4.18 with NFS_ALL patch compiled in on the clients,
and 2.4.18 (No patch) for the server.
 
Thanks,
Matt
 


------_=_NextPart_001_01C1D763.15E703C0
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">


<META content="MSHTML 5.50.4912.300" name=GENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=#ffffff>
<DIV><SPAN class=783564620-29032002><FONT face=Arial color=#0000ff size=2>hi 
matt-</FONT></SPAN></DIV>
<DIV><SPAN class=783564620-29032002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=783564620-29032002><FONT face=Arial color=#0000ff 
size=2>fsync() or close() will push the writes to the server immediately.&nbsp; 
you can also mount</FONT></SPAN></DIV>
<DIV><SPAN class=783564620-29032002><FONT face=Arial color=#0000ff size=2>the 
file system with the "sync" option to cause all write operations to push the 
data</FONT></SPAN></DIV>
<DIV><SPAN class=783564620-29032002><FONT face=Arial color=#0000ff size=2>to the 
server </FONT></SPAN><SPAN class=783564620-29032002><FONT face=Arial 
color=#0000ff size=2>before returning to your application.</FONT></SPAN></DIV>
<BLOCKQUOTE dir=ltr 
style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px solid; MARGIN-RIGHT: 0px">
  <DIV class=OutlookMessageHeader dir=ltr align=left><FONT face=Tahoma 
  size=2>-----Original Message-----<BR><B>From:</B> Matt Heaton 
  [mailto:admin@0catch.com]<BR><B>Sent:</B> Friday, March 29, 2002 6:39 
  AM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] 
  Caching<BR><BR></FONT></DIV>
  <DIV><FONT face=Arial size=2>I have an NFS server that is 99% reads and 1% 
  writes.&nbsp;&nbsp; When I do writes the NFS server (Or maybe the client) 
  seems to cache files so that when&nbsp;a</FONT></DIV>
  <DIV><FONT face=Arial size=2>write occurs my NFS clients don't get the updated 
  files for a while.&nbsp; Is there some way to expire the cache whenever a 
  write occurs for a specific</FONT></DIV>
  <DIV><FONT face=Arial size=2>file?&nbsp; I want the cache to be in place as 
  99% of all NFS service is reads on&nbsp;my network, I just want updates 
  available right away for the writes?&nbsp; Any</FONT></DIV>
  <DIV><FONT face=Arial size=2>clues?&nbsp; I am running 2.4.18 with NFS_ALL 
  patch compiled in on the clients, and 2.4.18 (No patch) for the 
  server.</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>Thanks,<BR>Matt</FONT></DIV>
  <DIV>&nbsp;</DIV></BLOCKQUOTE></BODY></HTML>

------_=_NextPart_001_01C1D763.15E703C0--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
