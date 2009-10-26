From: Chuck Lever <chuck.lever@oracle.com>
Subject: mount.nfs in latest nfs-utils doesn't build
Date: Mon, 26 Oct 2009 16:56:01 -0400
Message-ID: <45A199A9-CC1A-4A9B-BA2B-382BA06FCD18@oracle.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux-NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:40552 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbZJZU5E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Oct 2009 16:57:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 1d1f7016 added --enable-mountconfig, which defaults off, but  
building nfs-utils without it fails.

Making all in mount
libtool: link: gcc -Wall -Wstrict-prototypes -pipe -g -Wextra -fpie - 
D_FILE_OFFSET_BITS=64 -D _FORTIFY_SOURCE=2 -pie -o mount.nfs mount.o  
error.o network.o fstab.o token.o parse_opt.o parse_dev.o nfsmount.o  
nfs4mount.o stropts.o nfsumount.o  ../../support/nfs/libnfs.a ../../ 
support/export/libexport.a
network.o: In function `nfs_probe_nfsport':
/home/cel/src/nfs-utils/main/utils/mount/network.c:620: undefined  
reference to `config_default_proto'
/home/cel/src/nfs-utils/main/utils/mount/network.c:620: undefined  
reference to `config_default_proto'
stropts.o: In function `nfs_validate_options':
/home/cel/src/nfs-utils/main/utils/mount/stropts.c:291: undefined  
reference to `config_default_vers'
/home/cel/src/nfs-utils/main/utils/mount/stropts.c:292: undefined  
reference to `config_default_vers'
/home/cel/src/nfs-utils/main/utils/mount/stropts.c:293: undefined  
reference to `config_default_vers'
collect2: ld returned 1 exit status
make[2]: *** [mount.nfs] Error 1
make[1]: *** [all-recursive] Error 1
make: *** [all-recursive] Error 1
[cel@matisse nfs-utils]$

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



