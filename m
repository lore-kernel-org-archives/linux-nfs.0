Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56959 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750883Ab0G2Ek3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Jul 2010 00:40:29 -0400
Message-ID: <4C5105F8.5050101@cn.fujitsu.com>
Date: Thu, 29 Jul 2010 12:39:20 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: yo mama <mamamia69@gmail.com>
CC: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 	0000000000000020
References: <AANLkTikYDGpeX8kcK3ygFzjM+bYMFTtqr8Wgx+CygUt8@mail.gmail.com>
In-Reply-To: <AANLkTikYDGpeX8kcK3ygFzjM+bYMFTtqr8Wgx+CygUt8@mail.gmail.com>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Hello,
> 
> I am running Kernel version 2.6.35-rc5-pnfs and notice there is kernel
> crash everytime i run iozone on the mounted directory. Is there a
> patch already developed for this bug which i can apply. Please see the
> error message from message log.
> 

 I'm not sure it's ok, please try it.

----

 nfs_writeargs.lock_context always NULL at direct write procedure,
it will cause kernel panic when encode stateid.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 fs/nfs/direct.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 3ef9b0c..cb2e1fd 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -801,6 +801,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
 		data->args.context = ctx;
+		data->args.lock_context = nfs_get_lock_context(ctx);
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
 		data->args.pages = data->pagevec;
-- 
1.6.5.2

-- 
Regards
Bian Naimeng

