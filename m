Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:64776 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbbBFDFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 22:05:48 -0500
Received: by mail-qc0-f180.google.com with SMTP id r5so9801725qcx.11
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 19:05:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQCLpWwV+wdu0-nyrrmemXYgsJWKqiU5yXmmZUYj2RHpg@mail.gmail.com>
References: <1423175831-54558-1-git-send-email-trond.myklebust@primarydata.com>
 <CAKVebiVC+EH+baPYF2WNy1yQT-TvgR8pVFBFKPVQqdrzRY6atA@mail.gmail.com>
 <CAKVebiVX7Nd76_byoDgaZfP6ojVZ_WZ_rHu8T+K9TnrCphJ8wA@mail.gmail.com> <CAHQdGtQCLpWwV+wdu0-nyrrmemXYgsJWKqiU5yXmmZUYj2RHpg@mail.gmail.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 6 Feb 2015 11:05:27 +0800
Message-ID: <CAKVebiVNwEspYssDjJJxTQ__Uayn6F6=3X3MhjKDqK+thQbCqw@mail.gmail.com>
Subject: Re: [PATCH 1/5] NFSv4: Ensure we reference the inode for
 return-on-close in delegreturn
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 6, 2015 at 10:53 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Thu, Feb 5, 2015 at 8:57 PM, Peng Tao <tao.peng@primarydata.com> wrote:
>>
>> On Fri, Feb 6, 2015 at 9:45 AM, Peng Tao <tao.peng@primarydata.com> wrote:
>> > On Fri, Feb 6, 2015 at 6:37 AM, Trond Myklebust
>> > <trond.myklebust@primarydata.com> wrote:
>> >> If we have to do a return-on-close in the delegreturn code, then
>> >> we must ensure that the inode and super block remain referenced.
>> >>
>> ah, a second thought. I looked for call sites of nfs_sb_active() and
>> it gets called at five places in current tree:
>> alloc_nfs_open_context, nfs4_opendata_alloc, nfs4_do_close,
>> nfs_do_call_unlink, nfs_do_call_unlink
>>
>> So it appears that sb is activated while any file keeps opened and
>> between unlink calls. Then it looks that we are allowed to keep
>> delegations after sb is released? Maybe the best way to fix the sb
>> reference part is to pin sb when getting the first delegation.
>
> The superblock reference is only there in order to allow us to perform
> asynchronous delegreturns without any danger. The problem here is that
> we'd end up pinning the superblock even after umount if there are
> still unreturned delegations.
> That said, I do see that there is a problem with calling
> nfs_sb_active() when sb->s_active is zero, so I think I'd like to fix
> that up.
yeah, I see your point. Thanks for the explanation.

Cheers,
Tao

>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
