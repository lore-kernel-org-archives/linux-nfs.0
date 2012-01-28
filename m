Return-Path: linux-nfs-owner@vger.kernel.org
Received: from c2beaomr07.btconnect.com ([213.123.26.185]:10264 "EHLO
	mail.btconnect.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751454Ab2A1S3b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jan 2012 13:29:31 -0500
From: luxInteg <lux-integ@btconnect.com>
To: linux-nfs@vger.kernel.org
Subject: heimdal-1.5.2,ibrpcsecgss,nfs-utils-1.2.5,
Date: Sat, 28 Jan 2012 18:28:41 +0000
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Message-Id: <201201281828.41620.lux-integ@btconnect.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings,

I am new to this list. I am trying to compile nfs-utils-1.2.5 to work with 
heimdal-1.5.2.   My computer has these:-
--cpu: amd64 2 cores
--OS cblfs (linux) pure 64 bit gcc-4.5.2 kernel-3.2.1, heimdal-1.5.2

My list of programs/and build sequence is as follows:-

 --1--heimdal-1.5.2
 --2--libevent2
 --3--libnfsidmap
 --4--libgssapi  (skipped )
 --5--libgssglue (skipped )
 --6--librpcsecgss
 --7--nfs-utils-1.2.5


I have done this before for MITKerberos where those labelled skipped are used
I  compiled --6-- ( librpcsecgss-0.19 ) with
GSSGLUE_CFLAGS="-I/path/to/heimdal/include/gssapi" \
GSSGLUE_LIBS="lgssapi" \

And it compiles without complaints.




I then passed the same envars GSSGLUE_CFLAGS and GSSGLUE_LIBS to the configure 
script of 
nfs-utils-1.2.5.  However the configure scripts ends with this:-
--------------
checking for nfs4_set_debug in -lnfsidmap... (cached) yes
checking for nfs4_owner_to_uid in -lnfsidmap... (cached) yes
checking spkm3.h usability... no
checking spkm3.h presence... no
checking for spkm3.h... no
configure: WARNING: Could not locate SPKM3 header; will not have SPKM3 support
checking for Kerberos v5... /usr/local
The current KRBDIR is /usr/local
checking for gss_krb5_export_lucid_sec_context in -lgssapi... yes
checking for gss_krb5_set_allowable_enctypes in -lgssapi... yes
checking for gss_krb5_ccache_name in -lgssapi... yes
checking for krb5_get_error_message in -lgssapi... yes
checking for krb5_get_init_creds_opt_set_addressless in -lgssapi... yes
checking for authgss_create_default in -lrpcsecgss... no
configure: error: librpcsecgss not found.
-------------------

I do not know what 'authgss_create_default'  is nor  what file/nor files are 
used to create it. I looked  through the source archive  of  librpcsecgss-0.19 
and I do not see any 'obvious' single file that produces   
"authgss_create_default".   The file-list is below:-  

source files:-

        librpcsecgss-0.19/src/auth_gss.c
        librpcsecgss-0.19/src/authgss_prot.c
        librpcsecgss-0.19/src/clnt_generic.c
        librpcsecgss-0.19/src/clnt_perror.c
        librpcsecgss-0.19/src/clnt_raw.c
        librpcsecgss-0.19/src/clnt_simple.c
        librpcsecgss-0.19/src/clnt_tcp.c
        librpcsecgss-0.19/src/clnt_udp.c
        librpcsecgss-0.19/src/rpc_commondata.c
        librpcsecgss-0.19/src/svc.c
        librpcsecgss-0.19/src/svc_auth.c
        librpcsecgss-0.19/src/svc_auth_gss.c
        librpcsecgss-0.19/src/svc_auth_none.c
        librpcsecgss-0.19/src/svc_auth_unix.c
        librpcsecgss-0.19/src/svc_raw.c
        librpcsecgss-0.19/src/svc_run.c
        librpcsecgss-0.19/src/svc_simple.c
        librpcsecgss-0.19/src/svc_tcp.c
        librpcsecgss-0.19/src/svc_udp.c


headers


        librpcsecgss-0.19/include/rpcsecgss/rpc/auth.h
        librpcsecgss-0.19/include/rpcsecgss/rpc/auth_gss.h
        librpcsecgss-0.19/include/rpcsecgss/rpc/rpc.h
        librpcsecgss-0.19/include/rpcsecgss/rpc/rpcsecgss_rename.h
        librpcsecgss-0.19/include/rpcsecgss/rpc/svc.h
        librpcsecgss-0.19/include/rpcsecgss/rpc/svc_auth.h

----------

Accordingly I would be grateful if someone on  list could let me know how to 
compile librpcsecgss-0.19 on top of heimdal-1.5.2  so that the library 
'librpcsecgss.{so,a}'  has the   "authgss_create_default"  utility
thus enabling the compilation of nfs-utils-1.2.5  thereafter.

yours sincerely
luxInteg
