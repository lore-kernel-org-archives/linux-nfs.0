From: darren.miller@philips.com
Subject: NFS Server and long filenames
Date: Thu, 16 May 2002 15:46:37 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF9BADB0F9.0B7422F8-ON80256BBB.00507835@diamond.philips.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 0051337A80256BBB_="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gw-nl6.philips.com ([212.153.235.103])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178MX3-0006pl-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 07:47:05 -0700
Received: from smtpscan-nl2.philips.com (smtpscan-nl2.philips.com [130.139.36.22])
	by gw-nl6.philips.com (Postfix) with ESMTP id 82855A0BC2
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 16:47:00 +0200 (MET DST)
Received: from smtprelay-nl1.philips.com (localhost [127.0.0.1])
	by smtpscan-nl2.philips.com (8.9.3/8.8.5-1.2.2m-19990317) with ESMTP id QAA03050
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 16:46:59 +0200 (MET DST)
Received: from hbg001soh.diamond.philips.com (e1soh01.diamond.philips.com [130.143.165.45])
	by smtprelay-nl1.philips.com (8.9.3/8.8.5-1.2.2m-19990317) with ESMTP id QAA20193
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 16:46:59 +0200 (MET DST)
To: nfs@lists.sourceforge.net
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

This is a multipart message in MIME format.
--=_alternative 0051337A80256BBB_=
Content-Type: text/plain; charset="us-ascii"

Hi all,

I need to know if there is a way of allowing excessively long filenames 
over NFS,  we currently have
HPUX which supports this feature.. our main problem is that some amateur 
created a piece of software
which is now heavily used at my site, which creates computer generated 
files with name in excess of
400 characters.

I have managed to get a file in excess of 400 characters on the local 
system disk of our Linux Slackware 
system only I can't seem to be able to get this to work over NFS.

baring in mind that the NFS mounting is done from Linux to HPUX.

Currently our Network Appliance NAS solution does this, and the HPs do 
this, however Linux would appear
to be having some difficulty.

Any ideas, help or solution to problem welcome.

Darren

==============================================================================
Darren Miller 
Senior Systems Support Engineer
Microsoft Certified Professional
SCO Advanced Certified Engineer 
Infomation Systems Department (Core Server Support)
Philips Semiconductors,Milbrook Industrial Estate,Southampton,SO15 
0DJ,England
--=_alternative 0051337A80256BBB_=
Content-Type: text/html; charset="us-ascii"


<br><font size=2 face="sans-serif">Hi all,</font>
<br>
<br><font size=2 face="sans-serif">I need to know if there is a way of allowing excessively long filenames over NFS, &nbsp;we currently have</font>
<br><font size=2 face="sans-serif">HPUX which supports this feature.. our main problem is that some amateur created a piece of software</font>
<br><font size=2 face="sans-serif">which is now heavily used at my site, which creates computer generated files with name in excess of</font>
<br><font size=2 face="sans-serif">400 characters.</font>
<br>
<br><font size=2 face="sans-serif">I have managed to get a file in excess of 400 characters on the local system disk of our Linux Slackware </font>
<br><font size=2 face="sans-serif">system only I can't seem to be able to get this to work over NFS.</font>
<br>
<br><font size=2 face="sans-serif">baring in mind that the NFS mounting is done from Linux to HPUX.</font>
<br>
<br><font size=2 face="sans-serif">Currently our Network Appliance NAS solution does this, and the HPs do this, however Linux would appear</font>
<br><font size=2 face="sans-serif">to be having some difficulty.</font>
<br>
<br><font size=2 face="sans-serif">Any ideas, help or solution to problem welcome.</font>
<br>
<br><font size=2 face="sans-serif">Darren<br>
<br>
==============================================================================<br>
Darren Miller &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
Senior Systems Support Engineer<br>
Microsoft Certified Professional<br>
SCO Advanced Certified Engineer &nbsp; &nbsp; &nbsp; &nbsp;<br>
Infomation Systems Department (Core Server Support)<br>
Philips Semiconductors,Milbrook Industrial Estate,Southampton,SO15 0DJ,England</font>
--=_alternative 0051337A80256BBB_=--

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
