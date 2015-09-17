Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35264 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbbIQJv5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 05:51:57 -0400
Received: by pacfv12 with SMTP id fv12so16446016pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 02:51:57 -0700 (PDT)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfs: Fix open state losing after delegation return
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>, kinglongmee@gmail.com
Message-ID: <55FA8D22.2010003@gmail.com>
Date: Thu, 17 Sep 2015 17:51:30 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After delegation return caused by setting file mode, 
client lost the open state,  DESTROY_CLIENTID will 
get error NFS4ERR_CLIENTID_BUSY from server.

The delegation_type passed to nfs4_open_recover_helper
with NFS4_OPEN_CLAIM_DELEG_CUR_FH is never set.

Reproduce steps,
# mount -t nfs nfs-server:/ /mnt/
# ./delegation_test /mnt/
# umount /mnt    <--- costs 10 seconds

The delegation_test.c is,
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <error.h>

int main(int argc, char **argv)
{
        int fd1, fd2;
        char fname1[1024], fname2[1024];
        struct stat sb;

        if (argc < 2)
                return -1;

        sprintf(fname1, "%s/test1", argv[1]);
        sprintf(fname2, "%s/test2", argv[1]);

        fd1 = open(fname1, O_RDONLY);
        fd2 = open(fname2, O_RDONLY);

        fstat(fd1, &sb);
        fchmod(fd1, sb.st_mode + 1);

        close(fd1);
        close(fd2);

        return 0;
}

Fixes: 39f897fdbd ("NFSv4: When returning a delegation, don't reclaim an incompatible open mode.")
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 693b903..472a52f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1576,8 +1576,7 @@ static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmod
 	struct nfs4_state *newstate;
 	int ret;
 
-	if ((opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR ||
-	     opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEG_CUR_FH) &&
+	if (opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR &&
 	    (opendata->o_arg.u.delegation_type & fmode) != fmode)
 		/* This mode can't have been delegated, so we must have
 		 * a valid open_stateid to cover it - not need to reclaim.
-- 
2.5.0

