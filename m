From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: NFS4ERR_SYMLINK  error
Date: Thu, 05 Mar 2009 12:09:40 +0200
Message-ID: <49AFA4E4.50207@panasas.com>
References: <49AF9C28.8030603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
To: Ni Wenjuan <niwj@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16370 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753074AbZCEKJo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 05:09:44 -0500
In-Reply-To: <49AF9C28.8030603@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 05, 2009, 11:32 +0200, Ni Wenjuan <niwj@cn.fujitsu.com> wrote:
> the result of newpynfs test case of  LINK4a .  if you link with target directoty
>  is a symbole file,it should get NFS4ERR_NOTDIR ,instead got NFS4ERR_SYMLINK.
> 
> THE LINK operation  don't list NFS4ERR_SYMLINK as valid errors in the spec. But
> NFS4ERR_SYMLINK seems like a reasonable error.  Is this an oversight
> in the spec, or something we need to fix?

Although NFSv4.1 adds NFS4ERR_SYMLINK to LINK's allowed errors list
(and this might be an indication for it being an oversight in rfc3530),
NFSv4.0 doesn't allow it so this needs to be fixed.

Can you please test the following patch?

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

git diff --stat -p fs/nfsd/vfs.c
 fs/nfsd/vfs.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6e50aaa..9165b1f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1637,6 +1637,9 @@ out_dput:
 out_unlock:
 	fh_unlock(ffhp);
 out:
+	/* nfserr_symlink returned from fh_verify is inappropriate for LINK */
+	if (err == nfserr_symlink)
+		err = nfserr_notdir;
 	return err;
 
 out_nfserr:


> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
