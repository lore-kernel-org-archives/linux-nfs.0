From: Steve Dickson <SteveD@redhat.com>
Subject: Re: mount.nfs in latest nfs-utils doesn't build
Date: Tue, 27 Oct 2009 15:41:37 -0400
Message-ID: <4AE74CF1.8080003@RedHat.com>
References: <45A199A9-CC1A-4A9B-BA2B-382BA06FCD18@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753186AbZJ0Tlv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Oct 2009 15:41:51 -0400
In-Reply-To: <45A199A9-CC1A-4A9B-BA2B-382BA06FCD18@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/26/2009 04:56 PM, Chuck Lever wrote:
> Commit 1d1f7016 added --enable-mountconfig, which defaults off, but
> building nfs-utils without it fails.
Sorry about that..... that patch is upcoming....

steved.

> 
> Making all in mount
> libtool: link: gcc -Wall -Wstrict-prototypes -pipe -g -Wextra -fpie
> -D_FILE_OFFSET_BITS=64 -D _FORTIFY_SOURCE=2 -pie -o mount.nfs mount.o
> error.o network.o fstab.o token.o parse_opt.o parse_dev.o nfsmount.o
> nfs4mount.o stropts.o nfsumount.o  ../../support/nfs/libnfs.a
> ../../support/export/libexport.a
> network.o: In function `nfs_probe_nfsport':
> /home/cel/src/nfs-utils/main/utils/mount/network.c:620: undefined
> reference to `config_default_proto'
> /home/cel/src/nfs-utils/main/utils/mount/network.c:620: undefined
> reference to `config_default_proto'
> stropts.o: In function `nfs_validate_options':
> /home/cel/src/nfs-utils/main/utils/mount/stropts.c:291: undefined
> reference to `config_default_vers'
> /home/cel/src/nfs-utils/main/utils/mount/stropts.c:292: undefined
> reference to `config_default_vers'
> /home/cel/src/nfs-utils/main/utils/mount/stropts.c:293: undefined
> reference to `config_default_vers'
> collect2: ld returned 1 exit status
> make[2]: *** [mount.nfs] Error 1
> make[1]: *** [all-recursive] Error 1
> make: *** [all-recursive] Error 1
> [cel@matisse nfs-utils]$
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
