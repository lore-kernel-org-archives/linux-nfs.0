From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on file
Date: Wed, 19 May 2010 17:49:38 +0800
Message-ID: <4BF3B432.3040802@cn.fujitsu.com>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, ebiederm@xmission.com,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk, jamie@shareable.org,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54704 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753576Ab0ESJtj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 05:49:39 -0400
In-Reply-To: <20100514055844.109d2fdc-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Jeff Layton :
>>  /*	Check whether we can create an object with dentry child in directory
> 
> This doesn't look right to me.
> 
> The fcntl(2) manpage basically says that leases should be broken if the
> file is opened for read or write, or is truncated. unlinks don't seem
> to fall into either category...

Maybe the new one is better than before.

--------------------------------------------------------------

After client get one file's READ delegation through NFSv4,
server delete this file but don't reclaim the delegation.

This patch add break_lease at may_delete, which can reclaim delegations.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

---
 fs/namei.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index b86b96f..0423e19 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1338,6 +1338,10 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
 		return -ENOENT;
 	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
 		return -EBUSY;
+
+	/* try to break leases, but no effect to delete. */
+	break_lease(victim->d_inode, FMODE_WRITE);
+
 	return 0;
 }
 
-- 
1.7.0




