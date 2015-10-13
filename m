Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.236.176]:34656 "EHLO
	dot.freshdot.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbbJMM1Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 08:27:16 -0400
Date: Tue, 13 Oct 2015 14:21:28 +0200
From: Sander Smeenk <ssmeenk@freshdot.net>
To: linux-nfs@vger.kernel.org
Subject: CAP(abilities) and NFS mounted storage
Message-ID: <20151013122128.GD10632@dot.dmz.freshdot.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm struggling with a permission issue involving NFS-mounted storage and
a certain set of capabilities set by cap_set_flags(). The behaviour
differs for local storage versus NFS mounted storage.

I have this structure on local storage (spinning disks):
| # namei -l /opt/home/sites/t/test/dir/structure/.htaccess
| f: /opt/home/sites/t/test/dir/structure/.htaccess
| drwxr-xr-x root      root                 /
| drwxr-xr-x root      root                 opt
| drwxr-x--x root      root                 home
| drwx--x--x root      root                 sites
| drwx--x--x root      root                 t
| drwx------ http-test http-linux_http-test test
| drwx--x--x http-test http-linux_http-test dir
| drwx------ http-test http-linux_http-test structure
| -rw------- http-test http-linux_http-test .htaccess

And this same structure on NFS-mounted storage:
| # namei -l /mnt/home/sites/t/test/dir/structure/.htaccess
| f: /mnt/home/sites/t/test/dir/structure/.htaccess
| drwxr-xr-x root      root                 /
| drwxr-xr-x root      root                 mnt
| drwxr-x--x root      root                 home
| drwx--x--x root      root                 sites
| drwx--x--x root      root                 t
| drwx------ http-test http-linux_http-test test
| drwx--x--x http-test http-linux_http-test dir
| drwx------ http-test http-linux_http-test structure
| -rw------- http-test http-linux_http-test .htaccess

The NFS server is a NetApp filer (-sec=sys,rw=clientip,root=clientip).
I tried this with a Linux server too (rw,no_root_squash,no_subtree_check).
The client is always a Linux machine (rw,vers=3,tcp,bg).

I made a little C program to illustrate the issue. It drops privileges
to www-data and tries to access the file specified with a certain set of
capabilties[*].

This works for local storage, fails on NFS:

LOCAL:
| # ./capset /opt/home/sites/t/test/dir/structure/.htaccess
| euid:33 uid:33 egid:33 gid:33
| Process capabilities: = cap_dac_read_search,cap_setgid,cap_setuid,cap_sys_nice+ep;
| Access: success!

NFS:
| # ./capset /mnt/home/sites/t/test/dir/structure/.htaccess
| euid:33 uid:33 egid:33 gid:33
| Process capabilities: = cap_dac_read_search,cap_setgid,cap_setuid,cap_sys_nice+ep;
| Access: error (13): Permission denied

The source for capset can be seen pasted at https://8n1.org/10831/12f0
Lines >=42

I've experimented with different capabilties, but CAP_DAC_OVERRIDE is
not enough. I'd very much like to hear if it is possible for this to
work on NFS like it does on local storage.

Any ideas? 

Thanks in advance.
-Sndr.

[*] This issue popped up since Apache module 'mpm_itk' started using
libcap capabilties to further enhance the security. The capabilties set
was taken from mpm_itk source to 'prove the point' w/o the entire Apache
setup. 
-- 
| I wish i was a glow worm, a glow worm's never glum.
| How can you be unhappy when the sun shines out your bum!
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
