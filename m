Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:48531 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728AbaJ2VyZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2014 17:54:25 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: building upstream nfs-utils on EL6 fails
Date: Wed, 29 Oct 2014 17:54:19 -0400
Message-Id: <E823B0AB-32D7-45C5-B5C2-69B165A2CEAC@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

libtool: link: gcc -Wall -Wextra -Wstrict-prototypes -pipe -D_FILE_OFFSET_BITS=64 -Wp,-D_FORTIFY_SOURCE=2 -Os -Wall -Wextra -pedantic -std=c99 -Wformat=2 -Wmissing-include-dirs -Wunused -Wconversion -Wlogical-op -Wmissing-prototypes -Wmissing-declarations -Wstrict-prototypes -Wmissing-noreturn -Wshadow -Wunreachable-code -Winline -Wdisabled-optimization -Wstrict-aliasing=2 -Wstrict-overflow=4 -Wstack-protector -fstrict-aliasing -fstrict-overflow -fexceptions -fstack-protector -fasynchronous-unwind-tables -fpie -pie -o nfsidmap nfsidmap.o  /usr/lib64/libnfsidmap.so -ldl -lkeyutils ../../support/nfs/libnfs.a
nfsidmap.o: In function `key_invalidate':
nfsidmap.c:(.text+0x141): undefined reference to `keyctl_invalidate'
collect2: ld returned 1 exit status
make[2]: *** [nfsidmap] Error 1
make[1]: *** [all-recursive] Error 1
make: *** [all-recursive] Error 1
[cel@dali nfs-utils]$

I think this could be due to

commit 2ae0763a618d30037ebb2520f6292f80d838a440
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Mar 25 10:56:58 2014 -0400

    nfsidmap: Keys need to be invalidated instead of revoked

Probably need to have some autoconf logic to pick which keyctl_
API is available on the build system.

But I’d like to run recent kernels on EL6 systems. It looks like
the current upstream kernel ID mapping interface isn’t compatible
with the EL6 user space (/usr/sbin/nfsidmap).

I see both sets of infrastructure on EL6: nfsidmap is installed
and so is rpc.idmapd. Which one is supposed to be used?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



