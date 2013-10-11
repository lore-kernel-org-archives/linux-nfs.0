Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44653 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755327Ab3JKQaX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Oct 2013 12:30:23 -0400
Date: Fri, 11 Oct 2013 12:30:22 -0400
To: Ming Lei <mlei@riverbed.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4.1  pseudo filesystem
Message-ID: <20131011163022.GA22214@fieldses.org>
References: <loom.20131010T232229-437@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <loom.20131010T232229-437@post.gmane.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 10, 2013 at 09:39:38PM +0000, Ming Lei wrote:
> 
> I want to set up the real directory as the root of the pseudo filesystem 
> got exported from the server.

Unless you have some very good reason, I recommend just ignoring the
pseudo filesystem.  Just export the directories you want to without
using fsid=0 or bind mounts, just as you would with NFSv2/v3.  That will
work fine on any recent server.

--b.

> Can I do it or I have to create /export 
> empty directory as the root of the pseudo FS and then bind the real 
> directories?
> 
> I have this test, both server and client running 3.11.0+:
> 
> On the server, there is /root directory.
> [root@xxx ~] ls /root
> anaconda-ks.cfg  disk    Documents  fs_log.old   install.log.syslog  Public
> Desktop          disk.c  Downloads  install.log  linux3              
> rpmbuild
> [root@xxx ~]# ls /root/Downloads/linux-2.6.39.4
> arch       crypto         firmware  Kconfig      Module.symvers  security
> block      cscope.in.out  fs        kernel       net             sound
> config     cscope.out     include   lib          README          tools
> config-rh  cscope.po.out  init      MAINTAINERS  REPORTING-BUGS  usr
> COPYING    Documentation  ipc       Makefile     samples         virt
> CREDITS    drivers        Kbuild    mm           scripts
> 
> I have this /etc/exports on the server:
> /root *(ro,fsid=0,crossmnt,no_root_squash)
> /root/Downloads/linux-2.6.39.4 *(rw,no_root_squash,nohide)
> /root/linux3/Documentation/filesystems *(rw,no_root_squash,nohide)
> 
> [root@xxx ~]# cat /proc/net/rpc/nfsd.export/content 
> #path domain(flags)
> # /root/.gvfs	*()
> /root	*
> (ro,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,fsid=0,uuid=46bb42
> 56:d3c84b6f:bbbfff3a:8b0d912c)
> [root@xxx ~]# cat /proc/net/rpc/nfsd.fh/content 
> #domain fsidtype fsid [path]
> * 1 0x00000000 /root
> 
> 
> On the client side, what I saw:
> [root@xxx /]# mount -o vers=4.1 10.1.13.66:/ /mnt
> [root@xxx /]# cd /mnt
> [root@xxx mnt]# ls
> anaconda-ks.cfg  disk    Documents  fs_log.old   install.log.syslog  Public
> Desktop          disk.c  Downloads  install.log  linux3              
> rpmbuild
> [root@xxx mnt]# cd Downloads/linux-2.6.39.4
> [root@xxx linux-2.6.39.4]# ls
> arch       COPYING        cscope.out     firmware  ipc      lib          
> Module.symvers  samples   tools
> block      CREDITS        cscope.po.out  fs        Kbuild   MAINTAINERS  
> net             scripts   usr
> config     crypto         Documentation  include   Kconfig  Makefile     
> README          security  virt
> config-rh  cscope.in.out  drivers        init      kernel   mm           
> REPORTING-BUGS  sound
> [root@xxx linux-2.6.39.4]# rm REPORTING-BUGS 
> rm: remove regular file `REPORTING-BUGS'? y
> rm: cannot remove `REPORTING-BUGS': Read-only file system
> 
> The question is:
> Why can I delete this file even I specify the 
> mountpoint /root/Downloads/linux-2.6.39.4 to allow RW access?
> 
> Thanks
> Ming
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
