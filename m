Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:59378 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440Ab2JVQGQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:06:16 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so2175418iag.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:06:16 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] mountd: Make local functions static
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:06:15 -0400
Message-ID: <20121022160614.4552.16831.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up compiler warnings:

cache.c: At top level:
cache.c:373:5: warning: no previous prototype for ‘parse_fsid’
  [-Wmissing-prototypes]

cache.c: At top level:
cache.c:504:18: warning: no previous prototype for
  ‘lookup_client_addr’ [-Wmissing-prototypes]

Seen with gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC)

Once the parse_fsid() function was made static, the compiler
detected execution paths through it that did not initialize some
fields in *parsed.

[ I'm pretty sure these problems are currently harmless, since each
path is taken depending on the value of the .fsidtype field.  Each
path accesses only the fields in *parsed that it cares about. ]

cache.c: In function ‘nfsd_fh’:
cache.c:500:13: warning: ‘parsed.fhuuid’ may be used uninitialized
  in this function [-Wuninitialized]
cache.c:535:21: note: ‘parsed.fhuuid’ was declared here
cache.c:495:21: warning: ‘parsed.uuidlen’ may be used uninitialized
  in this function [-Wuninitialized]
cache.c:535:21: note: ‘parsed.uuidlen’ was declared here
cache.c:477:46: warning: ‘*((void *)&parsed+16)’ may be used
   uninitialized in this function [-Wuninitialized]
cache.c:535:21: note: ‘*((void *)&parsed+16)’ was declared here
cache.c:472:51: warning: ‘parsed.minor’ may be used uninitialized
  in this function [-Wuninitialized]
cache.c:535:21: note: ‘parsed.minor’ was declared here
cache.c:472:6: warning: ‘parsed.major’ may be used uninitialized
  in this function [-Wuninitialized]
cache.c:535:21: note: ‘parsed.major’ was declared here
cache.c:483:18: warning: ‘*((void *)&parsed+4)’ may be used
  uninitialized in this function [-Wuninitialized]
cache.c:535:21: note: ‘*((void *)&parsed+4)’ was declared here

This is because parsed_fsid isn't a union type.  parse_fsid() leaves
uninitialized fields that are not used by a particular fsidtype.  To
prevent an accidental dereference of stack garbage (.fhuuid being an
example of a pointer that is left uninitialized sometimes), have
parse_fsid() defensively pre-initialize *parsed to zero.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 70e1aa4..57a3fed 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -370,11 +370,13 @@ struct parsed_fsid {
 	char *fhuuid;
 };
 
-int parse_fsid(int fsidtype, int fsidlen, char *fsid, struct parsed_fsid *parsed)
+static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
+		struct parsed_fsid *parsed)
 {
 	unsigned int dev;
 	unsigned long long inode64;
 
+	memset(parsed, 0, sizeof(*parsed));
 	parsed->fsidtype = fsidtype;
 	switch(fsidtype) {
 	case FSID_DEV: /* 4 bytes: 2 major, 2 minor, 4 inode */
@@ -501,7 +503,7 @@ static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *path)
 	return false;
 }
 
-struct addrinfo *lookup_client_addr(char *dom)
+static struct addrinfo *lookup_client_addr(char *dom)
 {
 	struct addrinfo *ret;
 	struct addrinfo *tmp;

