Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33479 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234AbbG2AZ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 20:25:28 -0400
Date: Wed, 29 Jul 2015 10:25:19 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 1/9 v8] fs_pin: Initialize value for fs_pin explicitly
Message-ID: <20150729102519.16f2f70d@noble>
In-Reply-To: <55B5A04D.8090905@gmail.com>
References: <55B5A012.1030006@gmail.com>
	<55B5A04D.8090905@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 27 Jul 2015 11:06:53 +0800 Kinglong Mee <kinglongmee@gmail.com>
wrote:

> Without initialized, done in fs_pin at stack space may
> contains strange value.
> 
> v8, same as v3
> Adds macro for header file
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Reviewed-by: NeilBrown <neilb@suse.com>

It would be really good if some of these early patches could be applied
to the relevant trees so they appear in -next and we only need to keep
reviewing the more interesting code at the end.

Al, Bruce: any chance of some of these getting into -next ...

Thanks,
NeilBrown

> ---
>  include/linux/fs_pin.h | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
> index 3886b3b..0dde7b7 100644
> --- a/include/linux/fs_pin.h
> +++ b/include/linux/fs_pin.h
> @@ -1,3 +1,6 @@
> +#ifndef _LINUX_FS_PIN_H
> +#define _LINUX_FS_PIN_H
> +
>  #include <linux/wait.h>
>  
>  struct fs_pin {
> @@ -16,9 +19,12 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
>  	INIT_HLIST_NODE(&p->s_list);
>  	INIT_HLIST_NODE(&p->m_list);
>  	p->kill = kill;
> +	p->done = 0;
>  }
>  
>  void pin_remove(struct fs_pin *);
>  void pin_insert_group(struct fs_pin *, struct vfsmount *, struct hlist_head *);
>  void pin_insert(struct fs_pin *, struct vfsmount *);
>  void pin_kill(struct fs_pin *);
> +
> +#endif

