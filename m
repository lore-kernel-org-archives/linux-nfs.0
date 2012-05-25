Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758628Ab2EYWKD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 May 2012 18:10:03 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q4PMA2ap005731
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 25 May 2012 18:10:02 -0400
From: Simo Sorce <simo@redhat.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism for nfsd
Date: Fri, 25 May 2012 18:09:52 -0400
Message-Id: <1337983796-26476-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset implements a new upcall mechanism that uses the sunrpc
client to talk to gssproxy[1], a new userspace daemon that handles gssapi
operations on behalf of other processes on the system.

The main driver for this new mechanism is to overcome limitations with
the current daemon and upcall. The current code cannot handle tickets
larger than approximatively 2k and cannot handle sending back large user
credential sets to the kernel.

These patches have been tested against the development version of gssproxy
tagged as kernel_v0.1 in the master repo[2].

I have tested walking into mountpoints using tickets artificially pumped
up to 64k and the user is properly authorized, after the accept_se_context
call is performed through the new upcall mechanism and gssproxy.

The gssproxy has the potential of handling also init_sec_context calls,
but at the moment the only targeted system is nfsd.

Simo.

[1] https://fedorahosted.org/gss-proxy/
[2] http://git.fedorahosted.org/git/?p=gss-proxy.git;a=shortlog;h=refs/tags/kernel_v0.1


NOTE: Included are all changes request and agreed on the list recently,
      kmalloc changes and containers compatibility changes.
      Pacthes rebased on top of Bruce Field's for-3.5 tree.


Simo Sorce (4):
  SUNRPC: conditionally return endtime from import_sec_context
  SUNRPC: Document a bit RPCGSS handling in the NFS Server
  SUNRPC: Add RPC based upcall mechanism for RPCGSS auth
  SUNRPC: Use gssproxy upcall for nfsd's RPCGSS authentication.

 Documentation/filesystems/nfs/00-INDEX         |    2 +
 Documentation/filesystems/nfs/knfsd-rpcgss.txt |   65 ++
 include/linux/sunrpc/auth_gss.h                |    3 +
 include/linux/sunrpc/gss_api.h                 |    2 +
 include/linux/sunrpc/svcauth_gss.h             |    2 +-
 net/sunrpc/auth_gss/Makefile                   |    4 +-
 net/sunrpc/auth_gss/auth_gss.c                 |   11 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c            |    3 +
 net/sunrpc/auth_gss/gss_mech_switch.c          |    5 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c           |  353 +++++++++
 net/sunrpc/auth_gss/gss_rpc_upcall.h           |   43 ++
 net/sunrpc/auth_gss/gss_rpc_xdr.c              |  907 ++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_rpc_xdr.h              |  269 +++++++
 net/sunrpc/auth_gss/svcauth_gss.c              |  226 ++++++-
 14 files changed, 1875 insertions(+), 20 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/knfsd-rpcgss.txt
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.h
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.h

-- 
1.7.7.6

