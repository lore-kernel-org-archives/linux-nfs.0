From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/4] nfsd: Drop reference in expkey_parse error cases
Date: Mon, 20 Oct 2008 16:53:20 -0400
Message-ID: <20081020205320.GB27702@fieldses.org>
References: <20081020061428.17722.68145.sendpatchset@localhost.localdomain> <20081020061440.17722.70281.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33395 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832AbYJTUxX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 16:53:23 -0400
In-Reply-To: <20081020061440.17722.70281.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 20, 2008 at 11:44:40AM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Drop reference to export key on error. Compile tested.

Looks correct, thanks!  But adding the export key cleanup to every "goto
out" is getting a little silly; I've applied your patch, then applied
the cleanup appended below.

--b.

> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  fs/nfsd/export.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff -ruNp linux-2.6.27.org/fs/nfsd/export.c linux-2.6.27.new/fs/nfsd/export.c
> --- linux-2.6.27.org/fs/nfsd/export.c	2008-10-20 10:47:18.000000000 +0530
> +++ linux-2.6.27.new/fs/nfsd/export.c	2008-10-20 10:48:36.000000000 +0530
> @@ -151,8 +151,10 @@ static int expkey_parse(struct cache_det
>  
>  	/* now we want a pathname, or empty meaning NEGATIVE  */
>  	err = -EINVAL;
> -	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) < 0)
> +	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) < 0) {
> +		cache_put(&ek->h, &svc_expkey_cache);
>  		goto out;
> +	}
>  	dprintk("Path seems to be <%s>\n", buf);
>  	err = 0;
>  	if (len == 0) {
> @@ -164,8 +166,10 @@ static int expkey_parse(struct cache_det
>  	} else {
>  		struct nameidata nd;
>  		err = path_lookup(buf, 0, &nd);
> -		if (err)
> +		if (err) {
> +			cache_put(&ek->h, &svc_expkey_cache);
>  			goto out;
> +		}
>  
>  		dprintk("Found the path %s\n", buf);
>  		key.ek_path = nd.path;
> --

commit 0264a42d6b12afaaa39dbf407655bb49ed828a1e
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Oct 20 16:34:21 2008 -0400

    nfsd: clean up expkey_parse error cases
    
    We might as well do all of these at the end.  Fix up a couple minor
    style nits while we're there.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 7ce2c6e..5cd882b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -99,7 +99,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 	int fsidtype;
 	char *ep;
 	struct svc_expkey key;
-	struct svc_expkey *ek;
+	struct svc_expkey *ek = NULL;
 
 	if (mesg[mlen-1] != '\n')
 		return -EINVAL;
@@ -107,7 +107,8 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	err = -ENOMEM;
-	if (!buf) goto out;
+	if (!buf)
+		goto out;
 
 	err = -EINVAL;
 	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
@@ -151,38 +152,34 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 
 	/* now we want a pathname, or empty meaning NEGATIVE  */
 	err = -EINVAL;
-	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) < 0) {
-		cache_put(&ek->h, &svc_expkey_cache);
+	len = qword_get(&mesg, buf, PAGE_SIZE);
+	if (len < 0)
 		goto out;
-	}
 	dprintk("Path seems to be <%s>\n", buf);
 	err = 0;
 	if (len == 0) {
 		set_bit(CACHE_NEGATIVE, &key.h.flags);
 		ek = svc_expkey_update(&key, ek);
-		if (ek)
-			cache_put(&ek->h, &svc_expkey_cache);
-		else err = -ENOMEM;
+		if (!ek)
+			err = -ENOMEM;
 	} else {
 		struct nameidata nd;
 		err = path_lookup(buf, 0, &nd);
-		if (err) {
-			cache_put(&ek->h, &svc_expkey_cache);
+		if (err)
 			goto out;
-		}
 
 		dprintk("Found the path %s\n", buf);
 		key.ek_path = nd.path;
 
 		ek = svc_expkey_update(&key, ek);
-		if (ek)
-			cache_put(&ek->h, &svc_expkey_cache);
-		else
+		if (!ek)
 			err = -ENOMEM;
 		path_put(&nd.path);
 	}
 	cache_flush();
  out:
+	if (ek)
+		cache_put(&ek->h, &svc_expkey_cache);
 	if (dom)
 		auth_domain_put(dom);
 	kfree(buf);
