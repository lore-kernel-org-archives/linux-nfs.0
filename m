Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:59889 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759012Ab3BGQuQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 11:50:16 -0500
MIME-Version: 1.0
In-Reply-To: <20130207161948.GG3222@fieldses.org>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
	<1358441584-8783-3-git-send-email-piastry@etersoft.ru>
	<20130130221602.GC15584@fieldses.org>
	<CAKywueRh++TBazK8_kRN7AUb=EFhGv=Sv2CV0BESkfLFy+g5wA@mail.gmail.com>
	<20130205143514.GA9886@fieldses.org>
	<CAKywueS6oGNu9r_bypu32A89pOoiGb47kjXqw2ZcZQhZK+JV3g@mail.gmail.com>
	<20130207141832.GA3222@fieldses.org>
	<CAKywueTmU_L5cwwJSoUY6753eHf_38VtHadZGt9tcLS59sqmOA@mail.gmail.com>
	<20130207144156.GB3222@fieldses.org>
	<CAKywueShbPd9b+WmJwnfwPR_vzk_atBVRBZNTf-HpS7N2CK+AA@mail.gmail.com>
	<20130207161948.GG3222@fieldses.org>
Date: Thu, 7 Feb 2013 20:50:16 +0400
Message-ID: <CAKywueQDtjTxDF4-pcoBaJfXGS7Q+mvf+Jk3KE=2US=gFn_vTQ@mail.gmail.com>
Subject: Re: [PATCH v2 3/8] vfs: Add O_DENYREAD/WRITE flags support for open syscall
From: Pavel Shilovsky <piastry@etersoft.ru>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/2/7 J. Bruce Fields <bfields@fieldses.org>:
> That would be a bug, I think.  E.g. "man 3posix open":
>
>         No  files  shall  be created or modified if the function returns
>         -1.
>
> Looking at the code...  See the references to FILE_CREATED in
> atomic_open--looks like that's trying to prevent may_open from failing
> in this case.
>
>> I think
>> there is no difference between this case and the situation with
>> deny_lock_file there.
>
> Looks to me like it would be a bug in either case.

Then we returned from lookup_open in do_last we go to 'opened' lable.
Then we have a 3(!) chances to return -1 while a file is created
(open_check_o_direct, ima_file_check, handle_truncate). In this case
these places are bugs too.

We can call vfs_unlink if we failed after a file was created, but
possible affects need to be investigated.

-- 
Best regards,
Pavel Shilovsky.
