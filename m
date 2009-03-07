From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] nfs-utils: NULL-terminate buffer after read in read_service_info
Date: Sat,  7 Mar 2009 07:45:27 -0500
Message-ID: <1236429928-4680-3-git-send-email-jlayton@redhat.com>
References: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	chuck.lever@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55531 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754231AbZCGMph (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Mar 2009 07:45:37 -0500
In-Reply-To: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Valgrind complains that we're passing an unintialized buffer to
sscanf here. The main problem seems to be that we're not ensuring
that the buffer is NULL terminated before we pass it off.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d0d3f7f..0ebdfcd 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -133,6 +133,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	if ((nbytes = read(fd, buf, INFOBUFLEN)) == -1)
 		goto fail;
 	close(fd);
+	buf[nbytes] = '\0';
 
 	numfields = sscanf(buf,"RPC server: %127s\n"
 		   "service: %127s %15s version %15s\n"
-- 
1.6.0.6

