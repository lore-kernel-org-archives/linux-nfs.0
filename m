Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:35824 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983Ab3JJVpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 17:45:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1VUO2a-0006Bc-5j
	for linux-nfs@vger.kernel.org; Thu, 10 Oct 2013 23:45:04 +0200
Received: from 216.200.161.146.available.above.net ([216.200.161.146.available.above.net])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2013 23:45:04 +0200
Received: from mlei by 216.200.161.146.available.above.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2013 23:45:04 +0200
To: linux-nfs@vger.kernel.org
From: Ming Lei <mlei@riverbed.com>
Subject: nfs4.1  pseudo filesystem
Date: Thu, 10 Oct 2013 21:39:38 +0000 (UTC)
Message-ID: <loom.20131010T232229-437@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


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

