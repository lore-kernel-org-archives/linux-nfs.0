Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61945 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754219Ab2JORah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 13:30:37 -0400
Received: from netapp.com (vpn2ntap-358750.hq.netapp.com [10.55.67.32])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q9FHUZCs005698
	for <linux-nfs@vger.kernel.org>; Mon, 15 Oct 2012 10:30:35 -0700 (PDT)
Date: Mon, 15 Oct 2012 12:30:35 -0500
From: "Haynes, Tom" <thomas@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: Testing XDR code for nits
Message-ID: <20121015173035.GA1777@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It used to be when I wanted to test for sanity, I could do:

sudo yum -y install libgssglue-devel
sudo yum -y install nfs-utils-lib-devel

and then:

[thomas@psyklo NFSv4.2]$ make testx

Since about FC15, that has been broken. I can solve this with
another distro, but I'd really like to get it working.

I can't install nfs-utils-lib-devel, I found this bugzilla:

https://bugzilla.redhat.com/show_bug.cgi?id=722847

So I tried installing libtirpc-devel and no luck with the
test:

( cd testx.d ; \
	rpcgen -a nfsv42.x ; \
	if [ ! -f /usr/include/rpc/auth_sys.h ]; then \
		ln Make* make ; \
		CFLAGS="-I /usr/include/rpcsecgss -I /usr/include/gssglue" ; export CFLAGS ; \
		LDLIBS="-lrpcsecgss" ; export LDLIBS ; \
	fi ; \
	make -f make* )
file `nfsv42_server.c' already exists and may be overwritten
make[1]: Entering directory `/home/thomas/Documents/ietf/NFSv4.2/testx.d'
rpcgen  nfsv42.x
cc -I /usr/include/rpcsecgss -I /usr/include/gssglue -g    -c -o nfsv42_clnt.o nfsv42_clnt.c
cc -I /usr/include/rpcsecgss -I /usr/include/gssglue -g    -c -o nfsv42_client.o nfsv42_client.c
cc -I /usr/include/rpcsecgss -I /usr/include/gssglue -g    -c -o nfsv42_xdr.o nfsv42_xdr.c
nfsv42_xdr.c: In function ‘xdr_secinfo4’:
nfsv42_xdr.c:3511:7: error: ‘RPCSEC_GSS’ undeclared (first use in this function)
nfsv42_xdr.c:3511:7: note: each undeclared identifier is reported only once for each function it appears in
nfsv42_xdr.c: In function ‘xdr_callback_sec_parms4’:
nfsv42_xdr.c:3790:7: error: ‘RPCSEC_GSS’ undeclared (first use in this function)
make[1]: *** [nfsv42_xdr.o] Error 1
make[1]: Leaving directory `/home/thomas/Documents/ietf/NFSv4.2/testx.d'
make: *** [testx] Error 2

What package will provide RPCSEC_GSS in a header?

Thanks,


-- 
Tom Haynes - ex-cfb
