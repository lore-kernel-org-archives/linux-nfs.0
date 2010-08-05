Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sentry-three.sandia.gov ([132.175.109.17]:57869 "EHLO
	sentry-three.sandia.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758873Ab0HEWOI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Aug 2010 18:14:08 -0400
From: "Chen, Helen Y" <hycsw@sandia.gov>
To: "'Daniel.Muntz@emc.com'" <Daniel.Muntz@emc.com>,
        "'bhalevy@panasas.com'" <bhalevy@panasas.com>,
        "'steved@redhat.com'" <steved@redhat.com>,
        "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Date: Thu, 5 Aug 2010 16:13:55 -0600
Subject: Re: pNFS file layout performance
Message-ID: <F9F38212E2D77948B1CD89D239A7C07B138EE2E472@ES01SNLNT.srn.sandia.gov>
In-Reply-To: <DE966DA98A4ABE438D726BDF1699CF61403FB1F2@MX05A.corp.emc.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I believe Benny is right!  I might have forgotten to load the  nfs file layout driver.  I will check on that as soon as I have a chance.   Hopefully I will have good news to report later.

Thanks,
Helen

----- Original Message -----
From: Daniel.Muntz@emc.com [mailto:Daniel.Muntz@emc.com]
Sent: Thursday, August 05, 2010 04:01 PM
To: Chen, Helen Y; bhalevy@panasas.com <bhalevy@panasas.com>; steved@redhat.com <steved@redhat.com>; linux-nfs@vger.kernel.org <linux-nfs@vger.kernel.org>
Subject: RE: pNFS file layout performance

Anything in the logs indicating the MDS couldn't communicate with the DSs?  Beyond that, if the setup is correct, would it be possible to get network traces?  Nothing immediately comes to mind as to why performance would be poor if the data is landing on the MDS.  Otoh, if the data were landing on the DSs and the client was having to resort to proxy I/O, then spNFS performance would probably be poor (proxy I/O is _not_ spNFS's strong suit :-)

  -Dan

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Chen, Helen Y
Sent: Wednesday, August 04, 2010 5:21 PM
To: Chen, Helen Y; 'Benny Halevy'; 'steved@redhat.com'; 'NFS list'
Subject: RE: pNFS file layout performance

I add a 2nd DS and repeated the benchmark.   It had seemed the test data had been placed on the MDS and not the DS'es?  Any idea why?

Thanks,
Helen

The following are my notes on kernel, configuration set up, and results:

I rebuilt Steve's f13 pnfs kernel source with:
# CONFIG_PNFSD_LOCAL_EXPORT is not set


Configuration set up:
Data Server:
/etc/fstab
tmpfs		/export/spnfs		tmpfs	size=85%	0 0

/etc/exports
/export/spnfs	*(rw,sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_squash)


Meta Data Server:
/etc/fstab
wtb9-10g:/	/spnfs/192.168.96.109	nfs4	minorversion=1,intr,soft,rsize=32768,wsiz
e=32768	0 0
wtb10-10g:/	/spnfs/192.168.96.110	nfs4	minorversion=1,intr,soft,rsize=32768,wsiz
e=32768	0 0
wtb11-10g:/	/spnfs/192.168.96.11	nfs4	minorversion=1,intr,soft,rsize=32768,wsiz
e=32768	0 0

/etc/exports
/export	*(rw,sync,pnfs,fsid=0,insecure,no_subtree_check,no_root_squash)

/etc/spnfsd.conf
[General]
Verbosity = 1
Stripe-size = 8192
Dense-striping = 0
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
DS-Mount-Directory = /spnfs

[DataServers]
NumDS = 2
DS1_IP = 192.168.96.109
DS1_PORT = 2049
DS1_ROOT = /
DS1_ID = 1
DS2_IP = 192.168.96.110
DS2_PORT = 2049
DS2_ROOT = /
DS2_ID = 2


pNFS Client:
/etc/fstab
wtb8-10g:/  /mnt nfs4	minorversion=1,tcp,intr,soft,rsize=32768,wsize=32768,timeo=600 0 


The following is one of my benchmark result:
iozone -i 0 -s 1g -r 32k -f /mnt/1g -c -w


1. on Client:
[root@wtb7 pnfs-tests]# ls -l /mnt
total 132100
-rw-r----- 1 root root 1073741824 Aug  4 16:25 1g

2. on MDS
[root@wtb8 ~]# stat /export/1g
  File: `/export/1g'
  Size: 1073741824	Blocks: 264200     IO Block: 4096   regular file
Device: 805h/2053d	Inode: 491522      Links: 1
Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2010-08-04 16:24:48.000000000 -0700
Modify: 2010-08-04 16:25:28.000000000 -0700
Change: 2010-08-04 16:25:28.000000000 -0700

2. on MDS
[root@wtb8 ~]# stat /export/1g
  File: `/export/1g'
  Size: 1073741824	Blocks: 264200     IO Block: 4096   regular file
Device: 805h/2053d	Inode: 491522      Links: 1
Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2010-08-04 16:24:48.000000000 -0700
Modify: 2010-08-04 16:25:28.000000000 -0700
Change: 2010-08-04 16:25:28.000000000 -0700

3. op DS1:
[root@wtb9 ~]# stat /export/spnfs
  File: `/export/spnfs'
  Size: 60        	Blocks: 0          IO Block: 4096   directory
Device: 14h/20d	Inode: 8981        Links: 2
Access: (1777/drwxrwxrwt)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2010-08-04 16:26:49.938720191 -0700
Modify: 2010-08-04 16:58:31.959755618 -0700
Change: 2010-08-04 16:58:31.959755618 -0700

4. on DS2
[root@wtb10 ~]# stat /export/spnfs/
  File: `/export/spnfs/'
  Size: 60        	Blocks: 0          IO Block: 4096   directory
Device: 13h/19d	Inode: 8694        Links: 2
Access: (1777/drwxrwxrwt)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2010-08-04 16:26:54.573669020 -0700
Modify: 2010-08-04 16:58:18.525689302 -0700
Change: 2010-08-04 16:58:18.525689302 -0700



________________________________________
From: Chen, Helen Y
Sent: Wednesday, August 04, 2010 3:59 PM
To: 'Benny Halevy'; 'steved@redhat.com'; 'NFS list'
Subject: RE: pNFS file layout performance

Steve and Benny,

Thank you very much for your help! I have successfully set up a 3-node testbed and ran some benchmark since.  Unfortunately, throughput results are very poor.

I am running Steve's 2.6.33.5-112.2.2.pnfs.fc13.x86_64 kernel, and exported a 28GB ramfs from my DS to the MDS. I was able to achieve ~400 MB/s over NFS using iozone. I then proceed to run the same test from the pNFS client and got only 50 MB/s.  After detecting that my test data had landed on both the MDS and DS, I assumed disk I/O on the MDS was the bottleneck. So I proceeded to rebuild the kernel with CONFIG_PNFSD_LOCAL_EXPORT disabled, but achieved only 6 MB/s afterward. Is this expected, or am I doing something wrong?  Please let me know if I need to provide further information.

Thanks,
Helen

-----Original Message-----
From: Benny Halevy [mailto:bhalevy.lists@gmail.com] On Behalf Of Benny Halevy
Sent: Wednesday, May 26, 2010 5:36 AM
To: steved@redhat.com; NFS list
Cc: Chen, Helen Y
Subject: Fwd: Re: [pnfs] problem building pnfs-nfs-utils under Fedora 13

Helen, please note that the pnfs@linux-nfs.org mailing list was deprecated.
Forwarding to linux-nfs@vger.kernel.org.

>From a quick glance I'm not sure what went wrong with your build, Steve should know better :-)

Benny

On May. 19, 2010, 20:32 +0300, "Chen, Helen Y" <hycsw@sandia.gov> wrote:




Has anyone successfully build pnfs enabled nfs utils under Fedora 13?
I am running the kernel from:
http://steved.fedorapeople.org/repos/pnfs/13/x86_64/

I installed libtirpc{,-devel}, tcp_wrappers{,-devel}, libevent{,-devel}, nfs-utils-lib{,-devel}, libgssglue{,-devel}, libblkid{,-devel}, and libcap{,-devel}

per instructions from:
_http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd#Kernel_and_nfs-utils_compilati__on_
<http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd#Kernel_and_nfs-utils_compilation>

I used libnfsidmap{,-devel} bundled in:
Nfs-utils-lib-devel-1.1.5-1.fc13.X86_64.rpm

Finally, I downloaded _nfs-utils-1.2.2-4.1.pnfs.src.rpm_
<http://steved.fedorapeople.org/repos/pnfs/13/source/nfs-utils-1.2.2-4.1.pnfs.src.rpm>
from _http://steved.fedorapeople.org/repos/pnfs/13/source/_

I am having trouble building these utils. I failed to generate 'configure' when I ran autogen.sh:

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

I deleted the two Makefile.in requirements from line 421 in configure.ac because there were only python scripts inside those directories.

When I ran the 'configure' generated after the modification, it failed with the following output:

/checking build system type... x86_64-unknown-linux-gnu checking host system type... x86_64-unknown-linux-gnu checking for a BSD-compatible install... /usr/bin/install -c checking whether build environment is sane... yes checking for gawk... gawk checking whether make sets $(MAKE)... yes checking whether to enable maintainer-specific portions of Makefiles... no checking for style of include used by make... GNU checking for gcc... gcc checking whether the C compiler works... yes checking for C compiler default output file name... a.out checking for suffix of executables...
checking whether we are cross compiling... no checking for suffix of object files... o checking whether we are using the GNU C compiler... yes checking whether gcc accepts -g... yes checking for gcc option to accept ISO C89... none needed checking dependency style of gcc... gcc3 checking how to run the C preprocessor... gcc -E checking for grep that handles long lines and -e... /bin/grep checking for egrep... /bin/grep -E checking for ANSI C header files... no checking for sys/types.h... yes checking for sys/stat.h... yes checking for stdlib.h... no checking for string.h... yes checking for memory.h... yes checking for strings.h... yes checking for inttypes.h... yes checking for stdint.h... yes checking for unistd.h... yes checking for clnt_tli_create in -ltirpc... yes checking /usr/include/tirpc/netconfig.h usability... yes checking /usr/include/tirpc/netconfig.h presence... yes checking for /usr/include/tirpc/netconfig.h... yes checking for prctl... yes checking for cap_ge!
 t_proc in -lcap... yes checking sys/capability.h usability... yes checking sys/capability.h presence... yes checking for sys/capability.h... yes checking for libwrap... /

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









--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



