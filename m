Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754487Ab3GAPct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 11:32:49 -0400
From: Jan Stancek <jstancek@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@redhat.com, Trond.Myklebust@netapp.com
Subject: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
Date: Mon,  1 Jul 2013 17:32:34 +0200
Message-Id: <682ebd8ecc7309b18396da356a0feb38bfa41674.1372692346.git.jstancek@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Starting with commit:
  commit f994c43d19a9116727d4c228d3f13db595bff562
  Author: Trond Myklebust <Trond.Myklebust@netapp.com>
  Date:   Thu Nov 1 12:14:14 2012 -0400
      SUNRPC: Clean up rpc_bind_new_program

operations on directory mounted with -onfsvers=3,tcp,sec=krb5 fail
with Input/Output error after ~60 second timeout. This is presumably
because upcalls for 'nfsacl' are not getting anywhere.

This patch enables pipe dir for nfsacl_program and changes its name
to 'nfs'. This name will be used in upcalls and whole setup should
work as it did in past - just with nfs/hostname principal.

Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 fs/nfs/nfs3client.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index b3fc65e..09a7d06 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -9,11 +9,12 @@ static const struct rpc_version *nfsacl_version[] = {
 };
 
 const struct rpc_program nfsacl_program = {
-	.name			= "nfsacl",
+	.name			= "nfs",
 	.number			= NFS_ACL_PROGRAM,
 	.nrvers			= ARRAY_SIZE(nfsacl_version),
 	.version		= nfsacl_version,
 	.stats			= &nfsacl_rpcstat,
+	.pipe_dir_name		= NFS_PIPE_DIRNAME,
 };
 
 /*
-- 
1.7.1

