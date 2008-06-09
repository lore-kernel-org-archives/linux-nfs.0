From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 6/6] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Mon, 9 Jun 2008 17:10:22 -0400
Message-ID: <76bd70e30806091410q15dac78bx16e86eca0c5ad98@mail.gmail.com>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-2-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-4-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-5-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-6-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-7-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:37496 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969AbYFIVKY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2008 17:10:24 -0400
Received: by gv-out-0910.google.com with SMTP id e6so584896gvc.37
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jun 2008 14:10:22 -0700 (PDT)
In-Reply-To: <1213044696-32741-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I thought you had decided this wasn't necessary.

On Mon, Jun 9, 2008 at 4:51 PM, J. Bruce Fields <bfields@citi.umich.edu> wrote:
> The code incorrectly assumes here that the server name (or ip address)
> is null-terminated.  This can cause referrals to fail in some cases.
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfs/nfs4namespace.c |   34 ++++++++++------------------------
>  1 files changed, 10 insertions(+), 24 deletions(-)
>
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index b112857..2f3eabe 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -93,23 +93,6 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
>        return 0;
>  }
>
> -/*
> - * Check if the string represents a "valid" IPv4 address
> - */
> -static inline int valid_ipaddr4(const char *buf)
> -{
> -       int rc, count, in[4];
> -
> -       rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
> -       if (rc != 4)
> -               return -EINVAL;
> -       for (count = 0; count < 4; count++) {
> -               if (in[count] > 255)
> -                       return -EINVAL;
> -       }
> -       return 0;
> -}
> -
>  /**
>  * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
>  * @mnt_parent - mountpoint of parent directory
> @@ -172,19 +155,20 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
>
>                s = 0;
>                while (s < location->nservers) {
> +                       const struct nfs4_string *buf = &location->servers[s];
>                        struct sockaddr_in addr = {
>                                .sin_family     = AF_INET,
>                                .sin_port       = htons(NFS_PORT),
>                        };
> +                       u8 *ip = (u8 *)addr.sin_addr.s_addr;
>
> -                       if (location->servers[s].len <= 0 ||
> -                           valid_ipaddr4(location->servers[s].data) < 0) {
> -                               s++;
> -                               continue;
> -                       }
> +                       if (buf->len <= 0 || buf->len >= PAGE_SIZE)
> +                               goto next;
> +                       if (!in4_pton(buf->data, buf->len, ip, '\0', NULL))
> +                               goto next;
>
> -                       mountdata.hostname = location->servers[s].data;
> -                       addr.sin_addr.s_addr = in_aton(mountdata.hostname),
> +                       mountdata.hostname = kmalloc(buf->len + 1, GFP_KERNEL);
> +                       mountdata.hostname[buf->len] = 0;
>                        mountdata.addr = (struct sockaddr *)&addr;
>                        mountdata.addrlen = sizeof(addr);
>
> @@ -193,9 +177,11 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
>                                        mountdata.mnt_path);
>
>                        mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, &mountdata);
> +                       kfree(mountdata.hostname);
>                        if (!IS_ERR(mnt)) {
>                                break;
>                        }
> +next:
>                        s++;
>                }
>                loc++;
> --
> 1.5.5.rc1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
I am certain that these presidents will understand the cry of the
people of Bolivia, of the people of Latin America and the whole world,
which wants to have more food and not more cars. First food, then if
something's left over, more cars, more automobiles. I think that life
has to come first.
-- Evo Morales
