From: "Mario Schroen" <security.schroen@internet24.de>
Subject: stale NFS Handle and hanging
Date: Wed, 12 May 2004 11:43:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <DEEHKMKPNJNCFOLCILBKGECLJDAA.security.schroen@internet24.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BNqIb-0003WA-Qw
	for nfs@lists.sourceforge.net; Wed, 12 May 2004 02:45:13 -0700
Received: from mailout02.ims-firmen.de ([213.174.32.97])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BNqIb-0005OE-J5
	for nfs@lists.sourceforge.net; Wed, 12 May 2004 02:45:13 -0700
Received: from [192.168.1.17] (helo=scanner01.ims-firmen.de)
	by mailout02.ims-firmen.de with esmtp (Exim 4.30)
	id 1BNqJK-0000w1-PI
	for nfs@lists.sourceforge.net; Wed, 12 May 2004 11:45:58 +0200
Received: from [212.80.225.22] (helo=mschroen)
	by scanner01.ims-firmen.de with esmtp (Exim 4.30)
	id 1BNqIW-0005JH-R9
	for nfs@lists.sourceforge.net; Wed, 12 May 2004 11:45:08 +0200
To: <nfs@lists.sourceforge.net>
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

Hello NFS Friends,

i work since longtime a go with NFS in version v2 and v3
so that i can say it works fine.

In my current Project i will copy a local File to many NFS Shares on
Process.

Some time it's possible that any of the NFS Storages are down but not
dismounted
so my copy process are hanging thats not really good.
The same Process hast to notify or to continue his work ...

I have try "intr" mount Parameter and an alarm to the running Process
but it will not work. A open("FILE",O_NONBLOCK) are hanging around, too.


So can you tell me a method to workaround or to reanimate the
hanging Process for return of some errorstate  ?


Best Regreats

Mario Schroen




-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
