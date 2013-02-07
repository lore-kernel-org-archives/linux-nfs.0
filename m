Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40000 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656Ab3BGRDC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 12:03:02 -0500
Date: Thu, 7 Feb 2013 12:03:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v2 3/8] vfs: Add O_DENYREAD/WRITE flags support for open
 syscall
Message-ID: <20130207170300.GN3222@fieldses.org>
References: <20130130221602.GC15584@fieldses.org>
 <CAKywueRh++TBazK8_kRN7AUb=EFhGv=Sv2CV0BESkfLFy+g5wA@mail.gmail.com>
 <20130205143514.GA9886@fieldses.org>
 <CAKywueS6oGNu9r_bypu32A89pOoiGb47kjXqw2ZcZQhZK+JV3g@mail.gmail.com>
 <20130207141832.GA3222@fieldses.org>
 <CAKywueTmU_L5cwwJSoUY6753eHf_38VtHadZGt9tcLS59sqmOA@mail.gmail.com>
 <20130207144156.GB3222@fieldses.org>
 <CAKywueShbPd9b+WmJwnfwPR_vzk_atBVRBZNTf-HpS7N2CK+AA@mail.gmail.com>
 <20130207161948.GG3222@fieldses.org>
 <CAKywueQDtjTxDF4-pcoBaJfXGS7Q+mvf+Jk3KE=2US=gFn_vTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKywueQDtjTxDF4-pcoBaJfXGS7Q+mvf+Jk3KE=2US=gFn_vTQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2013 at 08:50:16PM +0400, Pavel Shilovsky wrote:
> 2013/2/7 J. Bruce Fields <bfields@fieldses.org>:
> > That would be a bug, I think.  E.g. "man 3posix open":
> >
> >         No  files  shall  be created or modified if the function returns
> >         -1.
> >
> > Looking at the code...  See the references to FILE_CREATED in
> > atomic_open--looks like that's trying to prevent may_open from failing
> > in this case.
> >
> >> I think
> >> there is no difference between this case and the situation with
> >> deny_lock_file there.
> >
> > Looks to me like it would be a bug in either case.
> 
> Then we returned from lookup_open in do_last we go to 'opened' lable.
> Then we have a 3(!) chances to return -1 while a file is created
> (open_check_o_direct, ima_file_check, handle_truncate

I don't know about the first two, but handle_truncate won't be hit since
will_truncate is false.

> ). In this case
> these places are bugs too.
> 
> We can call vfs_unlink if we failed after a file was created, but
> possible affects need to be investigated.

We definitely don't want to try to undo the create with an unlink.

--b.
