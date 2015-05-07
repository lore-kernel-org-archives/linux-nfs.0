Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48689 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbbEGTng (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 15:43:36 -0400
Date: Thu, 7 May 2015 15:43:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 1/4] fs_pin: Fix uninitialized value in fs_pin
Message-ID: <20150507194335.GA16527@fieldses.org>
References: <554A149B.5060102@gmail.com>
 <554A14DB.1020504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <554A14DB.1020504@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 06, 2015 at 09:19:23PM +0800, Kinglong Mee wrote:
> Without initialized, done in fs_pin at stack space may
> contains strange value.

Looks like both init_fs_pin callers use some variation on kzalloc(), so
I don't think there's any actual bug here.

Maybe there's some other reason for the belt-and-suspenders approach,
that's Al's call, I think.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  include/linux/fs_pin.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
> index 3886b3b..18fad53 100644
> --- a/include/linux/fs_pin.h
> +++ b/include/linux/fs_pin.h
> @@ -16,6 +16,7 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
>  	INIT_HLIST_NODE(&p->s_list);
>  	INIT_HLIST_NODE(&p->m_list);
>  	p->kill = kill;
> +	p->done = 0;
>  }
>  
>  void pin_remove(struct fs_pin *);
> -- 
> 2.4.0
> 
