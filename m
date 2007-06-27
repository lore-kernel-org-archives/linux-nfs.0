From: "farhan ahmed" <farhhanahmed@hotmail.com>
Subject: NFS issue
Date: Wed, 27 Jun 2007 04:14:56 +0000
Message-ID: <BAY107-F38728F96EA29AAED5327B6D00A0@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1656925249=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3Ovo-0006l7-Ag
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 21:15:04 -0700
Received: from bay0-omc3-s22.bay0.hotmail.com ([65.54.246.222])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3Ovo-0002g8-HQ
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 21:15:07 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1656925249==
Content-Type: text/html; format=flowed

<html><div style='background-color:'><P>Hi All,</P>
<P>We have weird NFS issue. we can't mount NFs share, when i enabled debug it gives </P>
<P>following error</P>
<P><FONT face=Arial color=navy size=2><SPAN style="FONT-SIZE: 10pt; COLOR: navy; FONT-FAMILY: Arial">Jun 27 12:04:30 backup03-syd kernel: nfs_get_root: getattr error = 13<?xml:namespace prefix = o ns = "urn:schemas-microsoft-com:office:office" /><o:p></o:p></SPAN></FONT></P>
<P class=MsoNormal><FONT face=Arial color=navy size=2><SPAN style="FONT-SIZE: 10pt; COLOR: navy; FONT-FAMILY: Arial">Jun 27 12:04:30 backup03-syd kernel: nfs_sb_init: get root inode failed: errno 13<o:p></o:p></SPAN></FONT></P>
<P class=MsoNormal>
<P class=MsoNormal><FONT face=Arial color=navy size=2><SPAN style="FONT-SIZE: 10pt; COLOR: navy; FONT-FAMILY: Arial"><o:p></o:p></SPAN></FONT></P>We dont have any problem with other shares. I have used all ways to solve but it is still there.</P>
<P>OS: Red Hat Enterprise Linux ES release 4 (Nahant Update 2)</P>
<P>Kernel: 2.6.9-55.ELsmp #1 SMP</P>
<P>/etc/exports: /mnt/p03&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; *(rw,sync,no_root_squash)</P>
<P>This box is attached with EMC SAN through HBA card and mounted partition on this box</P>
<P>/dev/emcpoweru&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 18G&nbsp; 7.4G&nbsp; 9.6G&nbsp; 44% /mnt/p03</P>
<P>and then shared it through NFS.</P>
<P>Initially I thought there was problem with SAN partition but I can access this same partition on </P>
<P>other system and then share through NFS.</P>
<P>Please help me</P>
<P>Thanks,</P>
<P><SPAN style="mso-no-proof: yes"><FONT size=3><FONT face="Times New Roman">-- <o:p></o:p></FONT></FONT></SPAN></P>
<DIV>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><SPAN style="mso-no-proof: yes"><FONT size=3><FONT face="Times New Roman">Regards,<o:p></o:p></FONT></FONT></SPAN></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><SPAN style="mso-no-proof: yes"><FONT size=3><FONT face="Times New Roman">Farhan Ahmed<o:p></o:p></FONT></FONT></SPAN></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><SPAN style="mso-no-proof: yes"><FONT size=3><FONT face="Times New Roman">NMS Engineer<o:p></o:p></FONT></FONT></SPAN></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><FONT size=3><FONT face="Times New Roman"><SPAN style="mso-no-proof: yes">Soul </SPAN><?xml:namespace prefix = st1 ns = "urn:schemas-microsoft-com:office:smarttags" /><st1:country-region><st1:place><SPAN style="mso-no-proof: yes">Australia</SPAN></st1:place></st1:country-region><SPAN style="mso-no-proof: yes"><o:p></o:p></SPAN></FONT></FONT></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><FONT size=3><FONT face="Times New Roman"><SPAN style="mso-no-proof: yes">Level 14, 201 </SPAN><st1:country-region><st1:place><SPAN style="mso-no-proof: yes">Kent</SPAN></st1:place></st1:country-region><SPAN style="mso-no-proof: yes"> Streen<o:p></o:p></SPAN></FONT></FONT></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><FONT size=3><FONT face="Times New Roman"><st1:City><st1:place><SPAN style="mso-no-proof: yes">Sydney</SPAN></st1:place></st1:City><SPAN style="mso-no-proof: yes"><SPAN style="mso-spacerun: yes">&nbsp; </SPAN>NSW 2000<o:p></o:p></SPAN></FONT></FONT></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><SPAN style="mso-no-proof: yes"><FONT size=3><FONT face="Times New Roman">Phone(Office): 61 2 8220 6022<o:p></o:p></FONT></FONT></SPAN></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><SPAN style="mso-no-proof: yes"><FONT size=3><FONT face="Times New Roman">Fax(Office): 61 2 9252 6864<o:p></o:p></FONT></FONT></SPAN></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><FONT size=3><FONT face="Times New Roman"><st1:City><st1:place><SPAN style="mso-no-proof: yes">Mobile</SPAN></st1:place></st1:City><SPAN style="mso-no-proof: yes">: 61 432 156906<o:p></o:p></SPAN></FONT></FONT></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><SPAN style="mso-no-proof: yes"><FONT face="Times New Roman" size=3>Email: </FONT><A href="mailto:fahmed@soulaustralia.com.au"><FONT face="Times New Roman" size=3>fahmed@soulaustralia.com.au</FONT></A><o:p></o:p></SPAN></P>
<P class=MsoNormal style="MARGIN: 0cm 0cm 0pt"><SPAN style="mso-no-proof: yes"><FONT face="Times New Roman" size=3>URL: </FONT><A href="http://www.soulaustralia.com.au/"><FONT face="Times New Roman" size=3>www.soulaustralia.com.au</FONT></A></SPAN><o:p></o:p></P>
<P>&nbsp;</P></DIV></div><br clear=all><hr>Search for local singles online @ Lavalife -  <a href="http://g.msn.com/8HMAENAU/2731??PS=47575" target="_top">Click here</a> </html>



--===============1656925249==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1656925249==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1656925249==--
