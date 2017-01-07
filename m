Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33513 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdAGOqk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 09:46:40 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so2466055pgd.0
        for <linux-nfs@vger.kernel.org>; Sat, 07 Jan 2017 06:46:40 -0800 (PST)
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>, kinglongmee@gmail.com,
        Matthieu Herrb <matthieu.herrb@laas.fr>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] NFSv4.2: Fix file creating with O_EXCL get a bad mode
Message-ID: <a76cec59-f007-5c26-dc26-4cc8a6e4daef@gmail.com>
Date: Sat, 7 Jan 2017 22:45:47 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Acorrding to Matthieu Herrb's test cases, a new created file will
get a bad mode as 0666 (expected 0644) after commit dff25ddb4808
"nfs: add support for the umask attribute".

It is caused by missing check of FATTR4_WORD2_MODE_UMASK
in nfs4_exclusive_attrset.

#include <sys/types.h>
#include <sys/stat.h>
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/*
 * Demonstrate file creation bug on NFS v4 and linux kernel 4.4+
 *
 * mktemp() is used on purpose.
 */
int
main(int argc, char *argv[])
{
	const char *name = argv[1];
	char tmp[] = "./tmpXXXXXXXXXX";
	struct stat buf;
	mode_t expected;
	int fd, i, n = 40;

	umask(S_IWGRP | S_IWOTH);
	expected = 0666 & ~(S_IWGRP | S_IWOTH);
	if (argv[1] == NULL)
		name = mktemp(tmp);
	for (i = 0; i < n; i++) {
		fd = open(name, O_RDWR|O_CREAT|O_EXCL, 0666);
		if (fd < 0)
			err(1, "open %s", name);
		memset(&buf, 0, sizeof(buf));
		if (stat(name, &buf) < 0)
			err(1, "stat %s", name);
		if ((buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO)) != expected)
			printf("%s: %o\n", name,
			    (int)buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO));
		else
			printf("%s: ok\n", name);
		unlink(name);
	}
	exit(0);
}

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6dcbc5d..a3e9ef1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2697,7 +2697,8 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
 		sattr->ia_valid |= ATTR_MTIME;
 
 	/* Except MODE, it seems harmless of setting twice. */
-	if ((attrset[1] & FATTR4_WORD1_MODE))
+	if ((attrset[1] & FATTR4_WORD1_MODE) ||
+	    (attrset[2] & FATTR4_WORD2_MODE_UMASK))
 		sattr->ia_valid &= ~ATTR_MODE;
 
 	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
-- 
2.9.3

