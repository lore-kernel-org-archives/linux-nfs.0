From: miah <jjohnson@sunrise-linux.com>
Subject: Problems building nfs-utils 0.3.3
Date: Sat, 13 Apr 2002 07:40:01 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020413074001.A6404@server.sunrise-linux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [198.78.66.27] (helo=server.sunrise-linux.com)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16wOh4-0006SV-00
	for <nfs@lists.sourceforge.net>; Sat, 13 Apr 2002 07:39:58 -0700
Received: (from miah@localhost)
	by server.sunrise-linux.com (8.11.6/8.11.6) id g3DEe1P07301
	for nfs@lists.sourceforge.net; Sat, 13 Apr 2002 07:40:01 -0700 (PDT)
	(envelope-from miah)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi all,

I'm not really sure why, but nfs-utils has stopped compiling for us.  If we had the time to fully look into this issue we would.  I tried the latest cvs version, but that appears to have the same problem too.  Attached is our build log, if anybody can shed some light on this, we'd appreciate it.

Thanks
-miah

--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="build.log"

Script started on Sat Apr 13 19:33:24 2002
sh-2.05a$ ./configure
creating cache ./config.cache
checking for gcc... gcc
checking whether the C compiler (gcc  ) works... yes
checking whether the C compiler (gcc  ) is a cross-compiler... no
checking whether we are using GNU C... yes
checking whether gcc accepts -g... yes
checking how to run the C preprocessor... gcc -E
checking for a BSD compatible install... /usr/bin/install -c
checking host system type... i686-pc-linux-gnu
checking build system type... i686-pc-linux-gnu
checking for ranlib... ranlib
checking for ar... ar
checking for ld... ld
checking for ANSI C header files... yes
checking for GNU libc2... yes
checking for main in -lsocket... no
checking for main in -lnsl... yes
checking for crypt in -lcrypt... yes
checking for the tcp wrapper library... yes
checking for innetgr... yes
updating cache ./config.cache
creating ./config.status
creating config.mk
creating nfs-utils.spec
creating utils/Makefile
creating support/include/config.h
sh-2.05a$ make
Making all in tools
Making all in rpcgen
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_clntout.o rpc_clntout.c
rpc_clntout.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_cout.o rpc_cout.c
rpc_cout.c: In function `print_header':
rpc_cout.c:160: warning: unused variable `i'
rpc_cout.c:159: warning: unused variable `ptr'
rpc_cout.c:158: warning: unused variable `dl'
rpc_cout.c: At top level:
rpc_cout.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_hout.o rpc_hout.c
rpc_hout.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_main.o rpc_main.c
rpc_main.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_parse.o rpc_parse.c
rpc_parse.c: In function `def_union':
rpc_parse.c:291: warning: unused variable `tcase'
rpc_parse.c: At top level:
rpc_parse.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_scan.o rpc_scan.c
rpc_scan.c: In function `findstrconst':
rpc_scan.c:308: warning: value computed is not used
rpc_scan.c: In function `findchrconst':
rpc_scan.c:329: warning: value computed is not used
rpc_scan.c: At top level:
rpc_scan.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_svcout.o rpc_svcout.c
rpc_svcout.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_tblout.o rpc_tblout.c
rpc_tblout.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_util.o rpc_util.c
rpc_util.c:32: warning: `sccsid' defined but not used
gcc -O2 -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpc_sample.o rpc_sample.c
rpc_sample.c:32: warning: `sccsid' defined but not used
gcc  -L../../support/lib -o rpcgen rpc_clntout.o rpc_cout.o rpc_hout.o rpc_main.o rpc_parse.o rpc_scan.o rpc_svcout.o rpc_tblout.o rpc_util.o rpc_sample.o 
Building rpcgen done.
if [ ! -d ../../bin ]; then \
  rm -rf ../../bin; mkdir -p ../../bin; \
fi
cp rpcgen ../../bin
Making all in getiversion
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o getiversion.o getiversion.c
gcc  -L../../support/lib -o getiversion getiversion.o 
Building getiversion done.
Making all in getkversion
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o getkversion.o getkversion.c
gcc  -L../../support/lib -o getkversion getkversion.o 
Building getkversion done.
Making all in rpcdebug
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpcdebug.o rpcdebug.c
rpcdebug.c:256: warning: `find_sysname' defined but not used
gcc  -L../../support/lib -o rpcdebug rpcdebug.o 
Building rpcdebug done.
Making all in locktest
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o testlk.o testlk.c
gcc  -L../../support/lib -o testlk testlk.o 
Building testlk done.
Making all in support
Making all in include
ln -sf ../export/mount.h .
Making all in nfs
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o exports.o exports.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rmtab.o rmtab.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o xio.o xio.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpcmisc.o rpcmisc.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rpcdispatch.o rpcdispatch.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o xlog.o xlog.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o xmalloc.o xmalloc.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o wildmat.o wildmat.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o nfssvc.o nfssvc.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o nfsclient.o nfsclient.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o nfsexport.o nfsexport.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o getfh.o getfh.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o nfsctl.o nfsctl.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o lockdsvc.o lockdsvc.c
ar cr libnfs.a exports.o rmtab.o xio.o rpcmisc.o rpcdispatch.o xlog.o xmalloc.o wildmat.o nfssvc.o nfsclient.o nfsexport.o getfh.o nfsctl.o lockdsvc.o
ranlib libnfs.a
Building libnfs.a done.
Making all in export
rm -f mount.h mount_clnt.c mount_xdr.c
../../bin/rpcgen -h -o mount.h mount.x
cannot find any C preprocessor (cpp)
../../bin/rpcgen -l -o mount_clnt.c mount.x
cannot find any C preprocessor (cpp)
../../bin/rpcgen -c -o mount_xdr.c mount.x
cannot find any C preprocessor (cpp)
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o mount_clnt.o mount_clnt.c
mount_clnt.c:9: warning: `TIMEOUT' defined but not used
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o mount_xdr.o mount_xdr.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o client.o client.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o export.o export.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o hostname.o hostname.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o nfsctl.o nfsctl.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o rmtab.o rmtab.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o xtab.o xtab.c
ar cr libexport.a mount_clnt.o mount_xdr.o client.o export.o hostname.o nfsctl.o rmtab.o xtab.o
ranlib libexport.a
Building libexport.a done.
Making all in lib
ln -sf ../nfs/libnfs.a .
ln -sf ../export/libexport.a .
ln -sf ../misc/libmisc.a .
Making all in misc
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o tcpwrapper.o tcpwrapper.c
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o from_local.o from_local.c
from_local.c:39: warning: `sccsid' defined but not used
ar cr libmisc.a tcpwrapper.o from_local.o
ranlib libmisc.a
Building libmisc.a done.
Making all in utils
Making all in exportfs
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o exportfs.o exportfs.c
gcc  -L../../support/lib -o exportfs exportfs.o -lexport -lnfs
Building exportfs done.
Making all in mountd
gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include -Wall  -pipe  -DVERSION="\"nfs-utils 0.3.3\"" -DNFS3_SUPPORTED   -c -o mountd.o mountd.c
In file included from mountd.c:24:
mountd.h:19: parse error before `dirpath'
mountd.h:19: warning: no semicolon at end of struct or union
mountd.h:23: parse error before `fhstatus'
mountd.h:23: warning: no semicolon at end of struct or union
mountd.h:24: warning: type defaults to `int' in declaration of `mountlist'
mountd.h:24: warning: data definition has no type or storage class
mountd.h:25: parse error before `exports'
mountd.h:25: warning: type defaults to `int' in declaration of `exports'
mountd.h:25: warning: data definition has no type or storage class
mountd.h:32: parse error before `dirpath'
mountd.h:33: parse error before `mountlist'
mountd.h:34: parse error before `dirpath'
mountd.h:36: parse error before `exports'
mountd.h:37: parse error before `exports'
mountd.h:38: parse error before `dirpath'
mountd.h:39: parse error before `dirpath'
mountd.h:51: parse error before `mountlist_list'
mountd.h:51: warning: type defaults to `int' in declaration of `mountlist_list'
mountd.h:51: warning: data definition has no type or storage class
mountd.c:28: parse error before `get_exportlist'
mountd.c:28: warning: type defaults to `int' in declaration of `get_exportlist'
mountd.c:28: warning: data definition has no type or storage class
mountd.c:29: parse error before `dirpath'
mountd.c: In function `killer':
mountd.c:55: `MOUNTPROG' undeclared (first use in this function)
mountd.c:55: (Each undeclared identifier is reported only once
mountd.c:55: for each function it appears in.)
mountd.c:55: `MOUNTVERS' undeclared (first use in this function)
mountd.c:57: `MOUNTVERS_POSIX' undeclared (first use in this function)
mountd.c:59: `MOUNTVERS_NFSV3' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:70: parse error before `dirpath'
mountd.c: In function `mount_mnt_1_svc':
mountd.c:74: `path' undeclared (first use in this function)
mountd.c:75: `rqstp' undeclared (first use in this function)
mountd.c:75: `res' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:81: parse error before `mountlist'
mountd.c: In function `mount_dump_1_svc':
mountd.c:84: `rqstp' undeclared (first use in this function)
mountd.c:88: `res' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:93: parse error before `dirpath'
mountd.c: In function `mount_umnt_1_svc':
mountd.c:96: `rqstp' undeclared (first use in this function)
mountd.c:98: `argp' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:128: parse error before `exports'
mountd.c: In function `mount_export_1_svc':
mountd.c:131: `rqstp' undeclared (first use in this function)
mountd.c:134: `resp' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:139: parse error before `exports'
mountd.c: In function `mount_exportall_1_svc':
mountd.c:142: `rqstp' undeclared (first use in this function)
mountd.c:145: `resp' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:161: parse error before `dirpath'
mountd.c: In function `mount_pathconf_2_svc':
mountd.c:164: `rqstp' undeclared (first use in this function)
mountd.c:168: `path' undeclared (first use in this function)
mountd.c:170: `res' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:215: parse error before `dirpath'
mountd.c: In function `mount_mnt_3_svc':
mountd.c:220: `path' undeclared (first use in this function)
mountd.c:221: `rqstp' undeclared (first use in this function)
mountd.c:221: `res' undeclared (first use in this function)
mountd.c:224: dereferencing pointer to incomplete type
mountd.c:225: dereferencing pointer to incomplete type
mountd.c:226: dereferencing pointer to incomplete type
mountd.c:227: dereferencing pointer to incomplete type
mountd.c: At top level:
mountd.c:233: parse error before `dirpath'
mountd.c: In function `get_rootfh':
mountd.c:236: `rqstp' undeclared (first use in this function)
mountd.c:240: `path' undeclared (first use in this function)
mountd.c:256: `error' undeclared (first use in this function)
mountd.c:275: `v3' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:299: parse error before `get_exportlist'
mountd.c:300: warning: return-type defaults to `int'
mountd.c: In function `get_exportlist':
mountd.c:301: syntax error before `elist'
mountd.c:307: `elist' undeclared (first use in this function)
mountd.c:311: dereferencing pointer to incomplete type
mountd.c:312: dereferencing pointer to incomplete type
mountd.c:313: dereferencing pointer to incomplete type
mountd.c:314: dereferencing pointer to incomplete type
mountd.c:317: dereferencing pointer to incomplete type
mountd.c:324: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:329: dereferencing pointer to incomplete type
mountd.c:330: dereferencing pointer to incomplete type
mountd.c:331: dereferencing pointer to incomplete type
mountd.c:332: dereferencing pointer to incomplete type
mountd.c:338: dereferencing pointer to incomplete type
mountd.c:339: dereferencing pointer to incomplete type
mountd.c:340: dereferencing pointer to incomplete type
mountd.c:341: dereferencing pointer to incomplete type
mountd.c:344: dereferencing pointer to incomplete type
mountd.c:348: dereferencing pointer to incomplete type
mountd.c:351: dereferencing pointer to incomplete type
mountd.c:353: dereferencing pointer to incomplete type
mountd.c:354: dereferencing pointer to incomplete type
mountd.c:357: dereferencing pointer to incomplete type
mountd.c:358: dereferencing pointer to incomplete type
mountd.c:367: dereferencing pointer to incomplete type
mountd.c:372: dereferencing pointer to incomplete type
mountd.c:372: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:378: dereferencing pointer to incomplete type
mountd.c:379: dereferencing pointer to incomplete type
mountd.c:380: dereferencing pointer to incomplete type
mountd.c:380: dereferencing pointer to incomplete type
mountd.c:381: dereferencing pointer to incomplete type
mountd.c:302: warning: `e' might be used uninitialized in this function
mountd.c:302: warning: `ne' might be used uninitialized in this function
mountd.c:303: warning: `g' might be used uninitialized in this function
mountd.c:303: warning: `ng' might be used uninitialized in this function
mountd.c:387: warning: control reaches end of non-void function
mountd.c: In function `main':
mountd.c:488: `MOUNTPROG' undeclared (first use in this function)
mountd.c:488: `MOUNTVERS' undeclared (first use in this function)
mountd.c:491: `MOUNTVERS_POSIX' undeclared (first use in this function)
mountd.c:494: `MOUNTVERS_NFSV3' undeclared (first use in this function)
make[2]: *** [mountd.o] Error 1
make[1]: *** [all] Error 2
make: *** [all] Error 2
sh-2.05a$ exit
exit

Script done on Sat Apr 13 19:35:05 2002

--k+w/mQv8wyuph6w0--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
