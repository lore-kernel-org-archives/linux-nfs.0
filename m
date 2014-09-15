Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:36403 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbaIOONY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 10:13:24 -0400
Received: by mail-qc0-f182.google.com with SMTP id c9so2118351qcz.41
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 07:13:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsdcltrack: fix some minor nits in the manpage
Date: Mon, 15 Sep 2014 10:13:17 -0400
Message-Id: <1410790397-20511-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsdcltrack isn't a daemon, and we should make mention of the section
in RFC5661.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/nfsdcltrack/nfsdcltrack.man | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/nfsdcltrack/nfsdcltrack.man b/utils/nfsdcltrack/nfsdcltrack.man
index 69407889df8a..c37c9a8d5813 100644
--- a/utils/nfsdcltrack/nfsdcltrack.man
+++ b/utils/nfsdcltrack/nfsdcltrack.man
@@ -23,12 +23,13 @@ nfsdcltrack [\-d] [\-f] [\-s stable storage dir] <command> <args...>
 .SH "DESCRIPTION"
 .IX Header "DESCRIPTION"
 nfsdcltack is the NFSv4 client tracking callout program. It is not necessary
-to install this daemon on machines that are not acting as NFSv4 servers.
+to install this program on machines that are not acting as NFSv4 servers.
 .PP
 When a network partition is combined with a server reboot, there are
 edge conditions that can cause the server to grant lock reclaims when
 other clients have taken conflicting locks in the interim. A more detailed
-explanation of this issue is described in \s-1RFC\s0 3530, section 8.6.3.
+explanation of this issue is described in \s-1RFC\s0 3530, section 8.6.3
+and in \s-1RFC\s0 5661, section 8.4.3.
 .PP
 In order to prevent these problems, the server must track a small amount
 of per-client information on stable storage. This program provides the
-- 
1.9.3

