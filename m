Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751311Ab2H1OJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Aug 2012 10:09:29 -0400
Message-ID: <1346162966.2554.3.camel@localhost>
Subject: Re: [PATCH] Avoid array overflow in __nfs4_get_acl_uncached
From: Sachin Prabhu <sprabhu@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 28 Aug 2012 15:09:26 +0100
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F69340@SACEXCMBX04-PRD.hq.netapp.com>
References: <1345817768-23511-1-git-send-email-sprabhu@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F4AF1E@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345843866.2279.6.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F5842F@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345845062.32200.1.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F5859F@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345937503.4943.17.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F69340@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> OK. How about this patch, which applies on top of the one I sent you?
> 8<-----------------------------------------------------------------
> From 22c9e2475560edda925f971a2a02bac58536414b Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sun, 26 Aug 2012 11:44:43 -0700
> Subject: [PATCH] NFSv4: Add buffer overflow checking to nfs4_write_cached_acl
> 
> Currently, the buffer overflow checking is done incorrectly by the
> caller. Move the overflow checking into nfs4_write_cached_acl itself
> for robustness, and fix the overflow calculation to take into account
> the 'pgbase' argument to _copy_from_pages.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 654dc38..af4ebc3 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3734,12 +3734,13 @@ out:
>  	return ret;
>  }
>  
> -static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size_t pgbase, size_t acl_len)
> +static void nfs4_write_cached_acl(struct inode *inode, struct page **pages,
> +		size_t srclen, size_t pgbase, size_t acl_len)
>  {
>  	struct nfs4_cached_acl *acl;
>  	size_t buflen = sizeof(*acl) + acl_len;
>  
> -	if (pages && buflen <= PAGE_SIZE) {
> +	if (buflen <= PAGE_SIZE && srclen <= pgbase + acl_len) {
>  		acl = kmalloc(buflen, GFP_KERNEL);
>  		if (acl == NULL)
>  			goto out;
> @@ -3820,11 +3821,8 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  		goto out_free;
>  
>  	acl_len = res.acl_len;
> -	if (acl_len > args.acl_len)
> -		nfs4_write_cached_acl(inode, NULL, 0, acl_len);
> -	else
> -		nfs4_write_cached_acl(inode, pages, res.acl_data_offset,
> -				      acl_len);
> +	nfs4_write_cached_acl(inode, pages, args.acl_len,
> +			res.acl_data_offset, res.acl_len);
>  	if (buf) {
>  		ret = -ERANGE;
>  		if (acl_len > buflen)
> -- 
> 1.7.11.4

I encountered 2 problems. 
1) The if condition should be srclen >= pgbase + acl_len
2) There is a second _copy_from_pages which copies to the the acl to the
passed buffer in __nfs4_get_acl_uncached().

I've attached a patch below.
-----

>From ec84527625b3847a0623410d532253dd919e119a Mon Sep 17 00:00:00 2001
From: Sachin Prabhu <sprabhu@redhat.com>
Date: Tue, 28 Aug 2012 15:01:13 +0100
Subject: [PATCH] NFSv4: Check for buffer overflow in __nfs4_get_acl_uncached

Check for buffer overflow in __nfs4_get_acl_uncached when using
_copy_from_pages to copy to the buffer passed in the argument.

Also fix if condition in nfs4_write_cached_acl() from the previous post.

Signed-off-by: Sachin Prabhu
---
 fs/nfs/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 580b0b1..cb8748d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3740,7 +3740,7 @@ static void nfs4_write_cached_acl(struct inode *inode, struct page **pages,
 	struct nfs4_cached_acl *acl;
 	size_t buflen = sizeof(*acl) + acl_len;
 
-	if (buflen <= PAGE_SIZE && srclen <= pgbase + acl_len) {
+	if (buflen <= PAGE_SIZE && srclen >= pgbase + acl_len) {
 		acl = kmalloc(buflen, GFP_KERNEL);
 		if (acl == NULL)
 			goto out;
@@ -3825,7 +3825,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 			res.acl_data_offset, res.acl_len);
 	if (buf) {
 		ret = -ERANGE;
-		if (acl_len > buflen)
+		if (acl_len > buflen || args.acl_len < res.acl_data_offset + res.acl_len)
 			goto out_free;
 		_copy_from_pages(buf, pages, res.acl_data_offset,
 				acl_len);
-- 
1.7.11.4





