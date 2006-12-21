From: Stefan Palme <kleiner@hora-obscura.de>
Subject: many files in exported directory
Date: Thu, 21 Dec 2006 10:44:25 +0100
Message-ID: <1166694265.9506.59.camel@devel.office.ancoso-development.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GxKTd-0002Xx-Q1
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 01:44:38 -0800
Received: from moutng.kundenserver.de ([212.227.126.183])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GxKTd-0006hQ-KF
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 01:44:39 -0800
Received: from localhost (localhost [127.0.0.1])
	by smtp.hora-obscura.de (Postfix) with ESMTP id 8114C58400C
	for <nfs@lists.sourceforge.net>; Thu, 21 Dec 2006 10:44:29 +0100 (CET)
Received: from [192.168.2.126] (p54B940E6.dip0.t-ipconnect.de [84.185.64.230])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.hora-obscura.de (Postfix) with ESMTP id 4EEA858400B
	for <nfs@lists.sourceforge.net>; Thu, 21 Dec 2006 10:44:27 +0100 (CET)
To: nfs@lists.sourceforge.net
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


Hi,

in one NFS-exported directory I have a lot of small files:

  [s15223736 binary]# ls | wc -l
  57072
  [s15223736 binary]# du -h
  276M    .
  [s15223736 binary]# 


Doing a "ls" on the NFS-client takes very very long before the
first output appears. Because some applications working on this
NFS-imported directory very often use a kind of "ls" in this
directory, this applications seem to hang often.

What can I change in my configuration to improve performance?

Current NFS-server configuration: 
  * linux-2.6.17 with NFSv3-support compiled in
  * nfs-utils-1.0.6
  * /etc/exports:
       /.../binary IP/32(rw,async,all_squash,anonuid=64,anongid=261)

Current NFS-client configuration:
  * linux-2.6.18 with NFSv3 and NFSv4 support compiled in
  * nfs-utils-1.0.6
  * /etc/fstab:
      IP:/.../binary    /.../binary      nfs     soft,intr


Any hints?
Thanks and best regards
-stefan-


-- 
-------------------------------------------------------------------
Dipl. Inf. (FH) Stefan Palme
 
email: kleiner@hora-obscura.de
www:   http://hbci4java.kapott.org
icq:   36376278
phon:  +49 341 3910484
fax:   +49 1212 517956219
mobil: +49 178 3227887
 
key fingerprint: 1BA7 D217 36A1 534C A5AD  F18A E2D1 488A E904 F9EC
-------------------------------------------------------------------


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
