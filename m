Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30279 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753126Ab0EZODy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 10:03:54 -0400
Message-ID: <4BFD2A46.8010307@panasas.com>
Date: Wed, 26 May 2010 17:03:50 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: steved@redhat.com, NFS list <linux-nfs@vger.kernel.org>,
        "Chen, Helen Y" <hycsw@sandia.gov>
Subject: Re: Fwd: Re: [pnfs] problem building pnfs-nfs-utils under Fedora
 13
References: <4BFD1595.1070502@panasas.com>
In-Reply-To: <4BFD1595.1070502@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2010 03:35 PM, Benny Halevy wrote:
> Helen, please note that the pnfs@linux-nfs.org mailing list was deprecated.
> Forwarding to linux-nfs@vger.kernel.org.
> 
>>From a quick glance I'm not sure what went wrong with your build,
> Steve should know better :-)
> 
> Benny
> 
> On May. 19, 2010, 20:32 +0300, "Chen, Helen Y" <hycsw@sandia.gov> wrote:
> 
> 
> 
>  
> Has anyone successfully build pnfs enabled nfs utils under Fedora 13? 
> I am running the kernel from:
> http://steved.fedorapeople.org/repos/pnfs/13/x86_64/
>  
> I installed libtirpc{,-devel}, tcp_wrappers{,-devel}, libevent{,-devel},
> nfs-utils-lib{,-devel},
> libgssglue{,-devel}, libblkid{,-devel}, and libcap{,-devel}
>  
> per instructions from:
> _http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd#Kernel_and_nfs-utils_compilati__on_
> <http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd#Kernel_and_nfs-utils_compilation>
>  
> I used libnfsidmap{,-devel} bundled in:
> Nfs-utils-lib-devel-1.1.5-1.fc13.X86_64.rpm
>  
> Finally, I downloaded _nfs-utils-1.2.2-4.1.pnfs.src.rpm_
> <http://steved.fedorapeople.org/repos/pnfs/13/source/nfs-utils-1.2.2-4.1.pnfs.src.rpm>
> from _http://steved.fedorapeople.org/repos/pnfs/13/source/_
>  
> I am having trouble building these utils. I failed to generate
> ‘configure’ when I ran autogen.sh:
>  
> /c//leaning up ............. done
> //lobotomize//: putting auxiliary files in `.'.
> libtoolize: copying file `./ltmain.sh'
> libtoolize: putting macros in AC_CONFIG_MACRO_DIR, `aclocal'.
> libtoolize: copying file `aclocal/libtool.m4'
> libtoolize: copying file `aclocal/ltoptions.m4'
> libtoolize: copying file `aclocal/ltsugar.m4'
> libtoolize: copying file `aclocal/ltversion.m4'
> libtoolize: copying file `aclocal/lt~obsolete.m4'
> configure.ac:5: installing `./config.guess'
> configure.ac:5: installing `./config.sub'
> configure.ac:421: required file `tools/mountstats/Makefile.in' not found
> configure.ac:421: required file `tools/nfs-iostat/Makefile.in' not found/
>  
> I deleted the two Makefile.in requirements from line 421 in configure.ac
> because there were only python scripts inside those directories.
>  
> When I ran the ‘configure’ generated after the modification, it failed
> with the following output:
>  
> /checking build system type... x86_64-unknown-linux-gnu
> checking host system type... x86_64-unknown-linux-gnu
> checking for a BSD-compatible install... /usr/bin/install -c
> checking whether build environment is sane... yes
> checking for gawk... gawk
> checking whether make sets $(MAKE)... yes
> checking whether to enable maintainer-specific portions of Makefiles... no
> checking for style of include used by make... GNU
> checking for gcc... gcc
> checking whether the C compiler works... yes
> checking for C compiler default output file name... a.out
> checking for suffix of executables...
> checking whether we are cross compiling... no
> checking for suffix of object files... o
> checking whether we are using the GNU C compiler... yes
> checking whether gcc accepts -g... yes
> checking for gcc option to accept ISO C89... none needed
> checking dependency style of gcc... gcc3
> checking how to run the C preprocessor... gcc -E
> checking for grep that handles long lines and -e... /bin/grep
> checking for egrep... /bin/grep -E
> checking for ANSI C header files... no
> checking for sys/types.h... yes
> checking for sys/stat.h... yes
> checking for stdlib.h... no
> checking for string.h... yes
> checking for memory.h... yes
> checking for strings.h... yes
> checking for inttypes.h... yes
> checking for stdint.h... yes
> checking for unistd.h... yes
> checking for clnt_tli_create in -ltirpc... yes
> checking /usr/include/tirpc/netconfig.h usability... yes
> checking /usr/include/tirpc/netconfig.h presence... yes
> checking for /usr/include/tirpc/netconfig.h... yes
> checking for prctl... yes
> checking for cap_get_proc in -lcap... yes
> checking sys/capability.h usability... yes
> checking sys/capability.h presence... yes
> checking for sys/capability.h... yes
> checking for libwrap... /
>  
> But libwrap is obviously installed based on the locate command:
> #locate libwrap
> /usr/lib/libwrap.so
> /usr/lib/libwrap.so.0
> /usr/lib/libwrap.so.0.7.6
> /usr/lib64/libwrap.so
> /usr/lib64/libwrap.so.0
> /usr/lib64/libwrap.so.0.7.6
>  

Yes I think I had that to, on FC12 did you also install tcp_wrappers-devel

[What configure does is look for the tcpd.h file.
 So basically you:
 - Look in configure what failed, and analyse what was missing here it was
   "#include <tcpd.h>".
 - yum provides "*/tcpd.h" - will show the tcp_wrappers-devel

 Imagine that stupid me, I attempted to configure without reading the wiki first
 and had about 10 of these, by the time I gut to libwrap it was becoming routine

 RANT: I wish configure would leave the failing code on disk and specify the commands
       I need to do to run the failing test. Or at least save and print the gcc output
       of the failing test, rrrr ...
]

> I am new at this and would appreciate any help you can provide.
>  

So there you have it

> Thanks,
> Helen
>  

Boaz
