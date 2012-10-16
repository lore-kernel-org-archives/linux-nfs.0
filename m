Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754375Ab2JPTVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 15:21:35 -0400
Message-ID: <507DB3BE.3050100@RedHat.com>
Date: Tue, 16 Oct 2012 15:21:34 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Haynes, Tom" <thomas@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Testing XDR code for nits
References: <20121015173035.GA1777@netapp.com> <507C7129.7090609@RedHat.com> <20121016175613.GA14138@netapp.com>
In-Reply-To: <20121016175613.GA14138@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 16/10/12 13:56, Haynes, Tom wrote:
> 
> 
> ( cd testx.d ; \
> 	rpcgen -a nfsv42.x ; \
> 	if [ ! -f /usr/include/rpc/auth_sys.h ]; then \
> 		ln Make* make ; \
> 		CFLAGS="-I /usr/include/rpcsecgss -I /usr/include/gssglue" ; export CFLAGS ; \
> 		LDLIBS="-lrpcsecgss" ; export LDLIBS ; \
> 	fi ; \
> 	make -f make* )
> file `nfsv42_server.c' already exists and may be overwritten
> make[1]: Entering directory `/home/thomas/Documents/ietf/NFSv4.2/testx.d'
> rpcgen  nfsv42.x
> cc -I /usr/include/rpcsecgss -I /usr/include/gssglue -g    -c -o nfsv42_clnt.o nfsv42_clnt.c
> cc -I /usr/include/rpcsecgss -I /usr/include/gssglue -g    -c -o nfsv42_client.o nfsv42_client.c
> cc -I /usr/include/rpcsecgss -I /usr/include/gssglue -g    -c -o nfsv42_xdr.o nfsv42_xdr.c
> nfsv42_xdr.c: In function ‘xdr_secinfo4’:
> nfsv42_xdr.c:3511:7: error: ‘RPCSEC_GSS’ undeclared (first use in this function)
> nfsv42_xdr.c:3511:7: note: each undeclared identifier is reported only once for each function it appears in
> nfsv42_xdr.c: In function ‘xdr_callback_sec_parms4’:
> nfsv42_xdr.c:3790:7: error: ‘RPCSEC_GSS’ undeclared (first use in this function)
> make[1]: *** [nfsv42_xdr.o] Error 1
> make[1]: Leaving directory `/home/thomas/Documents/ietf/NFSv4.2/testx.d'
> make: *** [testx] Error 2
> 
> Whether I look at a FC13 or FC17 system, I see a consistent view of the headers:
> 
> [thomas@psyklo NFSv4.2]$ grep RPCSEC_GSS /usr/include/gss*/*
> grep: /usr/include/gssglue/gssapi: Is a directory
> /usr/include/gssrpc/auth_gss.h:/* RPCSEC_GSS control procedures. */
> /usr/include/gssrpc/auth_gss.h:	RPCSEC_GSS_DATA = 0,
> /usr/include/gssrpc/auth_gss.h:	RPCSEC_GSS_INIT = 1,
> /usr/include/gssrpc/auth_gss.h:	RPCSEC_GSS_CONTINUE_INIT = 2,
> /usr/include/gssrpc/auth_gss.h:	RPCSEC_GSS_DESTROY = 3
> /usr/include/gssrpc/auth_gss.h:/* RPCSEC_GSS services. */
> /usr/include/gssrpc/auth_gss.h:	RPCSEC_GSS_SVC_NONE = 1,
> /usr/include/gssrpc/auth_gss.h:	RPCSEC_GSS_SVC_INTEGRITY = 2,
> /usr/include/gssrpc/auth_gss.h:	RPCSEC_GSS_SVC_PRIVACY = 3
> /usr/include/gssrpc/auth_gss.h:#define RPCSEC_GSS_VERSION	1
> /usr/include/gssrpc/auth_gss.h:/* RPCSEC_GSS security triple. */
> /usr/include/gssrpc/auth_gss.h:	RPCSEC_GSS_SVC_NONE
> /usr/include/gssrpc/auth.h:	 * RPCSEC_GSS errors
> /usr/include/gssrpc/auth.h:	RPCSEC_GSS_CREDPROBLEM = 13,
> /usr/include/gssrpc/auth.h:	RPCSEC_GSS_CTXPROBLEM = 14
> /usr/include/gssrpc/auth.h:#define RPCSEC_GSS	6		/* RPCSEC_GSS */
> /usr/include/gssrpc/rpc.h:#include <gssrpc/auth_gss.h>	/* RPCSEC_GSS */
> /usr/include/gssrpc/svc_auth.h:/* RPCSEC_GSS */
> 
> The difference I finally can see is FC13:
> 
> 
> [thomas@ietf include]$ ls -la /usr/include/rpcsecgss 
> total 20
> drwxr-xr-x    3 root root  4096 Oct 16 11:49 .
> drwxr-xr-x. 134 root root 12288 Oct 16 11:49 ..
> drwxr-xr-x    2 root root  4096 Oct 16 11:49 rpc
> [thomas@ietf include]$ yum provides /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h
> Loaded plugins: presto, refresh-packagekit
> nfs-utils-lib-devel-1.1.5-1.fc13.i686 : Development files for the nfs-utils-lib library
> Repo        : fedora
> Matched from:
> Filename    : /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h
> 
> 
> 
> nfs-utils-lib-devel-1.1.5-1.fc13.i686 : Development files for the nfs-utils-lib library
> Repo        : installed
> Matched from:
> Other       : Provides-match: /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h
> 
> And FC17:
> 
> [thomas@psyklo include]$ ls -la /usr/include/rpcsecgss 
> ls: cannot access /usr/include/rpcsecgss: No such file or directory
> [thomas@psyklo include]$ yum provides /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h
> Loaded plugins: langpacks, presto, refresh-packagekit
> nfs-utils-lib-devel-1.1.5-6.fc17.i686 : Development files for the nfs-utils-lib library
> Repo        : fedora
> Matched from:
> Filename    : /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h
> 
> 
> 
> nfs-utils-lib-devel-1.1.5-6.fc17.x86_64 : Development files for the nfs-utils-lib library
> Repo        : fedora
> Matched from:
> Filename    : /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h
> 
> 
> mas@psyklo include]$ sudo yum -y install nfs-utils-lib-devel
> Loaded plugins: langpacks, presto, refresh-packagekit
> Resolving Dependencies
> --> Running transaction check
> ---> Package nfs-utils-lib-devel.x86_64 0:1.1.5-6.fc17 will be installed
> --> Processing Dependency: librpcsecgss.so.3()(64bit) for package: nfs-utils-lib-devel-1.1.5-6.fc17.x86_64
> Package nfs-utils-lib-1.1.5-6.fc17.x86_64 is obsoleted by libnfsidmap-0.25-3.fc17.x86_64 which is already installed
> --> Finished Dependency Resolution
> Error: Package: nfs-utils-lib-devel-1.1.5-6.fc17.x86_64 (fedora)
>            Requires: librpcsecgss.so.3()(64bit)
>            Available: nfs-utils-lib-1.1.5-6.fc17.x86_64 (fedora)
>                librpcsecgss.so.3()(64bit)
>  You could try using --skip-broken to work around the problem
>  You could try running: rpm -Va --nofiles --nodigest
> [thomas@psyklo include]$ sudo yum -y --skip-broken install nfs-utils-lib-devel
> Loaded plugins: langpacks, presto, refresh-packagekit
> Resolving Dependencies
> --> Running transaction check
> ---> Package nfs-utils-lib-devel.x86_64 0:1.1.5-6.fc17 will be installed
> --> Processing Dependency: librpcsecgss.so.3()(64bit) for package: nfs-utils-lib-devel-1.1.5-6.fc17.x86_64
> Package nfs-utils-lib-1.1.5-6.fc17.x86_64 is obsoleted by libnfsidmap-0.25-3.fc17.x86_64 which is already installed
> 
> Packages skipped because of dependency problems:
>     nfs-utils-lib-devel-1.1.5-6.fc17.x86_64 from fedora
> 
> So it looks like this functionality is no longer provided.
> 
> What is supposed to replace it?
It appears to me that this functionality need to be ported to
use libtirpc and libgssglue... since that's where all he GSS
code now lives... that and the MIT libs... 

steved.


