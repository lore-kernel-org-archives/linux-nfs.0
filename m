Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0JKAFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:05:53 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:05:53 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/15] mount.nfs: Eliminate compiler warning in
	utils/mount/parse_opt.c
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:05:50 -0400
Message-ID: <20101011000550.6667.58637.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

parse_opt.c: In function ‘po_rightmost’:
parse_opt.c:517: warning: conversion to ‘int’ from ‘unsigned int’ may change the sign of the result

"i" contains the function's result value, so it should be defined as
the same type as the function's return type.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/parse_opt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/parse_opt.c b/utils/mount/parse_opt.c
index f0918f7..ab869d9 100644
--- a/utils/mount/parse_opt.c
+++ b/utils/mount/parse_opt.c
@@ -508,7 +508,7 @@ po_found_t po_get_numeric(struct mount_options *options, char *keyword, long *va
 int po_rightmost(struct mount_options *options, const char *keys[])
 {
 	struct mount_option *option;
-	unsigned int i;
+	int i;
 
 	if (options) {
 		for (option = options->tail; option; option = option->prev) {

