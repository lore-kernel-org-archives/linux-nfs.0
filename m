From: "Vuppuluri, Nirmal" <nirmal.vuppuluri@viasat.com>
Subject: "inode number mismatch" error while using Solaris NFS server and
 Linux client
Date: Tue, 25 Oct 2005 12:47:14 -0400
Message-ID: <A8E6CBCE61F8D5478F6349C914A015BB01305773@COURIER.vmd.viasat.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5D983.C0D9E218"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EURuc-0005F4-46
	for nfs@lists.sourceforge.net; Tue, 25 Oct 2005 09:44:34 -0700
Received: from thrasher.viasat.com ([12.39.34.160] helo=transit.viasat.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EURuX-00045l-Kk
	for nfs@lists.sourceforge.net; Tue, 25 Oct 2005 09:44:31 -0700
To: nfs@lists.sourceforge.net
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C5D983.C0D9E218
Content-Type: text/plain;
	charset="iso-8859-1"

Hi all, 

I'm using a Solaris 8 NFS server to mount a file system on my Linux 
client (Intel XScale 465).  When the client boots up, the linux kernel 
prints a lot of messages like the following: 

nfs_refresh_inode: inode number mismatch 
expected (0x7/0xec172), got (0x7/0xec206) 
nfs_refresh_inode: inode number mismatch 
expected (0x7/0xec172), got (0x7/0xec16f) 


Linux version is 2.4.20 
Solaris server version is Solaris 8. 

(1) I tried to apply Trond Myklebust's patch (provided at 
http://marc.theaimsgroup.com/?l=linux-nfs&m=101316526524213&w=2
<http://marc.theaimsgroup.com/?l=linux-nfs&m=101316526524213&w=2> ), but I 
saw that it was already applied.  But, I still get the message. 

(2) I've tried the Sun bug database, but there is no information on 
this. 

This actually causes problems for me because, as a result of these 
errors, the linux kernel is not able to update my modules.dep file and 
therefore, I keep getting linux kernel messages indiciating that it 
cannot find module dependencies. 

Does anyone know of a solution or if there is a problem with the Sun 
NFS server on Solaris 8 ?  Do let me know if you'd like to see any 
diagnostics, sniffer captures, etc. 

Thanks a bunch, 
Nirmal. 



------_=_NextPart_001_01C5D983.C0D9E218
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2658.2">
<TITLE>&quot;inode number mismatch&quot; error while using Solaris NFS =
server and Linux client</TITLE>
</HEAD>
<BODY>

<P><FONT SIZE=3D2 FACE=3D"Arial">Hi all,<BR>
</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">I'm using a Solaris 8 NFS server to =
mount a file system on my Linux<BR>
client (Intel XScale 465). =A0When the client boots up, the linux =
kernel<BR>
prints a lot of messages like the following:<BR>
</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">nfs_refresh_inode: inode number =
mismatch<BR>
expected (0x7/0xec172), got (0x7/0xec206)<BR>
nfs_refresh_inode: inode number mismatch<BR>
expected (0x7/0xec172), got (0x7/0xec16f)<BR>
</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Linux version is 2.4.20<BR>
Solaris server version is Solaris 8.<BR>
</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">(1) I tried to apply Trond =
Myklebust's patch (provided at<BR>
</FONT><A =
HREF=3D"http://marc.theaimsgroup.com/?l=3Dlinux-nfs&amp;m=3D101316526524=
213&amp;w=3D2"><U><FONT COLOR=3D"#0000FF" SIZE=3D2 =
FACE=3D"Arial">http://marc.theaimsgroup.com/?l=3Dlinux-nfs&amp;m=3D10131=
6526524213&amp;w=3D2</FONT></U></A><FONT SIZE=3D2 FACE=3D"Arial">), but =
I<BR>
saw that it was already applied. =A0But, I still get the message.<BR>
</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">(2) I've tried the Sun bug database, =
but there is no information on<BR>
this.<BR>
</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">This actually causes problems for me =
because, as a result of these<BR>
errors, the linux kernel is not able to update my modules.dep file =
and<BR>
therefore, I keep getting linux kernel messages indiciating that it<BR>
cannot find module dependencies.<BR>
</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Does anyone know of a solution or if =
there is a problem with the Sun<BR>
NFS server on Solaris 8 ? =A0Do let me know if you'd like to see =
any<BR>
diagnostics, sniffer captures, etc.<BR>
</FONT>
<BR><FONT SIZE=3D2 FACE=3D"Arial">Thanks a bunch,<BR>
Nirmal. </FONT>
</P>
<BR>

</BODY>
</HTML>
------_=_NextPart_001_01C5D983.C0D9E218--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
