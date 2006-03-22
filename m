From: Bernd Nies <listuser@adnovum.ch>
Subject: NFS Error 1300?
Date: Wed, 22 Mar 2006 11:17:42 +0100
Message-ID: <44212446.80802@adnovum.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FM0Q1-0001j7-TG
	for nfs@lists.sourceforge.net; Wed, 22 Mar 2006 02:18:21 -0800
Received: from smtp.adnovum.ch ([193.192.235.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FM0Q1-0003EU-FN
	for nfs@lists.sourceforge.net; Wed, 22 Mar 2006 02:18:21 -0800
Received: from adnmail.zh.adnovum.ch (adnmail.zh.adnovum.ch [192.168.1.29])
	by smtp.adnovum.ch (Postfix) with SMTP id DA2FE22F3
	for <nfs@lists.sourceforge.net>; Wed, 22 Mar 2006 11:18:17 +0100 (CET)
Received: from [192.168.5.226] ([192.168.5.226])
 by adnmail.zh.adnovum.ch (SMSSMTP 4.1.9.35) with SMTP id M2006032211181700943
 for <nfs@lists.sourceforge.net>; Wed, 22 Mar 2006 11:18:17 +0100
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

Hi,

We have a NetApp FAS 3020 Filer and SUSE Linux 9.2 and 10 NFS clients.

When copying something from an NFS share to a local disk with the command

cd /share/java/tools/ide/eclipse/3.1.2; find . -depth | cpio -dmp 
/local/eclipse/3.1.2/.

The client sometimes gets heavy load and a tcpdump shows that there are 
a lot of ERR 1300 replies from the NFS server.

11:12:31.784395 IP server.nfs > client.1936027236: reply ERR 1300
11:12:31.784408 IP server.nfs > client.1818846305: reply ERR 1300
11:12:31.784415 IP server.nfs > client.1937006964: reply ERR 1300
11:12:31.784429 IP server.nfs > client.1668246893: reply ERR 1300
11:12:31.784436 IP server.nfs > client.673669997: reply ERR 1300
11:12:31.784449 IP server.nfs > client.1685284212: reply ERR 1300
11:12:31.784457 IP server.nfs > client.544173667: reply ERR 1300
11:12:31.784470 IP server.nfs > client.1650553383: reply ERR 1300
11:12:31.784477 IP server.nfs > client.757089906: reply ERR 1300
11:12:31.808298 IP server.nfs > client.1635018784: reply ERR 1300
11:12:31.808315 IP server.nfs > client.1869509746: reply ERR 1300
11:12:31.808324 IP server.nfs > client.1162694468: reply ERR 328
11:12:31.808349 IP server.nfs > client.1697200906: reply ERR 1300
11:12:31.808363 IP server.nfs > client.1769156201: reply ERR 1300
11:12:31.808370 IP server.nfs > client.538997864: reply ERR 328
11:12:33.270247 IP server.nfs > client.0: reply ERR 1300
11:12:33.270254 IP server.nfs > client.1459617792: reply ERR 328

Google did not find something about NFS error 1300. Is there a list what 
those error codes mean?

Thanks in advance.

Regards,
Bernd


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
