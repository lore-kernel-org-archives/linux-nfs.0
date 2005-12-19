From: "Abdullah Jarbou" <ajarbou@kau.edu.sa>
Subject: nfs mount failed at boot while succeed by mount -a
Date: Mon, 19 Dec 2005 14:33:48 +0300
Message-ID: <200512191133.jBJBXoQ04227@mail1.kaau.edu.sa>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0004_01C604A9.399E7D30"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EoJHI-0002yk-C7
	for nfs@lists.sourceforge.net; Mon, 19 Dec 2005 03:34:04 -0800
Received: from relay.kaau.edu.sa ([212.26.82.8])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EoJHF-0004T2-ND
	for nfs@lists.sourceforge.net; Mon, 19 Dec 2005 03:34:04 -0800
Received: from ITCISDP10 (itc-isd-p10.kaau.edu.sa [10.1.10.36])
	by mail1.kaau.edu.sa (8.11.6/8.11.6) with ESMTP id jBJBXoQ04227
	for <nfs@lists.sourceforge.net>; Mon, 19 Dec 2005 14:33:51 +0300
To: <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.

------=_NextPart_000_0004_01C604A9.399E7D30
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
X-NAIMIME-Disclaimer: 1
X-NAIMIME-Modified: 1

Hello,

I have a problem with mounting my nfs dir on the client using the /etc/fstab
, here are additional information:

The nfs server setting correctly and from client I can mount the directory
manually by the following command :

 

mount -t nfs NFSserver.domain:/usr/local/atmail/tmp/ /usr/local/atmail/tmp/

 

Also, the "mount -a" succeed on the client, that mean that the /etc/fstab
entry is good.!!

On the client boot the nfs fail with the following message:

---------- 

 

Dec 19 09:48:51 mail mount: mount to NFS server 'bckendmail1.kau.edu.sa'
failed: server is down.

Dec 19 09:48:57 mail mount: mount to NFS server 'bckendmail1.kau.edu.sa'
failed: server is down.

Dec 19 09:48:57 mail netfs: Mounting NFS filesystems:  failed

Dec 19 09:48:57 mail netfs: Mounting other filesystems:  succeeded

 --------- 

 

And here is my /etc/fstab entry:

NFSserver.domain:/usr/local/atmail/users /usr/local/atmail/users nfs rw 0 0

NFSserver.domain:/usr/local/atmail/tmp /usr/local/atmail/tmp nfs rw 0 0

 

I'm running Red Hat Enterprise AS 4 update 2 on both server and client.

In addition I do the following:

-verify that the (uname -n) for the server was set correctly in the nfs
client.

-trying using the (nfsvers=2 or nfservs=3) but without succeed.

- the rpcinfo -p servername is identical on both server and client.

- there is no firewall at all on neither server nor client, and both are
located on the same network subnet.

 

Any help ..?

 

Ajarbou



"Disclaimer by McAfee Web Shield e1000 Appliance"

This Outgoing Email has been scanned by King Abdul Aziz University SMTP Gateway Antivirus

------=_NextPart_000_0004_01C604A9.399E7D30
Content-Type: text/html
Content-Transfer-Encoding: 7bit
X-NAIMIME-Modified: 1

<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=us-ascii">
<meta name=Generator content="Microsoft Word 11 (filtered medium)">
<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman";}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
p
	{mso-margin-top-alt:auto;
	margin-right:0cm;
	mso-margin-bottom-alt:auto;
	margin-left:0cm;
	font-size:12.0pt;
	font-family:"Times New Roman";}
span.EmailStyle17
	{mso-style-type:personal-compose;
	color:black;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=EN-US link=blue vlink=purple>

<div class=Section1 dir=RTL>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>Hello,<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>I have a problem with mounting my nfs dir
on the client using the /etc/fstab , here are additional information:<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>The nfs server setting correctly and from
client I can mount the directory manually by the following command :<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>&nbsp;<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>mount -t nfs NFSserver.domain:/usr/local/atmail/tmp/
/usr/local/atmail/tmp/<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'><o:p>&nbsp;</o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>Also, the &quot;mount &#8211;a&quot; succeed
on the client, that mean that the /etc/fstab entry is good.!!<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>On the client boot the nfs fail with the
following message:<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>---------- <o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'><o:p>&nbsp;</o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>Dec 19 09:48:51 mail mount: mount to NFS
server 'bckendmail1.kau.edu.sa' failed: server is down.<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>Dec 19 09:48:57 mail mount: mount to NFS
server 'bckendmail1.kau.edu.sa' failed: server is down.<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>Dec 19 09:48:57 mail netfs: Mounting NFS
filesystems:&nbsp; failed<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>Dec 19 09:48:57 mail netfs: Mounting other
filesystems:&nbsp; succeeded<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>&nbsp;--------- <o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'><o:p>&nbsp;</o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>And here is my /etc/fstab entry:<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>NFSserver.domain:/usr/local/atmail/users /usr/local/atmail/users
nfs rw 0 0<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>NFSserver.domain:/usr/local/atmail/tmp /usr/local/atmail/tmp
nfs rw 0 0<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'><o:p>&nbsp;</o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>I'm running Red Hat Enterprise AS 4 update
2 on both server and client.<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>In addition I do the following:<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>-verify that the (uname &#8211;n) for the
server was set correctly in the nfs client.<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>-trying using the (nfsvers=2 or nfservs=3)
but without succeed.<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>- the rpcinfo &#8211;p servername is
identical on both server and client.<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>- there is no firewall at all on neither
server nor client, and both are located on the same network subnet.<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'><o:p>&nbsp;</o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>Any help ..?<o:p></o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'><o:p>&nbsp;</o:p></span></font></p>

<p class=MsoNormal dir=LTR><font size=3 color=black face="Times New Roman"><span
style='font-size:12.0pt;color:black'>Ajarbou<o:p></o:p></span></font></p>

</div>


<DIV><P><HR>
&quot;Disclaimer by McAfee Web Shield e1000 Appliance&quot;<BR>
<BR>
This Outgoing Email has been scanned by King Abdul Aziz University SMTP Gateway Antivirus
</P></DIV>
</body>

</html>

------=_NextPart_000_0004_01C604A9.399E7D30--




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
