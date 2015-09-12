Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34112 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbbILBhb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 21:37:31 -0400
Received: by padhy16 with SMTP id hy16so89348429pad.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 18:37:31 -0700 (PDT)
Subject: [PATCH v2] Sunrpc: Supports hexadecimal number for sysctl files of
 sunrpc debug
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <55F17A7E.50406@gmail.com> <20150911212320.GG11677@fieldses.org>
 <55F38130.7020802@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55F381CE.4070600@gmail.com>
Date: Sat, 12 Sep 2015 09:37:18 +0800
MIME-Version: 1.0
In-Reply-To: <55F38130.7020802@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The sunrpc debug sysctl files only accept decimal number right now.
But all the XXXDBUG_XXX macros are defined as hexadecimal.
It is not easy to set or check an separate flag.

This patch let those files support accepting hexadecimal number,
(decimal number is also supported). Also, display it as hexadecimal.

v2,
Remove duplicate parsing of '0x...', just using simple_strtol(tmpbuf, &s, 0)
Fix a bug of isspace() checking after parsing

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/sysctl.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 887f018..c88d9bc 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -76,7 +76,7 @@ static int
 proc_dodebug(struct ctl_table *table, int write,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	char		tmpbuf[20], c, *s;
+	char		tmpbuf[20], c, *s = NULL;
 	char __user *p;
 	unsigned int	value;
 	size_t		left, len;
@@ -103,23 +103,24 @@ proc_dodebug(struct ctl_table *table, int write,
 			return -EFAULT;
 		tmpbuf[left] = '\0';
 
-		for (s = tmpbuf, value = 0; '0' <= *s && *s <= '9'; s++, left--)
-			value = 10 * value + (*s - '0');
-		if (*s && !isspace(*s))
-			return -EINVAL;
-		while (left && isspace(*s))
-			left--, s++;
+		value = simple_strtol(tmpbuf, &s, 0);
+		if (s) {
+			left -= (s - tmpbuf);
+			if (left && !isspace(*s))
+				return -EINVAL;
+			while (left && isspace(*s))
+				left--, s++;
+		} else
+			left = 0;
 		*(unsigned int *) table->data = value;
 		/* Display the RPC tasks on writing to rpc_debug */
 		if (strcmp(table->procname, "rpc_debug") == 0)
 			rpc_show_tasks(&init_net);
 	} else {
-		if (!access_ok(VERIFY_WRITE, buffer, left))
-			return -EFAULT;
-		len = sprintf(tmpbuf, "%d", *(unsigned int *) table->data);
+		len = sprintf(tmpbuf, "0x%04x", *(unsigned int *) table->data);
 		if (len > left)
 			len = left;
-		if (__copy_to_user(buffer, tmpbuf, len))
+		if (copy_to_user(buffer, tmpbuf, len))
 			return -EFAULT;
 		if ((left -= len) > 0) {
 			if (put_user('\n', (char __user *)buffer + len))
-- 
2.5.0

