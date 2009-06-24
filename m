From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Missing xtab entry after nfsd startup
Date: Wed, 24 Jun 2009 13:59:51 +0530
Message-ID: <4A41E3FF.4060303@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from saturn.datasyncintra.net ([208.88.241.29]:51110 "EHLO
	saturn.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbZFXIfO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2009 04:35:14 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by saturn.datasyncintra.net (Postfix) with ESMTP id 25BC6690CCD
	for <linux-nfs@vger.kernel.org>; Wed, 24 Jun 2009 03:28:37 -0500 (CDT)
Received: from saturn.datasyncintra.net ([127.0.0.1])
	by localhost (saturn.datasyncintra.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bvzIu0BYdVk2 for <linux-nfs@vger.kernel.org>;
	Wed, 24 Jun 2009 03:28:36 -0500 (CDT)
Received: from [192.168.1.90] (unknown [220.224.228.188])
	(Authenticated sender: shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org)
	by saturn.datasyncintra.net (Postfix) with ESMTP id 0714D313A64
	for <linux-nfs@vger.kernel.org>; Wed, 24 Jun 2009 03:28:35 -0500 (CDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

I am running into a "Permission denied" at the client when I try to
do a mount of an exported directory.

Looking at the HOWTO, I see that there seems to be some inconsistency
as the entries for the export are missing from the /var/lib/nfs/xtab.

For eg:

On the Server:
[root@192 shehjart]# cat /etc/exports
/data/shehjart/volumes/disk1    *(rw,no_root_squash)
[root@192 shehjart]# /etc/init.d/nfs start
Starting NFS services:                                     [  OK  ]
Starting NFS quotas:                                       [  OK  ]
Starting NFS daemon:                                       [  OK  ]
Starting NFS mountd:                                       [  OK  ]
[root@192 shehjart]# cat  /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
[root@192 shehjart]# cat /var/lib/nfs/xtab
[root@192 shehjart]#

On the client, after the above commands:
root@indus:~# mount 192.168.1.201:/data/shehjart/volumes/disk1 /mnt/
mount.nfs: 192.168.1.201:/data/shehjart/volumes/disk1 failed, reason 
given by server: Permission denied

After this failed mount, the server says:
[root@192 shehjart]# cat  /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/data/shehjart/volumes/disk1 
*(rw,no_root_squash,sync,wdelay,no_subtree_check)
[root@192 shehjart]# cat /var/lib/nfs/xtab
[root@192 shehjart]#

even with:
[root@192 shehjart]# exportfs -ra
[root@192 shehjart]# cat /var/lib/nfs/xtab
[root@192 shehjart]#

And the "Permission denied" persists.

tshark shows that the MNT request fails because the
server returns a MNT3ERR_ACCES.

Server is:
[root@192 shehjart]# uname -a
Linux n1 2.6.18-128.1.10.el5xen #1 SMP Thu May 7 11:07:18 EDT 2009 
x86_64 x86_64 x86_64 GNU/Linux

Client is a debian testing:
Linux indus 2.6.18-5-amd64 #1 SMP Thu May 31 23:51:05 UTC 2007 x86_64 
GNU/Linux

Thanks
Shehjar
