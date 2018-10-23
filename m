Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3A3DC46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 17:16:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 70A6820813
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 17:16:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uZ19OC2Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70A6820813
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728270AbeJXBke (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 21:40:34 -0400
Received: from mail-vk1-f193.google.com ([209.85.221.193]:44965 "EHLO
        mail-vk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727612AbeJXBke (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 21:40:34 -0400
Received: by mail-vk1-f193.google.com with SMTP id x78-v6so530103vke.11;
        Tue, 23 Oct 2018 10:16:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mJ3gBh4N1ZXy3/FDEouLTVZ2ilMP84gkn9MklmWUjzU=;
        b=uZ19OC2YGs+JJpVdQhpqsT24JISgzdM3wsC9Ibfr5RXKbikjJsfMNsLZUZEjBqi5Ah
         pyTV0MR+eRJNmLl7olfZJY2+UbkKUqF23UzTCFahilU19od3yCHCnIzmJ6vQiKoJMkOY
         Swd4MGSM4lCQ4hDQ93K5h9V+tNqIi3mx45jx7p7NBso2Gwi6Qz1p1SIMt0pSfBpSlmBT
         4f0ASyHGRoYZPyaFxoTJC7/OBpCUiDOaLOw4HDl3nezB8sDEEmh6vCtd1O/MOoIB1R2R
         3ZWVe4hZw/hVr5nD4lhRnepjcLNBuT9vwtWDea5oQiTL/mwGK5wpfaevB47ZJhsTVvr9
         /4vg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=mJ3gBh4N1ZXy3/FDEouLTVZ2ilMP84gkn9MklmWUjzU=;
        b=c+eMYmiM88iSc6OHM7keJSVLil49NNzfWg4HvIB4sGrtuJ4HoGyArjjj/ZLBkM1Zdy
         TCa2ABNuRkui1nlvADMAsy3Ayq4bqCHJvkbMjucTtzZxzadWECnb/RkcxhZ7S6BI9Lrz
         G0EZj0fa0+AVD2BwPJfzqueGX2WOJc0/s3zkG/HjH7J4G1dmufV4t6gLV6loRThoEJrU
         a7Pqa2m+MYxfI6LgxUTcJXExX/7nMUwbnuPDwRwPQD6EmrPqoA2wYEHiKNTPS0/CjQTe
         fVHWsAbGrvL4huFp3I4+uqp2Kv+VtS1QTYtrWN1xmFEWP8BerBhq3dKHlbbqg5IKw32t
         MFqg==
X-Gm-Message-State: ABuFfoiMeBhx6A/L5JVcJsPZrzPCziUZ3fYjkx490YGXOsAXKPBb7KQp
        eTgQR7WbC87engkN+EEYBtZ5rXZ5GvZtRYuwX/E=
X-Google-Smtp-Source: ACcGV63nKTjHcytlvlTRRJn4nRPryU5Ii+PcEB9vZx50ThrRNmHr1GUrtAemMVHH8Y/YeTQLkijhR7J7YfI2VPrQ1hI=
X-Received: by 2002:a1f:fca:: with SMTP id 193mr21114443vkp.87.1540314976101;
 Tue, 23 Oct 2018 10:16:16 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
 <20181022190620.GA8863@bombadil.infradead.org> <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
 <a4a3ac1e840444871f3bc87606b111668c66618b.camel@redhat.com>
 <CAOQ4uxiRnyxtOXBrdCvUcTa8GkTb2OyaJYJ58Ddoik0=3Y9pyA@mail.gmail.com>
 <CAN-5tyHQc3M2YprFJm35XUxJdAx11a85o1NygE5FQFyHq3SQew@mail.gmail.com> <CAN-5tyEtRSQMS-u0gbheFn5f2siOy8Qva2vnXW6rwb7pr_GDkA@mail.gmail.com>
In-Reply-To: <CAN-5tyEtRSQMS-u0gbheFn5f2siOy8Qva2vnXW6rwb7pr_GDkA@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 23 Oct 2018 13:16:04 -0400
Message-ID: <CAN-5tyEXvnekZJpOhNBkCBCLTpXjM5PghJxDSeo0dwn94_7wDw@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Jeff Layton <jlayton@redhat.com>, willy@infradead.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 23, 2018 at 11:30 AM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Tue, Oct 23, 2018 at 11:03 AM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > On Tue, Oct 23, 2018 at 2:05 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > >
> > > On Tue, Oct 23, 2018 at 2:39 AM Jeff Layton <jlayton@redhat.com> wrote:
> > > >
> > > > On Mon, 2018-10-22 at 15:34 -0400, Olga Kornievskaia wrote:
> > > > > On Mon, Oct 22, 2018 at 3:06 PM Matthew Wilcox <willy@infradead.org> wrote:
> > > > > >
> > > > > > On Mon, Oct 22, 2018 at 02:45:04PM -0400, Olga Kornievskaia wrote:
> > > > > > > On Sat, Oct 20, 2018 at 4:54 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > > > > > > > Another thing is the commit message claims to:
> > > > > > > > "Allow copy_file_range to copy between different superblocks but only
> > > > > > > > of the same file system types"
> > > > > > > >
> > > > > > > > But what the patch actually does is:
> > > > > > > > "Allow copy_file_range() syscall to copy between different filesystems
> > > > > > > > AND allow calling the filesystems' copy_file_range() method
> > > > > > > > between different superblocks but only of the same file system types"
> > > > > > > >
> > > > > > > > It's probably OK and quite useful to do the former, but maybe man page
> > > > > > > > should be fixed to explicitly mention that the copy is expected to work
> > > > > > > > across filesystems since kernel version XXX (?)
> > > > > > > >
> > > > > > > > If you don't wish to change cross filesystem type behavior and only
> > > > > > > > relax cross super block limitation, then you should replace the
> > > > > > > > same inode->i_sb check above with same inode->i_sb->s_type
> > > > > > > > check instead of doing the check only for calling the filesystem
> > > > > > > > copy_file_range() method.
> > > > > > >
> > > > > > > Thank you for the feedback. In the next version, I will remove the
> > > > > > > check for the functions and instead check for the same file system
> > > > > > > types.
> > > > > >
> > > > > > Jeff and I agree that this is the wrong way to go.  Instead, the
> > > > > > cross-device check should be in the individual instances, not the top
> > > > > > level code.
> > > > >
> > > > > So remove the check all together for the VFS (that was my original
> > > > > patch to begin with (like #1 not this one). So am I missing the point
> > > > > again, I keep getting different corrections every time.
> > > >
> > > > Sorry if I wasn't clear before:
> > > >
> > > > Basically, I think Willy and I are both envisioning that some
> > > > copy_file_range implementations may eventually not be subject to the
> > > > limitations of the checks you're adding.
> > > >
> > >
> > > Yes. Eventually. And even Matthew is (quote) "dubious" about that ever
> > > happening. Changing the interface as Matthew proposed has a price
> > > and we need to compare this price to the alleged backporting price
> > > that nobody may ever need to pay.
> > >
> > > As far as I can tell, passing a struct file * on a file_operations method
> > > that does not belong to that filesystem in unprecedented (*) and is a far
> > > more lethal landmine than the alleged backporting landmine.
> > >
> > > (*) prior to v4.19-rc1, filesystems could get an overlayfs file, but
> > >      file_inode(file) has always belonged to the filesystem.
> > >
> > > Olga,
> > >
> > > I do not strongly object to Matthew's proposal, so don't feel
> > > obligated to choose my side of the argument. I am just trying
> > > to offer a different perspective.
> > >
> > > In any case, my outstanding concerns with the patch are:
> > >
> > > 1. If you change syscall to support cross fs type copy (which is
> > >     good IMO) need to document that in commit message
> > >     and possibly follow up later with a note in man page
> > >
> > > 2. Commit message says:
> > >     "This feature was of interest of ... NFS"
> > >     "This feature is needed by NFSv4.2..."
> > >     "NFS will allow for copies between different NFS servers."
> > >     It is not clear to me if we are talking about present of future
> > >     NFSv4.2 code. If NFSv4.2 currently does not support cross
> > >     sb copy (??) than your patch need to enforce same sb
> > >     in nfs4_copy_file_range(). If it does support cross sb copy
> > >     than please edit the commit message to make that clear.
> >
> > I personally agree with Amir. I think it's far fetched that a file
> > system would know how to handle something that's not of its type. When
> > the copy_file_range() was checked in, there was a comment above the
> > superblock check saying "we might want to relax this in the future".
> > It deemed appropriate then to enforce the check since none of the file
> > systems used it. Now, the future is here, and we are removing the
> > check but proposing a different once because again the future isn't
> > here and having a single check simplifies the code.
>
> Sorry Ok I wrote this too fast. I think I'm changing my mind and
> siding with the check by the file system.

The reason I think we should remove the check all together is we'd
allow the callers of copy_file_range() to utilize the
do_splice_direct() between file system types even when
copy_file_range() doesn't support cross fs copy. Isn't that
beneficial?

> > But I don't feel strongly about the check (or rather the location of
> > it VFS vs each FS) and what I ultimately need is to removed same sb
> > check. It sounds like if Amir isn't objecting, then the check for same
> > file system type should be removed from VFS. And, for each of the file
> > systems that currently support copy_file_range() -- CIFS, NFS, and
> > overlayfs -- I need to modify them and add a check for the same
> > fs_type.
> >
> > Amir to answer your question, only NFSv4.2 has copy_offload
> > functionality (not earlier NFS versions). Furthermore, existing
> > upstream only supports same sb copy offload. What this patch series
> > adds is support for copy offload across different superblocks but NFS
> > will not support (and would need a check) for copy offload across
> > different file system types. Also I kinda stand behind the ideas
> > stated: 1) this is of interest to NFS (where NFS here is to represent
> > a community, and CIFS is used to represent the other community). 2)
> > NFSv4.2 copy offload a specific feature that needs this functionality.
> > 3rd statement is bad. Only NFSv4.2 will allow copies between different
> > NFS servers (ie., after this patch +series), the emphasis was on "will
> > allow" meaning what this patch will allow to be done (ie, patch's
> > purpose). Or also, if the NFS server exports different exports, then a
> > copy between them (assuming exports of the same file system type).
> >
> > In the next version of the patch, I'll do my best to specified what
> > changed as the consequence of removing the cross sb check (ie, file
> > system types of the passed in file can be from different file
> > systems). I will add wording to the man page and add the suggested
> > wording to the "porting" file.
