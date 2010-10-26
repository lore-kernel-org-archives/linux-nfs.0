Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53668 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab0JZP6I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 11:58:08 -0400
Received: by mail-iw0-f174.google.com with SMTP id 10so2336058iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 08:58:08 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] mount: Fix compiler warning in nfs_parse_retry_option()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Oct 2010 11:58:05 -0400
Message-ID: <20101026155805.19184.18299.stgit@matisse.1015granger.net>
In-Reply-To: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

stropts.c: In function ‘nfs_parse_retry_option’:
stropts.c:131: warning: conversion to ‘unsigned int’ from ‘long int’ may alter its value

Make it more clear what the second argument is for, and flag the
switch fallthrough case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index bcc36f3..29b1aaa 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -119,10 +119,12 @@ inline void nfs_default_version(struct nfsmount_info *mi) {}
  * Returns a time_t timeout timestamp, in seconds.
  */
 static time_t nfs_parse_retry_option(struct mount_options *options,
-				     unsigned int timeout_minutes)
+				     const time_t default_timeout)
 {
+	time_t timeout_minutes;
 	long tmp;
 
+	timeout_minutes = default_timeout;
 	switch (po_get_numeric(options, "retry", &tmp)) {
 	case PO_NOT_FOUND:
 		break;
@@ -131,6 +133,7 @@ static time_t nfs_parse_retry_option(struct mount_options *options,
 			timeout_minutes = tmp;
 			break;
 		}
+		/*FALLTHROUGH*/
 	case PO_BAD_VALUE:
 		if (verbose)
 			nfs_error(_("%s: invalid retry timeout was specified; "
@@ -138,7 +141,7 @@ static time_t nfs_parse_retry_option(struct mount_options *options,
 		break;
 	}
 
-	return time(NULL) + (time_t)(timeout_minutes * 60);
+	return time(NULL) + (timeout_minutes * 60);
 }
 
 /*

