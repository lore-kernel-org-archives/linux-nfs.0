From: Julius <commercials@gmx.net>
Subject: nfs4 with sec=krb5, mount times out
Date: Mon, 26 Jan 2009 19:24:10 +0100
Message-ID: <1232994250.3310.221.camel@wf>
Mime-Version: 1.0
Content-Type: text/plain
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:57704 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751615AbZAZSXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Jan 2009 13:23:40 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,


i can mount my nfsv4 share without kerberos security without
problems.../etc/fstab:

night_crawler.localdomain.de:/music /home/metalfan/nfs4-mount	nfs4	user
0	0


but adding "sec=krb5" to the options list results in:


mount -v nfs4-mount/
mount.nfs4: timeout set for Mon Jan 26 15:44:05 2009
mount.nfs4: text-based options:
'sec=krb5,clientaddr=141.x.x.x,addr=141.x.x.x
mount.nfs4: mount(2): Connection timed out


I read somewhere on the mailing list that only des-cbc-crc is supported
for nfs4, its the only keytype for my user metalfan.
"kinit metalfan" was run before attempting to mount.
i can use gssapi to connect to night_crawlers sshd with my local user,
which also does the nfs4 mount.

krb5-kdc.log and krb5-default.log do not show any connections.
Where do you start troubleshooting?

