Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:58646 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbaHTLQu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 07:16:50 -0400
Received: by mail-qc0-f171.google.com with SMTP id r5so7491239qcx.16
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 04:16:49 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 20 Aug 2014 07:16:47 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Joe Perches <joe@perches.com>
Subject: Re: [PATCH] lockd: Remove unused b_fl member from struct nlm_block
Message-ID: <20140820071647.2b607e3f@tlielax.poochiereds.net>
In-Reply-To: <53F47357.7050608@gmail.com>
References: <53F47357.7050608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 20 Aug 2014 18:07:19 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> Fix left code by Joe Perches's patch,
> "locks: Remove unused conf argument from lm_grant"
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/lockd/svclock.c          | 26 +++++---------------------
>  include/linux/lockd/lockd.h |  1 -
>  2 files changed, 5 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 2a61701..796e63b 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -245,7 +245,6 @@ nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
>  	block->b_daemon = rqstp->rq_server;
>  	block->b_host   = host;
>  	block->b_file   = file;
> -	block->b_fl = NULL;
>  	file->f_count++;
>  
>  	/* Add to file's list of blocks */
> @@ -295,7 +294,6 @@ static void nlmsvc_free_block(struct kref *kref)
>  	nlmsvc_freegrantargs(block->b_call);
>  	nlmsvc_release_call(block->b_call);
>  	nlm_release_file(block->b_file);
> -	kfree(block->b_fl);
>  	kfree(block);
>  }
>  
> @@ -523,20 +521,13 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
>  	block = nlmsvc_lookup_block(file, lock);
>  
>  	if (block == NULL) {
> -		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
> -

I think the problem here is that we're allocating a file_lock with
kzalloc instead of using locks_alloc_lock. I think we should change
this code to use that, and the kfree in nlmsvc_free_block to use
locks_free_lock. Maybe something like this? (untested, but it compiles).

I'll plan to resend the patch below for 3.18 once I've tested it out and
Trond, Bruce and I can work out who should merge it.

-------------------------[snip]-------------------------

[PATCH] lockd: switch allocation of conflock to standard lock allocation routines

lockd currently allocates a struct file_lock with kzalloc to use as a
conflock. Change it to use locks_alloc_lock and locks_free_lock instead.

In the event that someone were to add lm_get_owner/lm_put_owner ops for
lockd, then this would help ensure that things get cleaned up properly.
It's also less wasteful with memory since locks_alloc_lock allocates
from a dedicated slabcache.

Cc: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/lockd/svclock.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 2a6170133c1d..1eb2ae47e6b1 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -295,7 +295,8 @@ static void nlmsvc_free_block(struct kref *kref)
 	nlmsvc_freegrantargs(block->b_call);
 	nlmsvc_release_call(block->b_call);
 	nlm_release_file(block->b_file);
-	kfree(block->b_fl);
+	if (block->b_fl)
+		locks_free_lock(block->b_fl);
 	kfree(block);
 }
 
@@ -523,13 +524,13 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 	block = nlmsvc_lookup_block(file, lock);
 
 	if (block == NULL) {
-		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
+		struct file_lock *conf = locks_alloc_lock();
 
 		if (conf == NULL)
 			return nlm_granted;
 		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
 		if (block == NULL) {
-			kfree(conf);
+			locks_free_lock(conf);
 			return nlm_granted;
 		}
 		block->b_fl = conf;
-- 
1.9.3


