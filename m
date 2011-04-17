Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41842 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754390Ab1DQQLI convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2011 12:11:08 -0400
In-Reply-To: <87pqokx6lr.fsf@devron.myhome.or.jp>
References: <20110412143559.186613198@clark.kroah.org> <87pqokx6lr.fsf@devron.myhome.or.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 17 Apr 2011 09:10:12 -0700
Message-ID: <BANLkTimN6L80e_oiJ_uqbLde2Cdnw5p45Q@mail.gmail.com>
Subject: Re: [105/105] nfsd4: fix oops on lock failure
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Greg KH <gregkh@suse.de>,
        linux-kernel@vger.kernel.org, stable@kernel.org,
        akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Apr 17, 2011 at 8:03 AM, OGAWA Hirofumi
<hirofumi@mail.parknet.co.jp> wrote:
>
> I'm looking filp leak on recent kernel. Well, anyway,
> 23fcf2ec93fb8573a653408316af599939ff9a8e is strange, and I think it can
> be one of causes.

Hmm. Your patch looks correct to me. Added Neil and linux-nfs.

Bruce? Neil?

               Linus

---
> [PATCH] nfsd4: Fix filp leak
>
> 23fcf2ec93fb8573a653408316af599939ff9a8e (nfsd4: fix oops on lock failure)
>
> The above patch breaks free path for stp->st_file. If stp was inserted
> into sop->so_stateids, we have to free stp->st_file refcount. Because
> stp->st_file refcount itself is taken unrelated to stp->st_file->fi_fds[].
>
> Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> ---
>
>  fs/nfsd/nfs4state.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -puN fs/nfsd/nfs4state.c~nfsd4-filp-leak-fix fs/nfsd/nfs4state.c
> --- linux-2.6/fs/nfsd/nfs4state.c~nfsd4-filp-leak-fix   2011-04-17 20:45:45.000000000 +0900
> +++ linux-2.6-hirofumi/fs/nfsd/nfs4state.c      2011-04-17 20:59:53.000000000 +0900
> @@ -402,8 +402,8 @@ static void free_generic_stateid(struct
>        if (stp->st_access_bmap) {
>                oflag = nfs4_access_bmap_to_omode(stp);
>                nfs4_file_put_access(stp->st_file, oflag);
> -               put_nfs4_file(stp->st_file);
>        }
> +       put_nfs4_file(stp->st_file);
>        kmem_cache_free(stateid_slab, stp);
>  }
>
> _
> --
> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
>
