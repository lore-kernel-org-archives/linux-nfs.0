From: Shylendra Bhat <shylendra.bhat@hp.com>
Subject: machine hangs - SLES9/NFS
Date: Fri, 02 Jul 2004 08:40:57 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1088737857.3552.21.camel@nt2624.india.hp.com>
Reply-To: shylendra.bhat@hp.com
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BgES9-0002XT-D8
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 20:11:05 -0700
Received: from atlrel7.hp.com ([156.153.255.213])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BgES9-0008OX-1i
	for nfs@lists.sourceforge.net; Thu, 01 Jul 2004 20:11:05 -0700
Received: from iconsrv6.india.hp.com (iconsrv6.india.hp.com [15.42.227.74])
	by atlrel7.hp.com (Postfix) with ESMTP id 530F613B
	for <nfs@lists.sourceforge.net>; Thu,  1 Jul 2004 23:11:02 -0400 (EDT)
Received: from [15.42.226.24] (lx2624.india.hp.com [15.42.226.24])
	by iconsrv6.india.hp.com (8.9.3 (PHNE_29774)/8.9.3 SMKit7.02) with ESMTP id IAA07071
	for <nfs@lists.sourceforge.net>; Fri, 2 Jul 2004 08:41:33 +0530 (IST)
To: nfs@lists.sourceforge.net
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

Hello,

I am looking answers for the following questions.

Is nfs file lock acquired by client, persistent across the nfs server
reboot?
I know that this feature was not there in NFSv3. Does NFSv4 supports
this?

Following is the exercise which I did to test nfs file lock.

I have two machines. One among them is the NFS server running on
SLES9(kernel 2.6.5-7.79). The other machine mounts the NFS exported
filesystem.

I have written a application which locks the files over this nfs mount.

After acquiring the lock, I am restarting the nfs service using
"rcnfsserver restart" command.

After the nfs service restart, the client fails to release the lock and
is in a hung state. If the mount directory is listed, it shows

"bash: cd: /export: Stale NFS file handle"

After this behavior of the client, server stops responding. Only way to
bring back the machine is reboot.

Any help is really appreciated.

Thanks & regards
Shylendra



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
