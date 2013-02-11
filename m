Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipo2-out.fzu.cz ([147.231.27.21]:51932 "EHLO ipo2-out.fzu.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754209Ab3BKPkY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 10:40:24 -0500
Received: from [195.113.134.197] (hotgeorge.cesnet.cz [195.113.134.197])
	by freja.fzu.cz (Postfix) with ESMTPSA id AE1873DA82
	for <linux-nfs@vger.kernel.org>; Mon, 11 Feb 2013 16:30:27 +0100 (CET)
Message-ID: <51190E62.5090304@gmail.com>
Date: Mon, 11 Feb 2013 16:29:38 +0100
From: Jiri Horky <jiri.horky@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFSv4 server ignores local filesystem's POSIX ACL
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

we use NFSv4 with Kerberos and a custom idmap mapping plugin. The 
mapping is configured in a way that all principals that are not 
explicitly defined are mapped to nobody/nogroup on a server. Recently, 
the kerberos infrastructure within our organization expanded by 
crossrealming with other parties which should not be allowed to use our 
NFSv4 mounts.
It is my understanding that everybody who is able to authenticate 
against the used kerberos infrastructure can mount the filesystems but 
nonauthorized users will be mapped to user nobody/nogroup and according 
to server's filesystem rights can do other actions. Now, I would like to 
set deny ACL for user nobody to the server's /exports directory to 
restrict nobody user access. But it seems this ACL is ignored. In fact, 
local POSIX ACL's on any directory seems to ignored:

SERVER:
root@store4 /exports # mkdir local_tmp
root@store4 /exports # chmod 777 local_tmp/
root@store4 /exports # setfacl -m u:nobody:--- /exports/local_tmp/
root@store4 /exports # getfacl /exports/local_tmp/
getfacl: Removing leading '/' from absolute path names
# file: exports/local_tmp/
# owner: root
# group: root
user::rwx
user:nobody:---
group::rwx
mask::rwx
other::rwx
root@store4 /exports # su nobody -c "touch /exports/local_tmp/filelocal"
touch: cannot touch `/exports/local_tmp/filelocal': Permission denied

so far so good, now on a client:

CLIENT:
metex-1:~# mount -t nfs4 -o sec=krb5 store4.du1.cesnet.cz:/ /mnt
metex-1:~# touch /mnt/local_tmp/a
metex-1:~# ls -l /mnt/local_tmp/a
-rw-r--r-- 1 nobody nogroup 0 Feb 11 15:23 /mnt/local_tmp/a

and on the SERVER again:
root@store4 /exports # ls -l /exports/local_tmp/a
-rw-r--r-- 1 nobody nogroup 0 Feb 11 15:23 /exports/local_tmp/a

So the ACL is ignored when accessing through NFS. Is it the expected 
behavior and I am just doing something terribly wrong?

Some more info about server:

root@store4 /exports # cat /etc/exports
/exports 
*(sec=krb5:krb5i:krb5p,rw,fsid=0,sync,no_subtree_check,no_root_squash,insecure,crossmnt)
root@store4 /exports # uname -a
Linux fe4 2.6.32.59-0.7.1.du2-default #1 SMP 2012-07-13 15:50:56 +0200 
x86_64 x86_64 x86_64 GNU/Linux
OS is: SLES 11 SP1

root@store4 /exports # modinfo nfsd
filename: /lib/modules/2.6.32.59-0.7.1.du2-default/kernel/fs/nfsd/nfsd.ko
license:        GPL
author:         Olaf Kirch <okir@monad.swb.de>
srcversion:     74D3604622B7912E7C96E03
depends:        auth_rpcgss,sunrpc,lockd,exportfs,nfs_acl
supported:      yes
vermagic:       2.6.32.59-0.7.1.du2-default SMP mod_unload modversions

Our intention is  simply to force nobody users out of our NFS servers.

Regards
Jiri Horky

