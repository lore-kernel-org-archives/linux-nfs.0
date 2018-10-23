Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D895C46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:51:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B82F82075D
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:51:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uX0QxVTe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B82F82075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727758AbeJXBPU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 21:15:20 -0400
Received: from mail-vk1-f196.google.com ([209.85.221.196]:33529 "EHLO
        mail-vk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727402AbeJXBPT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 21:15:19 -0400
Received: by mail-vk1-f196.google.com with SMTP id l186so517242vke.0
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 09:51:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=n+fVXtV6pwUEPpKuI8yN7NTBHXa+2Ys7+5NBdrBhaV8=;
        b=uX0QxVTekHSBVTM/HaFj8fhvXqrrtVnuDXS0cvWdoUXHvKpwklVEnng4EvQ6wbbiFs
         5406+zlVslSapZQIz8sI6JVCIx0CoShqODOm2rLimtnZ73GIV8VEbbGkuQQoDFxKba+K
         EX7sijtPcZwx/fOOlQdEhH66cxvcRTu6PYz58Y3aXz2+W82DHoT2RakdsNFPMgPDoA6B
         VCaobk/FHJW3H2Eu+t89jOwJlhiibM+kM2ifmBX0ThE8bnCtGHCANJfa/mp2w66KGqGX
         hMtWqlu08YGF8eGR+WBsl9ehVutnYxZ/BM5lYAhoeLx4UmY/r4XUwxJVOIJL0CkfuP4X
         J9SQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=n+fVXtV6pwUEPpKuI8yN7NTBHXa+2Ys7+5NBdrBhaV8=;
        b=O3JsZASvXFOv0bmnF2nKIWCarHcrCR49oudPGZe2YS1RbRglXKfsbB1pHD09JDG2kE
         oMf5Gt9fX0n+UsgAvoXDhbAE8Pl9WuJseBz4t2BJpxM231NgiE3v4MLu5bjjtnQCkH6/
         P+gkQGZpC5MNCIQqSX0xfdKSrs/yZXZbAwUkwXjEQsG5hmJ91LptmXawULXjaUOhH2ei
         rmvRoVftscE+puDmX0XUvyV7IJQo6J93dJJRkKj6m5RdeychGMAi7LLKfUIAF8CFDQzF
         DynHrfDnDe1RAE5PbA3VkVU2mu1+1V3jm6+3ShOjhPAjVGyWZt/fImtE8CEBQTKRc2Ps
         Hnjg==
X-Gm-Message-State: ABuFfog1WTYeXF9VqZR3r0jQAxw1g0NO/0o9ES5d6cJyJRevhS6uO+ka
        l5XTRNiF6NjXIviE8q4QzhI7IEPYsCWhG2UoDns=
X-Google-Smtp-Source: ACcGV60ZQCICXNr9OFWrJ3xckqkZm9zkiFtu3f5WBHDreh868PAT++wJ6zrQIKt7opH5fPKjZ0By3gxYqp4+JY951X4=
X-Received: by 2002:a1f:1a83:: with SMTP id a125-v6mr21849576vka.83.1540313467896;
 Tue, 23 Oct 2018 09:51:07 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
 <20181019152932.32462-2-olga.kornievskaia@gmail.com> <fc9619bee3e27d6756ecff9ae143c646d2567b62.camel@kernel.org>
 <CAN-5tyEbGmujqD5Q1FBH9uBWR0YYbW_ojBhdbcD_7TYV9dqMag@mail.gmail.com> <1c269f7a09c24638ed3105b1fc934ca2c25383c9.camel@kernel.org>
In-Reply-To: <1c269f7a09c24638ed3105b1fc934ca2c25383c9.camel@kernel.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 23 Oct 2018 12:50:56 -0400
Message-ID: <CAN-5tyFW0JRFiEo78bHS97e_7-+POSbfhci0_mcQsQoi-YjNPQ@mail.gmail.com>
Subject: Re: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
To:     jlayton@kernel.org
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 22, 2018 at 7:23 PM Jeff Layton <jlayton@kernel.org> wrote:
>
> On Mon, 2018-10-22 at 14:32 -0400, Olga Kornievskaia wrote:
> > On Sun, Oct 21, 2018 at 10:29 AM Jeff Layton <jlayton@kernel.org> wrote=
:
> > >
> > > On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > > > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > >
> > > > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > > ---
> > > >  fs/read_write.c | 3 +++
> > > >  1 file changed, 3 insertions(+)
> > > >
> > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > index 39b4a21..c60790f 100644
> > > > --- a/fs/read_write.c
> > > > +++ b/fs/read_write.c
> > > > @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *file=
_in, loff_t pos_in,
> > > >       if (unlikely(ret))
> > > >               return ret;
> > > >
> > > > +     if (pos_in >=3D i_size_read(inode_in))
> > > > +             return -EINVAL;
> > > > +
> > > >       if (!(file_in->f_mode & FMODE_READ) ||
> > > >           !(file_out->f_mode & FMODE_WRITE) ||
> > > >           (file_out->f_flags & O_APPEND))
> > >
> > > The patch description could use a bit more fleshing-out. The
> > > copy_file_range manpage says:
> > >
> > >        EINVAL Requested range extends beyond the end of the source fi=
le; or the flags argument is not 0.
> > >
> > > So I guess this is intended to satisfy that requirement?
> >
> > I agree the description of the patch is poor. It sort of falls under
> > the the man page's description of range beyond the end of the source
> > file. But in NFSv4.2, there is an explicit wording for the validity of
> > the input parameters and having an input source offset that's beyond
> > the end of the file is what this patch is attempting to check.
> >
>
> Side note:
>
> One has to wonder why they decided to make that an -EINVAL condition?

To me that sounds like a correct use of -EINVAL error to check for
invalid arguments.

You can argue that since there were no bytes to copy then returning 0
would be an appropriate "size" of the copy. However, I would argue how
would a caller distinguish this 0 size which really means don't try to
copy more vs another case when copy_file_range() returned less byte
(0) and so that caller should loop to get the rest.

> The system call returns ssize_t. Why not just return a fewer number of
> bytes in that situation?
>
> In fact, the RETURN VALUE section of the manpage says:
>
>        Upon successful completion, copy_file_range() will return the numb=
er of
>        bytes copied between files.  This could be less than the length  o=
rigi=E2=80=90
>        nally requested.
>
> Under what conditions would that occur that do not include the file
> being shorter than the range you wanted to copy?
>
> I wonder if we ought to lobby to get that changed.

Do you mean ask NFSv4.2 spec to be changed? I thought that's stuff is
"written in stone".

>
> > > If so,
> > > i_size_read is just going to return whatever is in inode->isize.
> > > Could a copy_file_range call end up getting issued to copy from a fil=
e
> > > that is already open on a range that it doesn't know about yet? i.e.
> > > where the inode cache has not yet been updated.
> >
> > I thought that with NFSv4 cache consistency, the inode->isize is
> > accurate. If previous open had a read delegation, any modification on
> > a server would trigger a CB_RECALL and the open for the copy offload
> > would retrieve the latest size. In case of no delegations, the open
> > retrieves the latest size and the call to copy_file_range() would have
> > an update size.
> >
>
> > It seems like that could on network filesystems (like NFS). Would this
> > > be better handled in ->copy_file_range instead, where the driver coul=
d
> > > make a better determination of the file size?
> >
> > I'm not opposed to moving the size check into the NFS's copy_file_size
> > (again in my opinion NFS attribute cache has the same file size as the
> > inode's size). I think the thought was that such check should be done
> > at the VFS layer as oppose to doing it by each of the file systems.
> >
> >
>
> The attribute cache is not revalidated before the i_size is fetched with
> i_size_read. You're just reading what happens to be in the in-memory
> inode structure. So both clients have the file open already, and neither
> has a delegation:
>
> client 1: fetches attributes from file and sees a size of 1000
> client 2: writes 20 bytes at offset 1000
> client 1: calls copy file range to copy 1020 bytes starting at offset 0
>
> If client1 didn't get an attribute update before the copy_file_range
> call came in, then it would still think the size was 1000 and fail the
> operation. It may even be many seconds before client1 sees the updated
> size.
>
> You could argue that we're not using locking here so you're just subject
> to normal open-to-close cache coherency behavior, but that's rather "not
> nice".

Yes I would argue that locking needs to be used. In case your
describing it is impossible to get an accurate file size. Even if the
client issues a GETATTR there is nothing prevents another client from
changing it right after that GETATTR was already replied to.

What nfscopy application does is it opens then file and then locks it
(as suggested by the spec), then calls the copy_file_range() system
call. You can argue (if we didn't get a delegation) that a file might
have been changed between the reply to the OPEN and the LOCK operation
and therefore, we should send another GETATTR just in case. To guard
against that, I can add a getattr call though I think it's an overkill
specially since linux server always grants us a read delegation.

> I think we probably ought to also push this check down into the
> filesystem operations as well, and have copy_file_range ensure that the
> attribute cache is updated. We're dealing with copy offload here so
> doing an extra GETATTR beforehand shouldn't be terribly costly.
> --
> Jeff Layton <jlayton@kernel.org>
>
