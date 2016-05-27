Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41674 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932955AbcE0ROg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2016 13:14:36 -0400
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.7
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
References: <ed695df4-9072-41ae-93b0-8479873333f6@Netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <57488072.6030502@oracle.com>
Date: Fri, 27 May 2016 13:14:26 -0400
MIME-Version: 1.0
In-Reply-To: <ed695df4-9072-41ae-93b0-8479873333f6@Netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/26/2016 11:29 AM, Anna Schumaker wrote:
> Hi Linus,
>
> The following changes since commit 44549e8f5eea4e0a41b487b63e616cb089922b99:
>
>   Linux 4.6-rc7 (2016-05-08 14:38:32 -0700)
>
> are available in the git repository at:
>
>   git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.7-1
>
> for you to fetch changes up to c7d73af2d249f0323f5cdb171a59497ce80011fb:
>
>   pnfs: pnfs_update_layout needs to consider if strict iomode checking is on (2016-05-26 08:40:56 -0400)
>
>
> There are a few merge conflicts that were found in linux-next.  Stephen's suggested resolutions looked okay to us, so I've attached those patches for reference.
>
> Thanks,
> Anna
>
> ----------------------------------------------------------------
...

>
> Trond Myklebust (6):
>       pNFS: Fix a leaked layoutstats flag
>       SUNRPC: Ensure get_rpccred() and put_rpccred() can take NULL arguments
>       NFSv4: Label stateids with the type

This breaks on older compilers:

  CC      fs/nfs/nfs4state.o
/home/build/linux-linus/fs/nfs/nfs4state.c:69: error: unknown field
‘data’ specified in initializer
/home/build/linux-linus/fs/nfs/nfs4state.c:69: warning: missing braces
around initializer
/home/build/linux-linus/fs/nfs/nfs4state.c:69: warning: (near
initialization for ‘zero_stateid.<anonymous>.data’)
make[2]: *** [fs/nfs/nfs4state.o] Error 1
make[1]: *** [fs/nfs/nfs4state.o] Error 2
make[1]: Leaving directory `/home/build/xtt-x86_64/bootstrap/linux-build'
make: *** [sub-make] Error 2
make: Leaving directory `/home/build/linux-linus'
FC-64 <build@build-mk2:~/xtt-x86_64/bootstrap> gcc -v
Using built-in specs.
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man
--infodir=/usr/share/info
--with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap
--enable-shared --enable-threads=posix --enable-checking=release
--with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions
--enable-gnu-unique-object
--enable-languages=c,c++,objc,obj-c++,java,fortran,ada
--enable-java-awt=gtk --disable-dssi
--with-java-home=/usr/lib/jvm/java-1.5.0-gcj-1.5.0.0/jre
--enable-libgcj-multifile --enable-java-maintainer-mode
--with-ecj-jar=/usr/share/java/eclipse-ecj.jar
--disable-libjava-multilib --with-ppl --with-cloog --with-tune=generic
--with-arch_32=i686 --build=x86_64-redhat-linux
Thread model: posix
gcc version 4.4.4 20100503 (Red Hat 4.4.4-2) (GCC)
FC-64 <build@build-mk2:~/xtt-x86_64/bootstrap>


I believe pre-4.6 versions do not allow initialization of anonymous
structs/unions.

-boris




