Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0JKAFO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:05:14 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:05:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/15] mount.nfs: Eliminate compiler warning in
	utils/mount/mount.c
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:05:11 -0400
Message-ID: <20101011000511.6667.76388.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

mount.c: At top level:
mount.c:324: warning: no previous prototype for ‘mount_usage’

mount_usage() has no callers outside of utils/mount/mount.c and no
prototype is provided in a header file.  Make it static.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 82b9169..1c6a88f 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -321,7 +321,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 	return result;
 }
 
-void mount_usage(void)
+static void mount_usage(void)
 {
 	printf(_("usage: %s remotetarget dir [-rvVwfnsih] [-o nfsoptions]\n"),
 		progname);

