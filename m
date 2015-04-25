Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33864 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbbDYH4F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Apr 2015 03:56:05 -0400
Received: by lbcga7 with SMTP id ga7so51445480lbc.1
        for <linux-nfs@vger.kernel.org>; Sat, 25 Apr 2015 00:56:03 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 04/45] vfs: Shrink struct posix_acl
References: <cover.1429868795.git.agruenba@redhat.com>
	<ffc9b1f141b8fb65a958234ebd73b9408d1f987b.1429868795.git.agruenba@redhat.com>
Date: Sat, 25 Apr 2015 09:56:01 +0200
In-Reply-To: <ffc9b1f141b8fb65a958234ebd73b9408d1f987b.1429868795.git.agruenba@redhat.com>
	(Andreas Gruenbacher's message of "Fri, 24 Apr 2015 13:04:01 +0200")
Message-ID: <87wq1063qm.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24 2015, Andreas Gruenbacher <andreas.gruenbacher@gmail.com> wrote:

> There is a hole in struct posix_acl because its struct rcu_head member is too
> large; at least on on 64-bit architectures, the hole cannot be closed by
> changing the definition of struct posix_acl. So instead, remove the struct
> rcu_head member from struct posix_acl, make sure that acls are always big
> enough to fit a struct rcu_head, and cast to struct rcu_head * when disposing
> of an acl.
>
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/posix_acl.c            | 5 +++--
>  include/linux/posix_acl.h | 7 ++-----
>  2 files changed, 5 insertions(+), 7 deletions(-)
>
> diff --git a/fs/posix_acl.c b/fs/posix_acl.c
> index 3a48bb7..efe983e 100644
> --- a/fs/posix_acl.c
> +++ b/fs/posix_acl.c
> @@ -140,8 +140,9 @@ EXPORT_SYMBOL(posix_acl_init);
>  struct posix_acl *
>  posix_acl_alloc(int count, gfp_t flags)
>  {
> -	const size_t size = sizeof(struct posix_acl) +
> -	                    count * sizeof(struct posix_acl_entry);
> +	const size_t size = max(sizeof(struct rcu_head),
> +		sizeof(struct posix_acl) +
> +		count * sizeof(struct posix_acl_entry));
>  	struct posix_acl *acl = kmalloc(size, flags);
>  	if (acl)
>  		posix_acl_init(acl, count);
> diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
> index 3e96a6a..66cf477 100644
> --- a/include/linux/posix_acl.h
> +++ b/include/linux/posix_acl.h
> @@ -43,10 +43,7 @@ struct posix_acl_entry {
>  };
>  
>  struct posix_acl {
> -	union {
> -		atomic_t		a_refcount;
> -		struct rcu_head		a_rcu;
> -	};
> +	atomic_t		a_refcount;
>  	unsigned int		a_count;
>  	struct posix_acl_entry	a_entries[0];
>  };
> @@ -73,7 +70,7 @@ static inline void
>  posix_acl_release(struct posix_acl *acl)
>  {
>  	if (acl && atomic_dec_and_test(&acl->a_refcount))
> -		kfree_rcu(acl, a_rcu);
> +		__kfree_rcu((struct rcu_head *)acl, 0);
>  }

This doesn't seem right. Wouldn't that scribble over the a_count and
part of the first struct posix_acl_entry while there might still be rcu
users? That might blow up in interesting ways...

Rasmus
