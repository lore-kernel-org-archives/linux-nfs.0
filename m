Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWn5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:43:57 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/13] libtirpc: Closed a number of memory leaks 
Date: Fri,  7 Sep 2018 14:01:38 -0400
Message-Id: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There patches close a number of memory leaks that
were found using a covscan. Most them were in error
recovery code but a few of them were in main line code.


Steve Dickson (13):
  auth_gss.c: resource_leak
  auth_gss.c: buffer_size_warning
  clnt_bcast.c: resource_leak
  clnt_vc.c: resource_leak
  getnetconfig.c: cppcheck_warning
  getnetpath.c: resource_leak
  rpc_generic.c: resource_leak
  rpc_soc.c: resource_leak
  rpc_soc.c: buffer_size_warning
  rpcb_clnt.c: resource_leak
  rtime.c: resource_leak
  svc_generic.c: resource_leak
  svc_simple.c: resource_leak

 src/auth_gss.c     | 3 ++-
 src/clnt_bcast.c   | 1 +
 src/clnt_vc.c      | 2 ++
 src/getnetconfig.c | 2 ++
 src/getnetpath.c   | 1 +
 src/rpc_generic.c  | 1 +
 src/rpc_soc.c      | 8 ++++++--
 src/rpcb_clnt.c    | 1 +
 src/rtime.c        | 1 +
 src/svc_generic.c  | 1 +
 src/svc_simple.c   | 1 +
 11 files changed, 19 insertions(+), 3 deletions(-)

-- 
2.17.1
