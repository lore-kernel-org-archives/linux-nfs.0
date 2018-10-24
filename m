Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 065A8C004D3
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 16:00:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A918C205F4
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 16:00:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xo1GIU1o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A918C205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726809AbeJYA2h (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Oct 2018 20:28:37 -0400
Received: from mail-vs1-f68.google.com ([209.85.217.68]:38931 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726577AbeJYA2h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2018 20:28:37 -0400
Received: by mail-vs1-f68.google.com with SMTP id u21so2808362vsl.6
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2018 08:59:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Iwu/KqFG+0qbFOmblT9Z/0y9M2mnazIN4HJLwKh07og=;
        b=Xo1GIU1opXzrUo92TEDKH8qGvEj04pSRGXZ2uU7qyP85D+WZqCw0FCJ/rAI33ftwmh
         bu5RwFttB3RXdiP1xzIYqTPWVo0QC0Y5ykRMJq6EaGkqPZ+grTLc77AbC2hBaCin4hUp
         bDO97+QEi/s4FBRQw9LxWzYtYwSYmprnJWS3lFSYYKiYtJXSdpByd+TZ9tu1xoen1/SZ
         GTynOv5W2DbWAvp1Z3kf+ytq4ttBeZ5VS6aFXjr9JeH7AEZEQKRWc8kYmj1ZVPvCXuXM
         p6yzcWPeui6tr7Ti3aLF68dMSjNrlqlaz8bjmy0S1oJeffzPWfT015gwVBd6shQumzey
         iBIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=Iwu/KqFG+0qbFOmblT9Z/0y9M2mnazIN4HJLwKh07og=;
        b=jhdCLeykz1nrpMlGz50xz+3FW0Yhi6/epTV8RhzDdkQzCq/RqMBpxD8o2fupEie/8V
         rYeGSpOLIsugl/nPl14Qt/UfyfDGmwR+Yq2m3kDGsn+5QCS36tAtT7cE8XBuxJvV2ART
         XPt3KIjdlbeX0P4wpdco3qJE0H5HWKdXxgVwb5if3pwN2J2kmVTA0FDQM8p1V1L6rLzm
         cKO9HFUMWP1jqiJXCndyKuegkOuSjb7ubYRld0URrU5FPSgyQRxlR6Fx7Bdhmq6lzzL5
         vlOByI5hCmV97cPDYwhF6QTkBkcrQu5A6f8AfFpFUA1Re0tp1Wc0uV/IMh/YeLhGQuru
         3ChQ==
X-Gm-Message-State: AGRZ1gI9Qmp0Y6T3VWa3A5Cje48kPz9Up/I8Eyiwhy2Jx4D9sHQ1NX7F
        hoUdb0h/HkG3uriRGTjN0ZZ0RHkxk3dtS2x6xOw=
X-Google-Smtp-Source: AJdET5frCTUu1pXGmT1WRzTbzXNmpr+50S/FJHEnRzg51oo/NdHrGtq3Y5nXns9ZyhTsuMdpPUF2A+SX1Kc5ABB4p4g=
X-Received: by 2002:a67:f441:: with SMTP id r1mr1416107vsn.164.1540396797888;
 Wed, 24 Oct 2018 08:59:57 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
 <20181019152932.32462-2-olga.kornievskaia@gmail.com> <fc9619bee3e27d6756ecff9ae143c646d2567b62.camel@kernel.org>
 <CAN-5tyEbGmujqD5Q1FBH9uBWR0YYbW_ojBhdbcD_7TYV9dqMag@mail.gmail.com>
 <1c269f7a09c24638ed3105b1fc934ca2c25383c9.camel@kernel.org>
 <CAN-5tyFW0JRFiEo78bHS97e_7-+POSbfhci0_mcQsQoi-YjNPQ@mail.gmail.com> <0b8e3d09268821c286fa3ed58994e325de79ba0f.camel@kernel.org>
In-Reply-To: <0b8e3d09268821c286fa3ed58994e325de79ba0f.camel@kernel.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 24 Oct 2018 11:59:45 -0400
Message-ID: <CAN-5tyEpLmwYuUwftCaLf1byvTzABL2hOUdrij0yO9JpGiYz=g@mail.gmail.com>
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

On Wed, Oct 24, 2018 at 7:09 AM Jeff Layton <jlayton@kernel.org> wrote:
>
> On Tue, 2018-10-23 at 12:50 -0400, Olga Kornievskaia wrote:
> > On Mon, Oct 22, 2018 at 7:23 PM Jeff Layton <jlayton@kernel.org> wrote:
> > >
> > > On Mon, 2018-10-22 at 14:32 -0400, Olga Kornievskaia wrote:
> > > > On Sun, Oct 21, 2018 at 10:29 AM Jeff Layton <jlayton@kernel.org> w=
rote:
> > > > >
> > > > > On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > > > > > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > > > >
> > > > > > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > > > > ---
> > > > > >  fs/read_write.c | 3 +++
> > > > > >  1 file changed, 3 insertions(+)
> > > > > >
> > > > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > > > index 39b4a21..c60790f 100644
> > > > > > --- a/fs/read_write.c
> > > > > > +++ b/fs/read_write.c
> > > > > > @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *=
file_in, loff_t pos_in,
> > > > > >       if (unlikely(ret))
> > > > > >               return ret;
> > > > > >
> > > > > > +     if (pos_in >=3D i_size_read(inode_in))
> > > > > > +             return -EINVAL;
> > > > > > +
> > > > > >       if (!(file_in->f_mode & FMODE_READ) ||
> > > > > >           !(file_out->f_mode & FMODE_WRITE) ||
> > > > > >           (file_out->f_flags & O_APPEND))
> > > > >
> > > > > The patch description could use a bit more fleshing-out. The
> > > > > copy_file_range manpage says:
> > > > >
> > > > >        EINVAL Requested range extends beyond the end of the sourc=
e file; or the flags argument is not 0.
> > > > >
> > > > > So I guess this is intended to satisfy that requirement?
> > > >
> > > > I agree the description of the patch is poor. It sort of falls unde=
r
> > > > the the man page's description of range beyond the end of the sourc=
e
> > > > file. But in NFSv4.2, there is an explicit wording for the validity=
 of
> > > > the input parameters and having an input source offset that's beyon=
d
> > > > the end of the file is what this patch is attempting to check.
> > > >
> > >
> > > Side note:
> > >
> > > One has to wonder why they decided to make that an -EINVAL condition?
> >
> > To me that sounds like a correct use of -EINVAL error to check for
> > invalid arguments.
> >
> > You can argue that since there were no bytes to copy then returning 0
> > would be an appropriate "size" of the copy. However, I would argue how
> > would a caller distinguish this 0 size which really means don't try to
> > copy more vs another case when copy_file_range() returned less byte
> > (0) and so that caller should loop to get the rest.
> >
>
> I don't know -- it seems to run contrary to how read(2) and write(2)

That's because copy_file_range is not just read/write but also lseek.
I think of it as doing lseek(to source offset)->read()->lseek(to dst
offset)->write. and lseek() does return EINVAL when position is beyond
the end of the file.

> work with an EOF condition. I don't see why the implementation wouldn't
> want to just copy what you can up to the EOF of the source file. Maybe I
> need to go back and review the discussion from when the syscall was
> merged...

>
> > > The system call returns ssize_t. Why not just return a fewer number o=
f
> > > bytes in that situation?
> > >
> > > In fact, the RETURN VALUE section of the manpage says:
> > >
> > >        Upon successful completion, copy_file_range() will return the =
number of
> > >        bytes copied between files.  This could be less than the lengt=
h  origi=E2=80=90
> > >        nally requested.
> > >
> > > Under what conditions would that occur that do not include the file
> > > being shorter than the range you wanted to copy?
> > >
> > > I wonder if we ought to lobby to get that changed.
> >
> > Do you mean ask NFSv4.2 spec to be changed? I thought that's stuff is
> > "written in stone".
> >
>
> No, I meant the copy_file_range spec (such as it is). I guess the v4.2
> spec has this though:
>
>    If the source offset or the source offset plus count is greater than
>    the size of the source file, the operation MUST fail with
>    NFS4ERR_INVAL.
>
> I wonder if you'd be better off not trying to enforce this on the client
> and simply let the server return NFS4ERR_INVAL if we're beyond EOF on
> the source? That way it doesn't matter whether the client's attr cache
> is up to date or not.
>
> > >
> > > > > If so,
> > > > > i_size_read is just going to return whatever is in inode->isize.
> > > > > Could a copy_file_range call end up getting issued to copy from a=
 file
> > > > > that is already open on a range that it doesn't know about yet? i=
.e.
> > > > > where the inode cache has not yet been updated.
> > > >
> > > > I thought that with NFSv4 cache consistency, the inode->isize is
> > > > accurate. If previous open had a read delegation, any modification =
on
> > > > a server would trigger a CB_RECALL and the open for the copy offloa=
d
> > > > would retrieve the latest size. In case of no delegations, the open
> > > > retrieves the latest size and the call to copy_file_range() would h=
ave
> > > > an update size.
> > > >
> > > > It seems like that could on network filesystems (like NFS). Would t=
his
> > > > > be better handled in ->copy_file_range instead, where the driver =
could
> > > > > make a better determination of the file size?
> > > >
> > > > I'm not opposed to moving the size check into the NFS's copy_file_s=
ize
> > > > (again in my opinion NFS attribute cache has the same file size as =
the
> > > > inode's size). I think the thought was that such check should be do=
ne
> > > > at the VFS layer as oppose to doing it by each of the file systems.
> > > >
> > > >
> > >
> > > The attribute cache is not revalidated before the i_size is fetched w=
ith
> > > i_size_read. You're just reading what happens to be in the in-memory
> > > inode structure. So both clients have the file open already, and neit=
her
> > > has a delegation:
> > >
> > > client 1: fetches attributes from file and sees a size of 1000
> > > client 2: writes 20 bytes at offset 1000
> > > client 1: calls copy file range to copy 1020 bytes starting at offset=
 0
> > >
> > > If client1 didn't get an attribute update before the copy_file_range
> > > call came in, then it would still think the size was 1000 and fail th=
e
> > > operation. It may even be many seconds before client1 sees the update=
d
> > > size.
> > >
> > > You could argue that we're not using locking here so you're just subj=
ect
> > > to normal open-to-close cache coherency behavior, but that's rather "=
not
> > > nice".
> >
> > Yes I would argue that locking needs to be used. In case your
> > describing it is impossible to get an accurate file size. Even if the
> > client issues a GETATTR there is nothing prevents another client from
> > changing it right after that GETATTR was already replied to.
> >
> > What nfscopy application does is it opens then file and then locks it
> > (as suggested by the spec), then calls the copy_file_range() system
> > call. You can argue (if we didn't get a delegation) that a file might
> > have been changed between the reply to the OPEN and the LOCK operation
> > and therefore, we should send another GETATTR just in case. To guard
> > against that, I can add a getattr call though I think it's an overkill
> > specially since linux server always grants us a read delegation.
> >
>
> The spec does say you might need to lock the files but they don't say
> you SHOULD, only that servers need to be able to deal with lock
> stateids.  hat said, you have a good point. We're not violating anything
> by not revalidating the cache beforehand. Maybe we don't need to do this
> after all.
>
> Personally, I think this would be best enforced by the NFS server. Just
> fire off the COPY request as-is and let the server vet the lengths.
>
> Side note: a delegation is never guaranteed. knfsd won't grant one if
> the inode falls afoul of the bloom filter, for instance, and that can
> easily happen if (for example) there is a hash collision between
> different inodes.

I could push the checking validity of the arguments to the server (but
to me it sounds lame: a failure will require a network roundtrip). But
one can argue the server needs to check the validity of the arguments
anyway (as it can't rely on the client to play nice).

I still think the check should be done in both places (client and
server). And I feel like VFS is the right place to do so (as this
check implements what the man page states). But I don't feel strongly
about dropping the patch all together (I'll add a patch to the
server).

> > > I think we probably ought to also push this check down into the
> > > filesystem operations as well, and have copy_file_range ensure that t=
he
> > > attribute cache is updated. We're dealing with copy offload here so
> > > doing an extra GETATTR beforehand shouldn't be terribly costly.
> > > --
> > > Jeff Layton <jlayton@kernel.org>
>
> --
> Jeff Layton <jlayton@kernel.org>
>
