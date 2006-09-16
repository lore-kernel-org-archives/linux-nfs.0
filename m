From: Volker Eckert <volkere@cs.tu-berlin.de>
Subject: exporting UDF medium
Date: Sat, 16 Sep 2006 20:36:36 +0200
Message-ID: <65a4d3a049c6fe88fcb53d6cbaf0e2fe@cs.tu-berlin.de>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GOsIr-0002pe-Sf
	for nfs@lists.sourceforge.net; Sun, 17 Sep 2006 01:47:05 -0700
Received: from mail.cs.tu-berlin.de ([130.149.17.13])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GOsIq-0000ti-4w
	for nfs@lists.sourceforge.net; Sun, 17 Sep 2006 01:47:06 -0700
Received: from mailhost.cs.tu-berlin.de (mail.cs.tu-berlin.de [130.149.17.13])
	by mail.cs.tu-berlin.de (8.9.3p2/8.9.3) with ESMTP id KAA24134
	for <nfs@lists.sourceforge.net>; Sun, 17 Sep 2006 10:46:57 +0200 (MEST)
Received: from localhost (localhost [127.0.0.1])
	by mailhost.cs.tu-berlin.de (Postfix) with ESMTP id 1693CF215
	for <nfs@lists.sourceforge.net>; Sun, 17 Sep 2006 10:46:57 +0200 (MEST)
Received: from mailhost.cs.tu-berlin.de ([127.0.0.1])
	by localhost (mail.cs.tu-berlin.de [127.0.0.1]) (amavisd-new,
	port 10224) with ESMTP id 28378-17 for <nfs@lists.sourceforge.net>;
	Sun, 17 Sep 2006 10:46:55 +0200 (MEST) 15723
Received: from [192.168.1.8] (p54BD5467.dip.t-dialin.net [84.189.84.103])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested) (Authenticated sender: volkere)
	by mailhost.cs.tu-berlin.de (Postfix) with ESMTP
	for <nfs@lists.sourceforge.net>; Sun, 17 Sep 2006 10:46:55 +0200 (MEST)
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

hello,

i'm having trouble exporting my DVD-RAM media (i get 'permission 
denied'). searched groups and www to no avail so far. any help/info 
would be very appreciated.

exporting system is:
debian 3.1, kernel: vanilla 2.6.8-2 i686, nfs utils ver 1.0.6, kernel 
server same (i guess - how do i find out?)

/etc/exports:
/media/dvdram \
192.168.1.8(insecure,rw,async,wdelay,no_subtree_check,nohide) \
192.168.1.5(insecure,rw,async,wdelay,no_subtree_check,nohide)
/media  \
192.168.1.8(insecure,rw,async,wdelay,no_subtree_check,nohide) \
192.168.1.5(insecure,rw,async,wdelay,no_subtree_check,nohide)


server logs:
/var/log/messages only reports 'authenticated mount requests', like 
this one:
Sep 16 19:56:52 localhost rpc.mountd: authenticated mount request from 
192.168.1.5:868 for /media/dvdram (/media/dvdram)


client systems are:
mac os 10.3.9 and ubuntu (dapper), both can mount /home from the same 
server just fine, both can write into the directory when medium is not 
mounted.

* mac client, mounting /media: looks like at first it succeeds but then 
i see
'Sep 16 20:22:13 ruhr kernel: nfs server 192.168.1.4:/media: not 
responding'
in the client logs
trying to mount /media/dvdram i instantly get 'permission denied'

* ubuntu client, trying to mount both  /media/dvdram and /media: at 
first: dito, but every operation i try on the mounted directory (like 
ls) times out. /var/log/messages tells me 'lockd cannot be contacted, 
lockd cannot monitor 192.168.1.4'

i'm wondering why lockd can't be contacted (it's running but not using 
any port, though - guess it's contacted through the portmapper, right?)

disabled the firewall (netfilter): no rules, policy accept, same 
problem.

i used to get some 'getfh failed' messages on the server last week, but 
when i tried to reproduce the problem today, they disappeared.

permissions:
/media/dvdram belongs to uid 0 gid 501, permissions are: drwxrwx--x 
both unmounted and mounted

/media is same, except that it is world-readable when /media/dvdram is 
mounted as opposed to not being world-readble when /media/dvdram isn't

users on the clients are 1001:501

medium is UDF, local users on the server (same uid/gid as on the 
clients) can do both, mount and write to the medium


so, how do i go about solving the problem?
thanks in advance, best regards,
volker.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
