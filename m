From: "mrg" <mrg@normailer.com>
Subject: NFS Server problem (kernel > 2.6.5 ?)
Date: Tue, 26 Oct 2004 11:22:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001801c4bb3d$5d670bd0$1203a8c0@utvikling>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMNXD-0005IO-A7
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 02:22:31 -0700
Received: from 628936148.32-4.adsl.nsn.no ([62.89.36.148] helo=mail.normailer.com)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CMNXB-0000aI-FO
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 02:22:31 -0700
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

Hi,

I've had a server running FC2 for a while. I recently upgraded the kernel to
2.6.8.1, and then the NFS server stopped working.
I only get a 'Permission denied' on the client side, but the server writes a
'rpc.mountd: authenticated mount request from ...' in the message log.
I've tried al kinds of kernel options without any luck. I've also tried
2.6.8, 2.6.9-rc4 and 2.6.9, but the only kernel that works is the
2.6.5-1.358 which comes with FC2. However, the client can run both FC2 stock
kernel and 2.6.9 and still connect to the server (when run with kernel
2.6.5-1.358).

Some config info:
/etc/exports:
    /rootfs 192.168.1.0/24(rw,sync,no_root_squash)

/etc/hosts.deny is empty, /etc/hosts.allow: ALL:ALL


Does anybody know what the problem is ?

TIA,
    Geir Rastad



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
