From: ms419@freezone.co.uk
Subject: how to force umount when "Device or resource busy"?
Date: Tue, 14 Sep 2004 12:17:07 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <AB813470-0682-11D9-9080-000A95C71776@freezone.co.uk>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7IpB-0005Wa-Hz
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 12:18:45 -0700
Received: from defout.telus.net ([199.185.220.240] helo=priv-edtnes81.telusplanet.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C7IpA-0002cZ-Lv
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 12:18:45 -0700
Received: from tor.lat ([154.5.5.164]) by priv-edtnes81.telusplanet.net
          (InterMail vM.6.01.03.02 201-2131-111-104-20040324) with ESMTP
          id <20040914191711.WYRV27057.priv-edtnes81.telusplanet.net@tor.lat>
          for <nfs@lists.sourceforge.net>; Tue, 14 Sep 2004 13:17:11 -0600
Received: from [192.168.179.43] (fis.lat [192.168.179.43])
	by tor.lat (Postfix) with ESMTP id 2F5EB11DB0E
	for <nfs@lists.sourceforge.net>; Tue, 14 Sep 2004 12:16:59 -0700 (PDT)
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

How does one unmount when umount doesn't work?

Somehow, I got an NFS / AutoFS mount that just won't unmount.

I noticed /var/autofs/net was mounted twice, so I stopped AutoFS & 
tried killing the remaining automount process. "kill 14986" didn't 
work; I needed "kill -9 14986". The following mounts remain:

wum:~# mount
[...]
automount(pid14986) on /var/autofs/net type autofs 
(rw,fd=5,pgrp=14986,minproto=2,maxproto=4)
tor:/home on /var/autofs/net/tor/home type nfs 
(rw,nosuid,nodev,hard,intr,addr=192.168.103.158)

& I can't unmount them:

wum:~# umount /var/autofs/net/tor/home
umount: /var/autofs/net/tor/home: device is busy
umount: /var/autofs/net/tor/home: device is busy
wum:~# umount -f /var/autofs/net/tor/home
umount2: Device or resource busy
umount: /var/autofs/net/tor/home: Illegal seek
umount2: Device or resource busy
umount: /var/autofs/net/tor/home: device is busy
wum:~# umount /var/autofs/net
umount: /var/autofs/net: device is busy
umount: /var/autofs/net: device is busy
wum:~# umount -f /var/autofs/net
umount2: Device or resource busy
umount: automount(pid14986): not found
umount: /var/autofs/net: Illegal seek
umount2: Device or resource busy
umount: /var/autofs/net: device is busy

I triple checked that no process is using these mounts. How do I 
unmount them?

Thanks!

Jack



-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
