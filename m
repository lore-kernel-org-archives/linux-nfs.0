From: Jean-Denis Girard <jd.girard@sysnux.pf>
Subject: Server not working since 2.6.20-rc
Date: Tue, 20 Feb 2007 13:29:11 -1000
Message-ID: <45DB8447.1060903@sysnux.pf>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJeU0-0004wO-OA
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 15:33:16 -0800
Received: from smtpq.mana.pf ([202.3.225.153] ident=mirapoint)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJeU1-0000X0-3u
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 15:33:18 -0800
Received: from smtp.mana.pf (smtp.mana.pf [202.3.225.22])
	by smtpq.mana.pf (MOS 3.7.2-GA) with ESMTP id AJH57981
	for <nfs@lists.sourceforge.net>;
	Tue, 20 Feb 2007 13:30:43 -1000 (HST)
Received: from tiare.sysnux.pf (121.90.90.202.dsl.dyn.mana.pf [202.90.90.121])
	by smtp.mana.pf (MOS 3.7.2-GA) with ESMTP id BAG52366
	for <nfs@lists.sourceforge.net>;
	Tue, 20 Feb 2007 13:29:11 -1000 (HST)
Received: from [127.0.0.1] (tiare.sysnux.pf [127.0.0.1])
	by tiare.sysnux.pf (Postfix) with ESMTP id 3D0CD1263
	for <nfs@lists.sourceforge.net>; Tue, 20 Feb 2007 13:29:11 -1000 (TAHT)
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

Hi list,

I have an LTSP environment, which is working fine with kernels before =

2.6.20 series. I think I started to test with 2.6.20-rc3, up to latest =

2.6.20.1, but mounting nfs shares from the clients fails with =

"permission denied". If I reboot server to 2.6.19.x without changing =

configuration, it works again.

When I try to mount /home from my laptop (with kernel 2.6.20), I get the =

well known message:
	mount: tiare.sysnux.pf:/home failed, reason given by server: Permission =

denied

But, on the server I have:
[jdg@tiare ~]$ cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/home =

192.168.10.0/255.255.255.0(rw,insecure,root_squash,sync,wdelay,no_subtree_c=
heck,insecure_locks)

Client and server are based on Mandriva 2007. Server is 64 bits SMP. =

nfs-utils has been updated to 1.0.10. I can provide more details if needed.

I think I have done all checks recommended in the troubleshooting =

section of the nfs-howto. Any help would be greatly appreciated.


Thanks,
-- =

Jean-Denis Girard

SysNux                  Syst=E8mes Linux en Polyn=E9sie fran=E7aise
http://www.sysnux.pf/   T=E9l: +689 483 527 / GSM: +689 797 527

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
