From: "Benham, Timothy MR" <Timothy.Benham@defence.gov.au>
Subject: fcntl(3, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=0,
	len=0}) unreasonably slow SEC: UNCLASSIFIED
Date: Tue, 17 Oct 2006 10:59:31 +1000
Message-ID: <C172191424DC784385F213C8CBB4CDE015E1A4@rusrxm02.drn.mil.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0396738124=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZdPK-0000oa-8u
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 18:06:14 -0700
Received: from defuim01a.defence.gov.au ([203.10.224.150])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GZdPI-0001oY-Mw
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 18:06:15 -0700
To: <nfs@lists.sourceforge.net>
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

--===============0396738124==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C6F187.81087A01"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C6F187.81087A01
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I've noticed a problem with NFS file locking under Linux kernel
2.6.9-34.ELsmp. The server is a NetApp appliance. The problem was
initially discovered in a programs which access a file that holds state
for a distributed system. 30 second delays are unacceptable in this
application.

The problem is exhibited by a simple C program (let's call it tess) like

...
while(1) {
	fd=3Dopen(myNFSfile,O_RDWR);
	fcntl(fd, F_SETLKW, &myLock);
	close(fd);
	fprintf(stderr,".");
}
...

It prints period to the screen quickly. However running two instances at
once (eg "tess & tess") prints periods really slowly. Every call to
fcntl seems to take 30 seconds. If I compile and run tess under Solaris
9 the problem is not manifested.

Sorry about a lack of code etc but the systems in question are all
air-gapped. I'm only an applications programmer so I don't have access
to system logs, can't use tethereal, etc. Local systems support's answer
is to refer the question to Red Hat. Any clues on how I could get my
application working sooner than that would be appreciated.

cheers,
Tim Benham
Dept. of Defence


------_=_NextPart_001_01C6F187.81087A01
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7650.23">
<TITLE>fcntl(3, F_SETLKW, {type=3DF_WRLCK, whence=3DSEEK_SET, start=3D0, =
len=3D0}) unreasonably slow SEC: UNCLASSIFIED</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Arial">I've noticed a problem with NFS file =
locking under Linux kernel 2.6.9-34.ELsmp. The server is a NetApp =
appliance. The problem was initially discovered in a programs which =
access a file that holds state for a distributed system. 30 second =
delays are unacceptable in this application.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">The problem is exhibited by a simple C =
program (let's call it tess) like</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&#8230;</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">while(1) {</FONT>

<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT SIZE=3D2 =
FACE=3D"Arial">fd=3Dopen(myNFSfile,O_RDWR);</FONT>

<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT SIZE=3D2 =
FACE=3D"Arial">fcntl(fd, F_SETLKW, &amp;myLock);</FONT>

<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT SIZE=3D2 =
FACE=3D"Arial">close(fd);</FONT>

<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT SIZE=3D2 =
FACE=3D"Arial">fprintf(stderr,&quot;.&quot;);</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">}</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">...</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">It prints period to the screen quickly. =
However running two instances at once (eg &quot;tess &amp; tess&quot;) =
prints periods really slowly. Every call to fcntl seems to take 30 =
seconds. If I compile and run tess under Solaris 9 the problem is not =
manifested.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Sorry about a lack of code etc but the =
systems in question are all air-gapped. I'm only an applications =
programmer so I don't have access to system logs, can't use tethereal, =
etc. Local systems support's answer is to refer the question to Red Hat. =
Any clues on how I could get my application working sooner than that =
would be appreciated.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">cheers,</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Tim Benham</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Dept. of Defence</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C6F187.81087A01--


--===============0396738124==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============0396738124==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0396738124==--
