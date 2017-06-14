Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33276 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751829AbdFNPSF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:18:05 -0400
Subject: [PATCH 18/27] NFS: Constify mount argument match tables [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:18:02 +0100
Message-ID: <149745348270.10897.9943140662420498741.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The mount argument match tables should never be altered so constify them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/fs_context.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index 3e2fe57b9b07..a41f034aafb2 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -197,7 +197,7 @@ enum {
 	Opt_lookupcache_err
 };
 
-static match_table_t nfs_lookupcache_tokens = {
+static const match_table_t nfs_lookupcache_tokens = {
 	{ Opt_lookupcache_all, "all" },
 	{ Opt_lookupcache_positive, "pos" },
 	{ Opt_lookupcache_positive, "positive" },
@@ -213,7 +213,7 @@ enum {
 	Opt_local_lock_err
 };
 
-static match_table_t nfs_local_lock_tokens = {
+static const match_table_t nfs_local_lock_tokens = {
 	{ Opt_local_lock_all, "all" },
 	{ Opt_local_lock_flock, "flock" },
 	{ Opt_local_lock_posix, "posix" },
@@ -229,7 +229,7 @@ enum {
 	Opt_vers_err
 };
 
-static match_table_t nfs_vers_tokens = {
+static const match_table_t nfs_vers_tokens = {
 	{ Opt_vers_2, "2" },
 	{ Opt_vers_3, "3" },
 	{ Opt_vers_4, "4" },

