Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:7444 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab3JLGmi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Oct 2013 02:42:38 -0400
From: Wangminlan <wangminlan@huawei.com>
To: Ming Lei <mlei@riverbed.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: nfs4.1  pseudo filesystem
Date: Sat, 12 Oct 2013 06:40:24 +0000
Message-ID: <3962238FD7EA0F41B1810E7ABEAFBC314CEF99D0@szxema505-mbs.china.huawei.com>
References: <loom.20131010T232229-437@post.gmane.org>
In-Reply-To: <loom.20131010T232229-437@post.gmane.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Ming,
	I guess the problem here is that the filesystem on "/root", "/root/Downloads/linux-2.6.39.4", and "/root/linux3/Documentation/filesystems" are the same filesystem.
	So when your client tried to access anything within the three directories, they all use the export "/root *(ro,fsid=0,crossmnt,no_root_squash)" to determin their permission.
	Try to mount some other filesystems on your "real" exports, I mean, the exports with fsid other than 0, then do your tests.

B.R
Minlan Wang


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Ming Lei
Sent: Friday, October 11, 2013 5:40 AM
To: linux-nfs@vger.kernel.org
Subject: nfs4.1 pseudo filesystem


I want to set up the real directory as the root of the pseudo filesystem 
got exported from the server. Can I do it or I have to create /export 
empty directory as the root of the pseudo FS and then bind the real 
directories?

I have this test, both server and client running 3.11.0+:

On the server, there is /root directory.
[root@xxx ~] ls /root
anaconda-ks.cfg  disk    Documents  fs_log.old   install.log.syslog  Public
Desktop          disk.c  Downloads  install.log  linux3              
rpmbuild
[root@xxx ~]# ls /root/Downloads/linux-2.6.39.4
arch       crypto         firmware  Kconfig      Module.symvers  security
block      cscope.in.out  fs        kernel       net             sound
config     cscope.out     include   lib          README          tools
config-rh  cscope.po.out  init      MAINTAINERS  REPORTING-BUGS  usr
COPYING    Documentation  ipc       Makefile     samples         virt
CREDITS    drivers        Kbuild    mm           scripts

I have this /etc/exports on the server:
/root *(ro,fsid=0,crossmnt,no_root_squash)
/root/Downloads/linux-2.6.39.4 *(rw,no_root_squash,nohide)
/root/linux3/Documentation/filesystems *(rw,no_root_squash,nohide)

[root@xxx ~]# cat /proc/net/rpc/nfsd.export/content 
#path domain(flags)
# /root/.gvfs	*()
/root	*
(ro,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,fsid=0,uuid=46bb42
56:d3c84b6f:bbbfff3a:8b0d912c)
[root@xxx ~]# cat /proc/net/rpc/nfsd.fh/content 
#domain fsidtype fsid [path]
* 1 0x00000000 /root


On the client side, what I saw:
[root@xxx /]# mount -o vers=4.1 10.1.13.66:/ /mnt
[root@xxx /]# cd /mnt
[root@xxx mnt]# ls
anaconda-ks.cfg  disk    Documents  fs_log.old   install.log.syslog  Public
Desktop          disk.c  Downloads  install.log  linux3              
rpmbuild
[root@xxx mnt]# cd Downloads/linux-2.6.39.4
[root@xxx linux-2.6.39.4]# ls
arch       COPYING        cscope.out     firmware  ipc      lib          
Module.symvers  samples   tools
block      CREDITS        cscope.po.out  fs        Kbuild   MAINTAINERS  
net             scripts   usr
config     crypto         Documentation  include   Kconfig  Makefile     
README          security  virt
config-rh  cscope.in.out  drivers        init      kernel   mm           
REPORTING-BUGS  sound
[root@xxx linux-2.6.39.4]# rm REPORTING-BUGS 
rm: remove regular file `REPORTING-BUGS'? y
rm: cannot remove `REPORTING-BUGS': Read-only file system

The question is:
Why can I delete this file even I specify the 
mountpoint /root/Downloads/linux-2.6.39.4 to allow RW access?

Thanks
Ming

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
