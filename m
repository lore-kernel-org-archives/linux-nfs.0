From: Gilles HAUTZ <gilles.hautz@mana.pf>
Subject: exportfs -ra problem
Date: Thu, 03 Nov 2005 13:42:42 -1000
Message-ID: <436AA072.5010904@mana.pf>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090309010600020700060302"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EXojo-00045H-7k
	for nfs@lists.sourceforge.net; Thu, 03 Nov 2005 15:43:20 -0800
Received: from mirapoint3.mana.pf ([202.3.225.153] ident=mirapoint)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EXojm-0000Ff-AN
	for nfs@lists.sourceforge.net; Thu, 03 Nov 2005 15:43:20 -0800
Received: from smtp2.mana.pf ([202.3.225.154])
	by mirapoint3.mana.pf (MOS 3.4.6-GR)
	with ESMTP id BEK12757
	for <nfs@lists.sourceforge.net>;
	Thu, 3 Nov 2005 13:42:50 -1000 (TAHT)
Received: from [192.168.4.30] (trash.mana.pf [202.3.225.5] (may be forged))
	by smtp2.mana.pf (MOS 3.5.8-GR)
	with ESMTP id BOK29769
	for <nfs@lists.sourceforge.net>;
	Thu, 3 Nov 2005 13:42:14 -1000 (TAHT)
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
--------------090309010600020700060302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi

I've got a server running nfs-utils-1.0.7 latest kernel with bonding 
enabled.
When I modify the export file and then execute exportfs -ra, all the 
client ( 1.0.6 or 1.0.7 ) need to remount their mount point.
What is the problem as this is the first time it happens on a server. 
Same client doesn't have this problem on another server.

Any help would be appreciate.

--------------090309010600020700060302
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


--------------090309010600020700060302--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
