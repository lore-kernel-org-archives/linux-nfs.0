From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: rpc.statd is not running but is required
Date: Mon, 2 May 2011 00:59:01 -0700 (PDT)
Message-ID: <846668.33333.qm@web111707.mail.gq1.yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: nfs <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nm17-vm4.bullet.mail.ne1.yahoo.com ([98.138.91.177]:28100 "HELO
	nm17-vm4.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753978Ab1EBIFE convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 04:05:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I have setup NFS and I checked every thing with documents and manual.
After the client boots up, it says:
=A0
=A0
mount.nfs: rpc.statd is not running but is required for remote locking.
mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
mountall: mount /opt [1000] terminated with status 32
=A0
and I can not see the shared folder.
my hosts.allow file contains:
=A0
=A0
portmap: 192.168.1.0/255.255.255.0
lockd: 192.168.1.0/255.255.255.0
rqoutad: 192.168.1.0/255.255.255.0
mountd: 192.168.1.0/255.255.255.0
=A0
=A0
also /etc/exports contain:
/opt=A0=A0=A0=A0=A0=A0=A0 192.168.1.0/255.255.255.0(rw,no_subtree_check=
,sync,no_root_squash)
=A0
=A0
Any idea about that? What does '-o loop' mean?
