Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37292 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab0EZMfm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 08:35:42 -0400
Received: by fxm5 with SMTP id 5so4351016fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 05:35:40 -0700 (PDT)
Message-ID: <4BFD1595.1070502@panasas.com>
Date: Wed, 26 May 2010 15:35:33 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: steved@redhat.com, NFS list <linux-nfs@vger.kernel.org>
CC: "Chen, Helen Y" <hycsw@sandia.gov>
Subject: Fwd: Re: [pnfs] problem building pnfs-nfs-utils under Fedora 13
Content-Type: multipart/mixed;
 boundary="------------080807060901060808080307"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------080807060901060808080307
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit

Helen, please note that the pnfs@linux-nfs.org mailing list was deprecated.
Forwarding to linux-nfs@vger.kernel.org.

>From a quick glance I'm not sure what went wrong with your build,
Steve should know better :-)

Benny

On May. 19, 2010, 20:32 +0300, "Chen, Helen Y" <hycsw@sandia.gov> wrote:



 
Has anyone successfully build pnfs enabled nfs utils under Fedora 13? 
I am running the kernel from:
http://steved.fedorapeople.org/repos/pnfs/13/x86_64/
 
I installed libtirpc{,-devel}, tcp_wrappers{,-devel}, libevent{,-devel},
nfs-utils-lib{,-devel},
libgssglue{,-devel}, libblkid{,-devel}, and libcap{,-devel}
 
per instructions from:
_http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd#Kernel_and_nfs-utils_compilati__on_
<http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd#Kernel_and_nfs-utils_compilation>
 
I used libnfsidmap{,-devel} bundled in:
Nfs-utils-lib-devel-1.1.5-1.fc13.X86_64.rpm
 
Finally, I downloaded _nfs-utils-1.2.2-4.1.pnfs.src.rpm_
<http://steved.fedorapeople.org/repos/pnfs/13/source/nfs-utils-1.2.2-4.1.pnfs.src.rpm>
from _http://steved.fedorapeople.org/repos/pnfs/13/source/_
 
I am having trouble building these utils. I failed to generate
‘configure’ when I ran autogen.sh:
 
/c//leaning up ............. done
//lobotomize//: putting auxiliary files in `.'.
libtoolize: copying file `./ltmain.sh'
libtoolize: putting macros in AC_CONFIG_MACRO_DIR, `aclocal'.
libtoolize: copying file `aclocal/libtool.m4'
libtoolize: copying file `aclocal/ltoptions.m4'
libtoolize: copying file `aclocal/ltsugar.m4'
libtoolize: copying file `aclocal/ltversion.m4'
libtoolize: copying file `aclocal/lt~obsolete.m4'
configure.ac:5: installing `./config.guess'
configure.ac:5: installing `./config.sub'
configure.ac:421: required file `tools/mountstats/Makefile.in' not found
configure.ac:421: required file `tools/nfs-iostat/Makefile.in' not found/
 
I deleted the two Makefile.in requirements from line 421 in configure.ac
because there were only python scripts inside those directories.
 
When I ran the ‘configure’ generated after the modification, it failed
with the following output:
 
/checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether to enable maintainer-specific portions of Makefiles... no
checking for style of include used by make... GNU
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... none needed
checking dependency style of gcc... gcc3
checking how to run the C preprocessor... gcc -E
checking for grep that handles long lines and -e... /bin/grep
checking for egrep... /bin/grep -E
checking for ANSI C header files... no
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... no
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking for clnt_tli_create in -ltirpc... yes
checking /usr/include/tirpc/netconfig.h usability... yes
checking /usr/include/tirpc/netconfig.h presence... yes
checking for /usr/include/tirpc/netconfig.h... yes
checking for prctl... yes
checking for cap_get_proc in -lcap... yes
checking sys/capability.h usability... yes
checking sys/capability.h presence... yes
checking for sys/capability.h... yes
checking for libwrap... /
 
But libwrap is obviously installed based on the locate command:
#locate libwrap
/usr/lib/libwrap.so
/usr/lib/libwrap.so.0
/usr/lib/libwrap.so.0.7.6
/usr/lib64/libwrap.so
/usr/lib64/libwrap.so.0
/usr/lib64/libwrap.so.0.7.6
 
I am new at this and would appreciate any help you can provide.
 
Thanks,
Helen
 
 
 
 
 
 
 
 

--------------080807060901060808080307
Content-Type: text/plain;
 name="Attached Message Part"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="Attached Message Part"

_______________________________________________
NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org
instead.  (To subscribe to linux-nfs@vger.kernel.org: send "subscribe
linux-nfs" in the body of a message to majordomo@vger.kernel.org.)

pNFS mailing list
pNFS@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs

--------------080807060901060808080307--
