From: "Dennis, Richard" <Richard.Dennis@lehman.com>
Subject: RE: nfs connection refuse
Date: Mon, 25 Aug 2003 07:43:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0073ECCF4F99D611810B0002A58F26560EB31810@exnyc03.lehman.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="----_=_NextPart_001_01C36AFD.BD0888BE"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail-haw.bigfish.com ([12.129.199.61] helo=mail9-haw-R.bigfish.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19rFlZ-000078-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Aug 2003 04:44:09 -0700
To: "'will supat'" <willsupat@hotmail.com>, nfs@lists.sourceforge.net
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

------_=_NextPart_001_01C36AFD.BD0888BE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Make sure you don't have tcpwrappers issues on the server side (make sure
there is a line like "portmap: ALL" in the /etc/hosts.allow file on the
server.  Also I would turn off iptables on both boxes to make sure that's
not part of your problem.  Rather than just pinging the server try running
this command from the client "rpcinfo -p <servername>".  
 
 
-----Original Message-----
From: will supat [mailto:willsupat@hotmail.com] 
Sent: Saturday, August 23, 2003 1:18 PM
To: nfs@lists.sourceforge.net
Subject: [NFS] nfs connection refuse



I set up nfs on redhat linux 9. I created dir and mount locally, It's work.
But when I try to mount remotely from another redhat linux 9, I got error
message RPC: connection refuse. I can ping both ways. I also replace host
name with the IP address to eliminate DNS problem. But I still get the same
error message.

Please suggest what else I need to do to resolve this error message.

 

Thank you


------------------------------------------------------------------------------
This message is intended only for the personal and confidential use of the
designated recipient(s) named above.  If you are not the intended recipient of
this message you are hereby notified that any review, dissemination,
distribution or copying of this message is strictly prohibited.  This
communication is for information purposes only and should not be regarded as
an offer to sell or as a solicitation of an offer to buy any financial
product, an official confirmation of any transaction, or as an official
statement of Lehman Brothers.  Email transmission cannot be guaranteed to be
secure or error-free.  Therefore, we do not represent that this information is
complete or accurate and it should not be relied upon as such.  All
information is subject to change without notice.

------_=_NextPart_001_01C36AFD.BD0888BE
Content-Type: text/html
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML xmlns="http://www.w3.org/TR/REC-html40" xmlns:o = 
"urn:schemas-microsoft-com:office:office" xmlns:w = 
"urn:schemas-microsoft-com:office:word"><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=us-ascii">
<TITLE>Message</TITLE>

<META content="MSHTML 6.00.2715.400" name=GENERATOR>
<STYLE>@font-face {
	font-family: Tahoma;
}
@page Section1 {size: 8.5in 11.0in; margin: 1.0in 1.25in 1.0in 1.25in;
mso-footer-margin: .5in; }
P.MsoNormal {
	FONT-SIZE: 12pt; MARGIN: 0in 0in 0pt; FONT-FAMILY: "Times New Roman"
}
LI.MsoNormal {
	FONT-SIZE: 12pt; MARGIN: 0in 0in 0pt; FONT-FAMILY: "Times New Roman"
}
DIV.MsoNormal {
	FONT-SIZE: 12pt; MARGIN: 0in 0in 0pt; FONT-FAMILY: "Times New Roman"
}
A:link {
	COLOR: blue; TEXT-DECORATION: underline
}
SPAN.MsoHyperlink {
	COLOR: blue; TEXT-DECORATION: underline
}
A:visited {
	COLOR: #aa00aa; TEXT-DECORATION: underline
}
SPAN.MsoHyperlinkFollowed {
	COLOR: #aa00aa; TEXT-DECORATION: underline
}
SPAN.EmailStyle18 {
	COLOR: windowtext; FONT-FAMILY: Arial; mso-style-type: personal-compose
}
DIV.Section1 {
	page: Section1
}
</STYLE>
</HEAD>
<BODY lang=EN-US vLink=#aa00aa link=blue>
<DIV><SPAN class=990334011-25082003><FONT face=Arial color=#0000ff size=2>Make
sure you don't have tcpwrappers issues on the server side (make sure there is
a 
line like "portmap: ALL" in the /etc/hosts.allow file on the server.&nbsp;
Also 
I would turn off iptables on both boxes to make sure that's not part of your 
problem.&nbsp; Rather than just pinging the server try running this command
from 
the client "rpcinfo -p &lt;servername&gt;".&nbsp; </FONT></SPAN></DIV>
<DIV><SPAN class=990334011-25082003><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=990334011-25082003><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV></DIV>
<DIV class=OutlookMessageHeader lang=en-us dir=ltr align=left><FONT
face=Tahoma 
size=2>-----Original Message-----<BR><B>From:</B> will supat 
[mailto:willsupat@hotmail.com] <BR><B>Sent:</B> Saturday, August 23, 2003 1:18
PM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] nfs 
connection refuse<BR><BR></FONT></DIV>
<DIV class=Section1>
<P class=MsoNormal><FONT face=Arial size=2><SPAN 
style="FONT-SIZE: 10pt; FONT-FAMILY: Arial">I set up nfs on redhat linux 9. I 
created dir and mount locally, It's work. &nbsp;But when I try to mount
remotely 
from another redhat linux 9, I got error message RPC: connection refuse. I can
ping both ways. I also replace host name with the IP address to eliminate DNS 
problem. But I still get the same error message.<o:p></o:p></SPAN></FONT></P>
<P class=MsoNormal><FONT face=Arial size=2><SPAN 
style="FONT-SIZE: 10pt; FONT-FAMILY: Arial">Please suggest what else I need to
do to resolve this error message.<o:p></o:p></SPAN></FONT></P>
<P class=MsoNormal><FONT face=Arial size=2><SPAN 
style="FONT-SIZE: 10pt; FONT-FAMILY:
Arial"><o:p>&nbsp;</o:p></SPAN></FONT></P>
<P class=MsoNormal><FONT face=Arial size=2><SPAN 
style="FONT-SIZE: 10pt; FONT-FAMILY: Arial">Thank 
you<o:p></o:p></SPAN></FONT></P></DIV></BODY></HTML>

<P>------------------------------------------------------------------------------<br>
This message is intended only for the personal and confidential use of the
designated recipient(s) named above.  If you are not the intended recipient of
this message you are hereby notified that any review, dissemination,
distribution or copying of this message is strictly prohibited.  This
communication is for information purposes only and should not be regarded as
an offer to sell or as a solicitation of an offer to buy any financial
product, an official confirmation of any transaction, or as an official
statement of Lehman Brothers.  Email transmission cannot be guaranteed to be
secure or error-free.  Therefore, we do not represent that this information is
complete or accurate and it should not be relied upon as such.  All
information is subject to change without notice.<br>
</P>
------_=_NextPart_001_01C36AFD.BD0888BE--



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
