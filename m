Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37112 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbdG0IAG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jul 2017 04:00:06 -0400
Received: by mail-pg0-f67.google.com with SMTP id k190so4029797pgk.4
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 01:00:06 -0700 (PDT)
From: ChunYu Wang <chunyu.wang.1995@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: ChunYu Wang <chunyu.wang.1995@gmail.com>
Subject: [PATCH] rpcdebug: Add proper free() to avoid memory leak
Date: Thu, 27 Jul 2017 03:59:24 -0400
Message-Id: <1501142364-14033-1-git-send-email-chunyu.wang.1995@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcdebug.c use char* cdename to store program name:

    cdename = malloc(strlen(basename(argv[0])));
    strcpy(cdename, basename(argv[0]));

It is better to free before exit to avoid potential leaks.

Signed-off-by: ChunYu Wang <chunyu.wang.1995@gmail.com>
---
 tools/rpcdebug/rpcdebug.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
index 68206cc..722ab4d 100644
--- a/tools/rpcdebug/rpcdebug.c
+++ b/tools/rpcdebug/rpcdebug.c
@@ -131,6 +131,7 @@ main(int argc, char **argv)
 	        print_flags(stdout, module, ~(unsigned int) 0, 1);
 	}
 
+	free(cdename);
 	return 0;
 }
 
@@ -221,6 +222,7 @@ find_flag(char **module, char *name)
 				"please specify the module name using\n"
 				"the -m option.\n",
 				cdename, name);
+			free(cdename);
 			exit(1);
 		}
 		value = flagmap[i].value;
@@ -238,6 +240,7 @@ find_flag(char **module, char *name)
 			fprintf(stderr,
 				"%s: unknown flag %s\n",
 				cdename, name);
+		free(cdename);
 		exit(1);
 	}
 
@@ -255,10 +258,12 @@ get_flags(char *module)
 
 	if ((sysfd = open(filename, O_RDONLY)) < 0) {
 		perror(filename);
+		free(cdename);
 		exit(1);
 	}
 	if ((len = read(sysfd, buffer, sizeof(buffer))) < 0) {
 		perror("read");
+		free(cdename);
 		exit(1);
 	}
 	close(sysfd);
@@ -278,14 +283,17 @@ set_flags(char *module, unsigned int value)
 	len = sprintf(buffer, "%d", value);
 	if ((sysfd = open(filename, O_WRONLY)) < 0) {
 		perror(filename);
+		free(cdename);
 		exit(1);
 	}
 	if ((ret = write(sysfd, buffer, len)) < 0) {
 		perror("write");
+		free(cdename);
 		exit(1);
 	}
 	if (ret < len) {
 		fprintf(stderr, "error: short write in set_flags!\n");
+		free(cdename);
 		exit(1);
 	}
 	close(sysfd);
@@ -359,6 +367,7 @@ usage(int excode, char *module)
 	  else
 	    fprintf(stderr, "       (use %s -vh to get a list of modules and valid flags)\n", cdename);
 	}
+	free(cdename);
 	exit (excode);
 }
 
-- 
2.1.4

