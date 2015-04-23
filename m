Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966430AbbDWQzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2015 12:55:43 -0400
Message-ID: <5539240E.1060205@RedHat.com>
Date: Thu, 23 Apr 2015 12:55:42 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Natanael Copa <ncopa@alpinelinux.org>,
        libtirpc-devel@lists.sourceforge.net
CC: linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH 0/9] Cleanups and fixes for musl libc
References: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/16/2014 03:28 AM, Natanael Copa wrote:
> Various fixes for making libtirpc build and run with musl libc.
> 
> I have also included some cleanups that I did while at it.
> 
> Natanael Copa (9):
>   Replace INSTALL symlink with a copy of the file
>   Provide getrpcbynumber and getrpcbyname if those are missing
>   Avoid use of internal glibc sys/cdefs.h header
>   Add configure option to disable DES authentication
>   Fix compile error: 'IPPORT_RESERVED' undeclared
>   Define struct rpcent on non GNU libc
>   Include string.h for memset
>   Fix location of various standard header includes
>   Add a HACKING file which tells where to send patches
All 9 patches committed... 

steved.

> 
>  HACKING               |   2 +
>  INSTALL               | 371 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  configure.ac          |  12 +-
>  src/Makefile.am       |  12 +-
>  src/auth_des.c        |   2 -
>  src/auth_none.c       |   1 -
>  src/auth_time.c       |   5 +-
>  src/auth_unix.c       |   1 -
>  src/authdes_prot.c    |   1 -
>  src/authgss_prot.c    |   1 +
>  src/authunix_prot.c   |   1 -
>  src/bindresvport.c    |   2 +-
>  src/clnt_bcast.c      |   3 +-
>  src/clnt_dg.c         |   2 +-
>  src/clnt_generic.c    |   2 +-
>  src/clnt_perror.c     |   3 -
>  src/clnt_simple.c     |   1 -
>  src/clnt_vc.c         |   2 +-
>  src/crypt_client.c    |   1 -
>  src/des_crypt.c       |   1 -
>  src/getnetconfig.c    |   1 -
>  src/getnetpath.c      |   2 -
>  src/getpeereid.c      |   1 -
>  src/getpublickey.c    |   3 -
>  src/getrpcent.c       |  10 +-
>  src/key_call.c        |   3 +-
>  src/key_prot_xdr.c    |   1 -
>  src/mt_misc.c         |   1 -
>  src/pmap_clnt.c       |   1 -
>  src/pmap_getmaps.c    |   1 -
>  src/pmap_rmt.c        |   2 +-
>  src/rpc_com.h         |   9 +-
>  src/rpc_generic.c     |   1 -
>  src/rpc_soc.c         |   2 +
>  src/rpcb_st_xdr.c     |   1 -
>  src/rpcdname.c        |   1 -
>  src/svc.c             |   2 +-
>  src/svc_dg.c          |   1 -
>  src/svc_simple.c      |   1 -
>  src/svc_vc.c          |   3 +-
>  src/xdr.c             |   1 -
>  src/xdr_array.c       |   1 -
>  src/xdr_float.c       |   1 -
>  src/xdr_mem.c         |   1 -
>  src/xdr_rec.c         |   2 -
>  src/xdr_reference.c   |   2 -
>  src/xdr_sizeof.c      |   1 -
>  src/xdr_stdio.c       |   1 -
>  tirpc/netconfig.h     |   8 +-
>  tirpc/rpc/auth.h      |  89 ++++++++----
>  tirpc/rpc/auth_des.h  |  16 ++-
>  tirpc/rpc/auth_gss.h  |  47 +++----
>  tirpc/rpc/auth_unix.h |   9 +-
>  tirpc/rpc/clnt.h      |  57 ++++++--
>  tirpc/rpc/clnt_soc.h  |  33 +++--
>  tirpc/rpc/des_crypt.h |  25 +++-
>  tirpc/rpc/nettype.h   |   8 +-
>  tirpc/rpc/pmap_clnt.h |   9 +-
>  tirpc/rpc/pmap_prot.h |   9 +-
>  tirpc/rpc/pmap_rmt.h  |   9 +-
>  tirpc/rpc/rpc.h       |  18 ++-
>  tirpc/rpc/rpc_com.h   |   9 +-
>  tirpc/rpc/rpc_msg.h   |   8 +-
>  tirpc/rpc/rpcb_clnt.h |   8 +-
>  tirpc/rpc/rpcent.h    |  14 +-
>  tirpc/rpc/svc.h       |  65 ++++++---
>  tirpc/rpc/svc_auth.h  |   8 +-
>  tirpc/rpc/svc_soc.h   |  49 +++++--
>  tirpc/rpc/xdr.h       |  17 ++-
>  69 files changed, 784 insertions(+), 214 deletions(-)
>  create mode 100644 HACKING
>  mode change 120000 => 100644 INSTALL
> 
