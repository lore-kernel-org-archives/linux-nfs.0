Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:56722 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726733AbeHHNzS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Aug 2018 09:55:18 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org, jlayton@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: ensure that writing '+4' to /proc/fs/nfsd/versions enables minor version 0
Date: Wed,  8 Aug 2018 07:36:00 -0400
Message-Id: <20180808113600.11502-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to commit d3635ff07e8 ("nfsd: fix configuration of supported
minor versions"), it should be possible to use either '4.0' or '4' to
enable or disable minor version 0.

Currently, writing '+4' to /proc/fs/nfsd/versions has no effect unless
no minor versions are enabled.  That leaves rpc.nfsd without an easy
way to re-enable v4.0, since that's what it does when invoked with
'-V 4.0'.

Fixes: d3635ff07e8 ("nfsd: fix configuration of supported minor versions")
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfsctl.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d107b4426f7e..b3f9f9233953 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -614,6 +614,14 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 					minor = 0;
 					while (nfsd_minorversion(minor, cmd) >= 0)
 						minor++;
+				} else if (cmd == NFSD_SET) {
+					/*
+					 * We have +4 but there are already some minors
+					 * enabled.  We must ensure 4.0 gets enabled,
+					 * since it could be a request from rpc.nfsd.
+					 */
+					if (nfsd_minorversion(0, cmd) < 0)
+						return -EINVAL;
 				}
 				break;
 			default:
-- 
2.14.4

