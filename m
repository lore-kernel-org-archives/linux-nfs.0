Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53EA7C67863
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 18:45:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5EE6B20651
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 18:45:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hwWOEgGR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EE6B20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728442AbeJWDE5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 23:04:57 -0400
Received: from mail-vs1-f65.google.com ([209.85.217.65]:43851 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727748AbeJWDE5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 23:04:57 -0400
Received: by mail-vs1-f65.google.com with SMTP id w85so30283328vsa.10;
        Mon, 22 Oct 2018 11:45:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eXR2SP0ZAqmmqBAl9sHWWo6gHvSBw76qjmvTLO9cLfQ=;
        b=hwWOEgGRsbbK2FSSMgoJV/zSGPqvx7PoGPvHMOEAOtyxhZOqRkztVHWUDJ8TQW69n2
         ERSdYcyj29NMiVJ75dvHciBcUAzzA7KfipUfEigSEbm0v/IYgPjlBVwiAY9RhF8lXED0
         VPGgoDAI6afxbJ3/Eb3Mlj0vNLqwE+fQ2m1buCR048oIZmNKK42ZctHIDduQt8V1iWvb
         bzNrxUwqFfpMJfHI34K/gqL/P0pKHwymQ4TpR8K5QjcSx5Oxv3hhXUyxty/69XHe3N8L
         bJmp5PWdALy68Ujwb9BOws+el5V7pWSQoCtvIcFFrGC0jMtc5KPQfhxZdT2EcXj4Y56v
         E17Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=eXR2SP0ZAqmmqBAl9sHWWo6gHvSBw76qjmvTLO9cLfQ=;
        b=I15WlHA51CFmMJ3+vKrjhHNZXgHEzsEh4pNJ+gqEO/mdY8cE3tIQ/zT9XL9JoiQ9y9
         SuNXuiLuuw6lpLtWmPI4Y60LjNqzu9qXkbFjDhvxjonj2ENBI2dpmCoEqYAZutCr8qag
         3Jk6LAN+XaSNy04+DaShp8aWmGKp0acd+ichIkAqod5KuT59BMsYbrMlDtZ/kR05Zkyo
         OYfedBTYkW1j2Lpq/c5CG/NEoKZXhU3VkyqyX5YUeKCiY+wM2IiUOKNL9VfHZyZsD0e8
         KyaAlJ3J/99Pv2yS4VxabDriqkrH+XkDAby5o9EqInXBPY2WgyphBjF4U311NC4q+RZ5
         pu/g==
X-Gm-Message-State: ABuFfojiJLG88rXjG28HrPK9jygpJFZkYLpitw9P1AyuqNGYP90ybbHR
        vjL56unUv/sKJirp0/XgGVyzW6ctodiRrl92apI=
X-Google-Smtp-Source: ACcGV61woef2NlzvcDPp3wS1b37+BCxP3kWQtzIobdCZ4FJsxPmAtxPIWZQA4eAM6KL2VzzbSn3tp37Y+B9cgKtjNpk=
X-Received: by 2002:a67:4282:: with SMTP id p124mr19443699vsa.134.1540233916296;
 Mon, 22 Oct 2018 11:45:16 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
In-Reply-To: <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 22 Oct 2018 14:45:04 -0400
Message-ID: <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
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

On Sat, Oct 20, 2018 at 4:54 AM Amir Goldstein <amir73il@gmail.com> wrote:
>
> On Sat, Oct 20, 2018 at 7:06 AM Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > On Fri, Oct 19, 2018 at 11:30:18AM -0400, Olga Kornievskaia wrote:
> > > Allow copy_file_range to copy between different superblocks but only
> > > of the same file system types. This feature was of interest to CIFS
> > > as well as NFS.
> >
> > > +     if (file_out->f_op->copy_file_range &&
> > > +                     (file_in->f_op->copy_file_range ==
> > > +                             file_out->f_op->copy_file_range)) {
> >
> > That is seriously asking for trouble.  If at some point we add
> > a library function usable as ->copy_file_range() instance, this
> > will turn into a hard-to-spot problem.
> >
> > Comparing methods like that is best avoided.  If you want to compare
> > fs types, do just that - it's not hard.
>
> Another thing is the commit message claims to:
> "Allow copy_file_range to copy between different superblocks but only
> of the same file system types"
>
> But what the patch actually does is:
> "Allow copy_file_range() syscall to copy between different filesystems
> AND allow calling the filesystems' copy_file_range() method
> between different superblocks but only of the same file system types"
>
> It's probably OK and quite useful to do the former, but maybe man page
> should be fixed to explicitly mention that the copy is expected to work
> across filesystems since kernel version XXX (?)
>
> If you don't wish to change cross filesystem type behavior and only
> relax cross super block limitation, then you should replace the
> same inode->i_sb check above with same inode->i_sb->s_type
> check instead of doing the check only for calling the filesystem
> copy_file_range() method.

Thank you for the feedback. In the next version, I will remove the
check for the functions and instead check for the same file system
types.

>
> >
> > Another potential issue here is the interplay with local filesystems
> > using vfs_clone_file_prep_inodes() (or Darrick's series lifting that
> > into generic code).  There we assume the same block size on both
> > sides; that is automatically true if they live on the same superblock,
> > but with your changes it's no longer true.
>
> Heh? I don't see that Darrick's work has anything to do with
> copy_file_range(). It only touched vfs_copy_file_range() for
> the ->clone_file_range() call, which Olga's patch protects with same sb
> check.
>
> Thanks,
> Amir.
