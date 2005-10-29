From: Gilles HAUTZ <gilles.hautz@mana.pf>
Subject: exportfs strange behavior
Date: Fri, 28 Oct 2005 14:09:16 -1000
Message-ID: <4362BDAC.7090804@mana.pf>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010902030101030709030500"
Cc: gilles.hautz@mana.pf
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVeHb-0006mw-Nu
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 17:09:15 -0700
Received: from mirapoint3.mana.pf ([202.3.225.153] ident=mirapoint)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EVeHY-0001jn-Mj
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 17:09:15 -0700
Received: from smtp2.mana.pf ([202.3.225.154])
	by mirapoint3.mana.pf (MOS 3.4.6-GR)
	with ESMTP id BEE11657
	for <nfs@lists.sourceforge.net>;
	Fri, 28 Oct 2005 14:08:57 -1000 (TAHT)
Received: from [192.168.4.30] (ntp2.mana.pf [202.3.225.5])
	by smtp2.mana.pf (MOS 3.5.8-GR)
	with ESMTP id BNN77867
	for nfs@lists.sourceforge.net;
	Fri, 28 Oct 2005 14:08:55 -1000 (TAHT)
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

This is a multi-part message in MIME format.
--------------010902030101030709030500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi list

I have a server running nfs-utils-1.0.7, stock kernel-2.6.13.4 on LFS-6.1
I'm exporting some directories to a lot of clients (different versions)
When I modify /etc/exports and run exportfs -ra or exportfs a , I need 
to remount the directory on ALL the clients.
It's very boring as this is a production server, and I don't know how to 
solve this issue.

Any help would be appreciate.

Sorry for my poor english.

--------------010902030101030709030500
Content-Type: text/x-vcard; charset=utf-8;
 name="gilles.hautz.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="gilles.hautz.vcf"

begin:vcard
fn:Gilles HAUTZ
n:HAUTZ;Gilles
org:MANA S.A.S.;PRODUCTION
adr;quoted-printable:;;B.P. 40001 FARE TONY;;TAHITI;98713;Polynesie Fran=C3=A7aise
email;internet:gilles.hautz@mana.pf
title;quoted-printable:Sp=C3=A9cialiste syst=C3=A8mes
tel;work:+689 479956
tel;fax:+689 508859
tel;cell:+689 789788
note:APNIC Member IAP/ISP of Tahiti and her islands
x-mozilla-html:TRUE
url:http://www.mana.pf
version:2.1
end:vcard


--------------010902030101030709030500--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
