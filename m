Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B182EC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:08:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 86B8C21927
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:08:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391560AbfBOQIL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:08:11 -0500
Received: from mx1.redhat.com ([209.132.183.28]:32880 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728911AbfBOQIL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:08:11 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2807C7AEBE;
        Fri, 15 Feb 2019 16:08:11 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E19F7600C5;
        Fri, 15 Feb 2019 16:08:06 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 06/27] containers,
 vfs: Allow syscall dirfd arguments to take a container fd
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:08:06 +0000
Message-ID: <155024688620.21651.16013251077091180213.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 15 Feb 2019 16:08:11 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Some filesystem system calls, such as mkdirat(), take a 'directory fd' to
specify the pathwalk origin.  This takes either AT_FDCWD or a file
descriptor that refers to an open directory.

Make it possible to supply a container fd, as obtained from
container_create(), instead thereby specifying the container's root as the
origin.  This performs the filesystem operation into the container's mount
namespace.  For example:

	int cfd = container_create("fred", CONTAINER_NEW_MNT_NS, 0);
	mkdirat(cfd, "/fred", 0755);

A better way to do this might be to temporarily override current->fs and
current->nsproxy, but this requires splitting those fields so that procfs
doesn't see the override.

A sequence number and lock are available to protect the root pointer in
case container_chroot() and/or container_pivot_root() are implemented.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namei.c |   45 ++++++++++++++++++++++++++++++++++-----------
 1 file changed, 34 insertions(+), 11 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a85deb55d0c9..4932b5467285 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2232,20 +2232,43 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
 		if (!f.file)
 			return ERR_PTR(-EBADF);
 
-		dentry = f.file->f_path.dentry;
+		if (is_container_file(f.file)) {
+			struct container *c = f.file->private_data;
+			unsigned seq;
 
-		if (*s && unlikely(!d_can_lookup(dentry))) {
-			fdput(f);
-			return ERR_PTR(-ENOTDIR);
-		}
+			if (!*s)
+				return ERR_PTR(-EINVAL);
 
-		nd->path = f.file->f_path;
-		if (flags & LOOKUP_RCU) {
-			nd->inode = nd->path.dentry->d_inode;
-			nd->seq = read_seqcount_begin(&nd->path.dentry->d_seq);
+			if (flags & LOOKUP_RCU) {
+				do {
+					seq = read_seqcount_begin(&c->seq);
+					nd->path = c->root;
+					nd->inode = nd->path.dentry->d_inode;
+					nd->seq = __read_seqcount_begin(&nd->path.dentry->d_seq);
+				} while (read_seqcount_retry(&c->seq, seq));
+			} else {
+				spin_lock(&c->lock);
+				nd->path = c->root;
+				path_get(&nd->path);
+				spin_unlock(&c->lock);
+				nd->inode = nd->path.dentry->d_inode;
+			}
 		} else {
-			path_get(&nd->path);
-			nd->inode = nd->path.dentry->d_inode;
+			dentry = f.file->f_path.dentry;
+
+			if (*s && unlikely(!d_can_lookup(dentry))) {
+				fdput(f);
+				return ERR_PTR(-ENOTDIR);
+			}
+
+			nd->path = f.file->f_path;
+			if (flags & LOOKUP_RCU) {
+				nd->inode = nd->path.dentry->d_inode;
+				nd->seq = read_seqcount_begin(&nd->path.dentry->d_seq);
+			} else {
+				path_get(&nd->path);
+				nd->inode = nd->path.dentry->d_inode;
+			}
 		}
 		fdput(f);
 		return s;

