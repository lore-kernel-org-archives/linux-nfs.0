Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33612 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791AbbG2AbK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 20:31:10 -0400
Date: Wed, 29 Jul 2015 10:30:59 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/9 v8] fs_pin: Export functions for specific filesystem
Message-ID: <20150729103059.0523f7a5@noble>
In-Reply-To: <55B5A06D.1070506@gmail.com>
References: <55B5A012.1030006@gmail.com>
	<55B5A06D.1070506@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 27 Jul 2015 11:07:25 +0800 Kinglong Mee <kinglongmee@gmail.com>
wrote:

> Exports functions for others who want pin to vfsmount,
> eg, nfsd's export cache.
> 
> v8, same as v4
> add exporting of pin_kill.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Reviewed-by: NeilBrown <neilb@suse.com>

These are needed for any module to participate in pinning.

mnt_pin_kill() and group_pin_kill() are just helper-functions for
unmount etc (and are in fs/internal.h) so don't need to be exported.

Thanks,
NeilBrown

> ---
>  fs/fs_pin.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/fs/fs_pin.c b/fs/fs_pin.c
> index 611b540..a1a4eb2 100644
> --- a/fs/fs_pin.c
> +++ b/fs/fs_pin.c
> @@ -17,6 +17,7 @@ void pin_remove(struct fs_pin *pin)
>  	wake_up_locked(&pin->wait);
>  	spin_unlock_irq(&pin->wait.lock);
>  }
> +EXPORT_SYMBOL(pin_remove);
>  
>  void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head *p)
>  {
> @@ -26,11 +27,13 @@ void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head
>  	hlist_add_head(&pin->m_list, &real_mount(m)->mnt_pins);
>  	spin_unlock(&pin_lock);
>  }
> +EXPORT_SYMBOL(pin_insert_group);
>  
>  void pin_insert(struct fs_pin *pin, struct vfsmount *m)
>  {
>  	pin_insert_group(pin, m, &m->mnt_sb->s_pins);
>  }
> +EXPORT_SYMBOL(pin_insert);
>  
>  void pin_kill(struct fs_pin *p)
>  {
> @@ -72,6 +75,7 @@ void pin_kill(struct fs_pin *p)
>  	}
>  	rcu_read_unlock();
>  }
> +EXPORT_SYMBOL(pin_kill);
>  
>  void mnt_pin_kill(struct mount *m)
>  {

