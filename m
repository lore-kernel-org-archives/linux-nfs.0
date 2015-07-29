Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37822 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520AbbG2CLi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 22:11:38 -0400
Date: Wed, 29 Jul 2015 12:11:29 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 5/9 v8] sunrpc: Store cache_detail in seq_file's private
 directly
Message-ID: <20150729121129.61c2ed40@noble>
In-Reply-To: <55B5A0D6.8040908@gmail.com>
References: <55B5A012.1030006@gmail.com>
	<55B5A0D6.8040908@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 27 Jul 2015 11:09:10 +0800 Kinglong Mee <kinglongmee@gmail.com>
wrote:

> Cleanup.
> 
> Just store cache_detail in seq_file's private,
> an allocated handle is redundant.
> 
> v8, same as v6.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/cache.c | 28 +++++++++++++---------------
>  1 file changed, 13 insertions(+), 15 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 2928aff..edec603 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1270,18 +1270,13 @@ EXPORT_SYMBOL_GPL(qword_get);
>   * get a header, then pass each real item in the cache
>   */
>  
> -struct handle {
> -	struct cache_detail *cd;
> -};
> -
>  static void *c_start(struct seq_file *m, loff_t *pos)
>  	__acquires(cd->hash_lock)
>  {
>  	loff_t n = *pos;
>  	unsigned int hash, entry;
>  	struct cache_head *ch;
> -	struct cache_detail *cd = ((struct handle*)m->private)->cd;
> -
> +	struct cache_detail *cd = m->private;
>  
>  	read_lock(&cd->hash_lock);
>  	if (!n--)
> @@ -1308,7 +1303,7 @@ static void *c_next(struct seq_file *m, void *p, loff_t *pos)
>  {
>  	struct cache_head *ch = p;
>  	int hash = (*pos >> 32);
> -	struct cache_detail *cd = ((struct handle*)m->private)->cd;
> +	struct cache_detail *cd = m->private;
>  
>  	if (p == SEQ_START_TOKEN)
>  		hash = 0;
> @@ -1334,14 +1329,14 @@ static void *c_next(struct seq_file *m, void *p, loff_t *pos)
>  static void c_stop(struct seq_file *m, void *p)
>  	__releases(cd->hash_lock)
>  {
> -	struct cache_detail *cd = ((struct handle*)m->private)->cd;
> +	struct cache_detail *cd = m->private;
>  	read_unlock(&cd->hash_lock);
>  }
>  
>  static int c_show(struct seq_file *m, void *p)
>  {
>  	struct cache_head *cp = p;
> -	struct cache_detail *cd = ((struct handle*)m->private)->cd;
> +	struct cache_detail *cd = m->private;
>  
>  	if (p == SEQ_START_TOKEN)
>  		return cd->cache_show(m, cd, NULL);
> @@ -1373,24 +1368,27 @@ static const struct seq_operations cache_content_op = {
>  static int content_open(struct inode *inode, struct file *file,
>  			struct cache_detail *cd)
>  {
> -	struct handle *han;
> +	struct seq_file *seq;
> +	int err;
>  
>  	if (!cd || !try_module_get(cd->owner))
>  		return -EACCES;
> -	han = __seq_open_private(file, &cache_content_op, sizeof(*han));
> -	if (han == NULL) {
> +
> +	err = seq_open(file, &cache_content_op);
> +	if (err) {
>  		module_put(cd->owner);
> -		return -ENOMEM;
> +		return err;
>  	}
>  
> -	han->cd = cd;
> +	seq = file->private_data;
> +	seq->private = cd;
>  	return 0;
>  }
>  
>  static int content_release(struct inode *inode, struct file *file,
>  		struct cache_detail *cd)
>  {
> -	int ret = seq_release_private(inode, file);
> +	int ret = seq_release(inode, file);
>  	module_put(cd->owner);
>  	return ret;
>  }


Reviewed-by: NeilBrown <neilb@suse.com>

The 'struct handle' structure hasn't been needed since 2.5.74!

commit 121bed2470d9e8ddeeaa0b9dc2af5561ba07df87
Author: Neil Brown <neilb@cse.unsw.edu.au>
Date:   Thu Jun 26 19:37:59 2003 -0700

    [PATCH] Remove path buffer passed around by cache_show routines
    
    this was need for paths, but now we have seq_path...


This is certainly a patch that could go upstream without waiting for
the rest :-)

Thanks,
NeilBrown
