Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab0JKAEO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:04:14 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:04:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/15] mountd: Clear mountd registrations at start up
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:04:11 -0400
Message-ID: <20101011000411.6667.17979.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clear stale MNT registrations before mountd tries to create fresh
listeners, to ensure that mountd starts.  This is also what statd
does.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/mountd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index d309950..7e0cf6a 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -840,6 +840,7 @@ main(int argc, char **argv)
 	if (new_cache)
 		cache_open();
 
+	unregister_services();
 	if (version2()) {
 		listeners += nfs_svc_create("mountd", MOUNTPROG,
 					MOUNTVERS, mount_dispatch, port);

