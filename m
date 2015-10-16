Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32842 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbbJPJXD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 05:23:03 -0400
Received: by pabrc13 with SMTP id rc13so115742926pab.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2015 02:23:02 -0700 (PDT)
Subject: [PATCH 1/2] nfs/blocklayout: Fix bad using of page offset in
 bl_read_pagelist
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55FF77DD.8070807@gmail.com> <561CFD01.3080201@gmail.com>
 <CAHQdGtSapCjT+ABSx=8maLN2KQJFFsW-v-F7BYy6wYykKfs0BA@mail.gmail.com>
 <561E01BA.4040109@gmail.com>
 <CAHQdGtSzTQLacptvPw0c73zHFn3ixynkpjavC2v-C5FBxNv8Hg@mail.gmail.com>
 <561F9FBA.7090501@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5620C1EA.9020302@gmail.com>
Date: Fri, 16 Oct 2015 17:22:50 +0800
MIME-Version: 1.0
In-Reply-To: <561F9FBA.7090501@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Blocklayout uses file offset for the read-back page's offset of first writing,
it's definitely wrong, it writes data to bad address of page that cause userspace
application segment fault. It must be the page base stored in header->args.pgbase.

Also, the pg_offset has no influence with isect and extent length.

Note: The offset of the non-first page is always zero.

Ps: A test program will segment fault at read() as,
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, char **argv)
{
        char buf[2049];
        char *filename = NULL;
        int fd = -1;

        if (argc < 2) {
                printf("Usage: %s filename\n", argv[0]);
                return 0;
        }

        filename = argv[1];
        fd = open(filename, O_RDONLY | O_DIRECT);
        if (fd < 0) {
                printf("Open %s fail: %m\n", filename);
                return 1;
        }

        lseek(fd, 2048, SEEK_SET);
        if (read(fd, buf, sizeof(buf) - 1) != (sizeof(buf) - 1))
                printf("Read 4096 bityes data from %s fail: %m\n", filename);
out:
        close(fd);
        return 0;
}

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/blocklayout/blocklayout.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9cd4eb3..ddd0138 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -229,7 +229,7 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 	struct parallel_io *par;
 	loff_t f_offset = header->args.offset;
 	size_t bytes_left = header->args.count;
-	unsigned int pg_offset, pg_len;
+	unsigned int pg_offset = header->args.pgbase, pg_len;
 	struct page **pages = header->args.pages;
 	int pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
 	const bool is_dio = (header->dreq != NULL);
@@ -262,7 +262,6 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 			extent_length = be.be_length - (isect - be.be_f_offset);
 		}
 
-		pg_offset = f_offset & ~PAGE_CACHE_MASK;
 		if (is_dio) {
 			if (pg_offset + bytes_left > PAGE_CACHE_SIZE)
 				pg_len = PAGE_CACHE_SIZE - pg_offset;
@@ -273,9 +272,6 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 			pg_len = PAGE_CACHE_SIZE;
 		}
 
-		isect += (pg_offset >> SECTOR_SHIFT);
-		extent_length -= (pg_offset >> SECTOR_SHIFT);
-
 		if (is_hole(&be)) {
 			bio = bl_submit_bio(READ, bio);
 			/* Fill hole w/ zeroes w/o accessing device */
@@ -301,6 +297,7 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 		extent_length -= (pg_len >> SECTOR_SHIFT);
 		f_offset += pg_len;
 		bytes_left -= pg_len;
+		pg_offset = 0;
 	}
 	if ((isect << SECTOR_SHIFT) >= header->inode->i_size) {
 		header->res.eof = 1;
-- 
2.5.0

