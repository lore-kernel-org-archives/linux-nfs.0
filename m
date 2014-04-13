Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f54.google.com ([209.85.160.54]:55110 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754557AbaDMNLg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 09:11:36 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so7175396pbc.41
        for <linux-nfs@vger.kernel.org>; Sun, 13 Apr 2014 06:11:36 -0700 (PDT)
Message-ID: <534A8CEF.6000609@gmail.com>
Date: Sun, 13 Apr 2014 21:11:11 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: add FATTR4_WORD1_MODE flags for cache_consistency_bitmask
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After writing data at NFS client, file's access mode is inconsistent
with server.
Because WRITE proceduce changes the S_ISUID and S_ISGID bits,
but client don't get it.

#touch hello; chmod 06777 hello; stat hello;
  File: ¡®hello¡¯
  Size: 0               Blocks: 0          IO Block: 262144 regular
empty file
Device: 24h/36d Inode: 786434      Links: 1
Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
Context: system_u:object_r:nfs_t:s0
Access: 2014-04-13 21:00:44.996908708 +0800
Modify: 2014-04-13 21:00:44.996908708 +0800
Change: 2014-04-13 21:00:45.033908705 +0800
 Birth: -

#echo 12324 > hello; stat hello; stat /nfstest/hello
  File: ¡®hello¡¯
  Size: 6               Blocks: 0          IO Block: 262144 regular file
Device: 24h/36d Inode: 786434      Links: 1
Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
         ^^^^^ it should be 0777
Context: system_u:object_r:nfs_t:s0
Access: 2014-04-13 21:00:44.996908708 +0800
Modify: 2014-04-13 21:00:45.061908703 +0800
Change: 2014-04-13 21:00:45.061908703 +0800
 Birth: -
  File: ¡®/nfstest/hello¡¯
  Size: 6               Blocks: 8          IO Block: 4096   regular file
Device: 803h/2051d      Inode: 786434      Links: 1
Access: (0777/-rwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
         ^^^^^ bits on the server
Context: system_u:object_r:default_t:s0
Access: 2014-04-13 21:00:44.996908708 +0800
Modify: 2014-04-13 21:00:45.061908703 +0800
Change: 2014-04-13 21:00:45.061908703 +0800
 Birth: -

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 397be39..f234af7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2819,7 +2819,7 @@ static int _nfs4_server_capabilities(struct
nfs_server *server, struct nfs_fh *f

 		memcpy(server->cache_consistency_bitmask, res.attr_bitmask,
sizeof(server->cache_consistency_bitmask));
 		server->cache_consistency_bitmask[0] &=
FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
-		server->cache_consistency_bitmask[1] &=
FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
+		server->cache_consistency_bitmask[1] &=
FATTR4_WORD1_MODE|FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
 		server->cache_consistency_bitmask[2] = 0;
 		server->acl_bitmask = res.acl_bitmask;
 		server->fh_expire_type = res.fh_expire_type;
-- 
1.9.0

