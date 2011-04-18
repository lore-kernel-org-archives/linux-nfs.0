Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043Ab1DRPnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Apr 2011 11:43:06 -0400
Date: Mon, 18 Apr 2011 11:42:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Greg KH <gregkh@suse.de>,
        linux-kernel@vger.kernel.org, stable@kernel.org,
        akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [105/105] nfsd4: fix oops on lock failure
Message-ID: <20110418154212.GD20935@pad.home.fieldses.org>
References: <20110412143559.186613198@clark.kroah.org>
 <87pqokx6lr.fsf@devron.myhome.or.jp>
 <BANLkTimN6L80e_oiJ_uqbLde2Cdnw5p45Q@mail.gmail.com>
 <20110418153236.GC20935@pad.home.fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110418153236.GC20935@pad.home.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Apr 18, 2011 at 11:32:36AM -0400, J. Bruce Fields wrote:
> On Sun, Apr 17, 2011 at 09:10:12AM -0700, Linus Torvalds wrote:
> > On Sun, Apr 17, 2011 at 8:03 AM, OGAWA Hirofumi
> > <hirofumi@mail.parknet.co.jp> wrote:
> > >
> > > I'm looking filp leak on recent kernel. Well, anyway,
> 
> Does this fix it?

(But, yes, I think your patch is almost certainly right as well.
Gah--I've been introducing depressing number of regressions lately.)

--b.

> 
> --b.
> 
> commit 5152c8a947359758862d4631863e68e83ec01048
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Apr 15 18:08:26 2011 -0400
> 
>     nfsd4: fix struct file leak on delegation
>     
>     Introduced by acfdf5c383b38f7f4dddae41b97c97f1ae058f49.
>     
>     Cc: stable@kernel.org
>     Reported-by: Gerhard Heift <ml-nfs-linux-20110412-ef47@gheift.de>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index aa309aa..c79a983 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -258,6 +258,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
>  	if (atomic_dec_and_test(&fp->fi_delegees)) {
>  		vfs_setlease(fp->fi_deleg_file, F_UNLCK, &fp->fi_lease);
>  		fp->fi_lease = NULL;
> +		fput(fp->fi_deleg_file);
>  		fp->fi_deleg_file = NULL;
>  	}
>  }
