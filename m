Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8BC1ECDE46
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 18:54:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9BFAC207DD
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 18:54:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p9uA9paN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BFAC207DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727416AbeJYDXZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Oct 2018 23:23:25 -0400
Received: from mail-vk1-f193.google.com ([209.85.221.193]:33511 "EHLO
        mail-vk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726748AbeJYDXZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2018 23:23:25 -0400
Received: by mail-vk1-f193.google.com with SMTP id l186so1531842vke.0
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2018 11:54:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ac664+bWkwMDS6z7sLaaBzt4hZx9t/RWEoaV/v/MaYY=;
        b=p9uA9paN0UjepXttp9sGPGtmfuWK5XllQi+1QFCpUbEdz6jEbz9iR3kyRc9ULp0xlp
         gHsaKK5IYkS0V/jpfuMivZPNSLr0eATpdGtasBXmFUKfRP5iiURuk7JOPy4Pfqt5zbqc
         hf73ZsD2Kq6ufKfWAQgSXhkow5Pcthj+7sMQAqf2mHnhvc3IDofRPB5csn51lHR+3LKd
         mT2VK7FUXF8IFmg4HxQVaPC5LhMhrEcguIM/xm6lfeu6xcMiUkqQa6qT7x9ETxzS+uZt
         Zknm/+w5FzPf6pwQrVMk7dnOq4ZsPwxLVomEJnFpQ6IF/En+2MiEkm5hHzdTCZYrzoJi
         B9Eg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=ac664+bWkwMDS6z7sLaaBzt4hZx9t/RWEoaV/v/MaYY=;
        b=LwBBWfhHA9vpo1ZzhL19cgWFgLnk5iQPIRN7eUe+mRYamiincO7eHwL+yjCB7FAM9H
         0QgDI3dgG/ay5SUFXUT9sdssh3+epOVDR4CnLO3zoHtz9Fq8g81j+Vw9DpTmhMsBB0Gu
         0XEMkEzF+oDm9o6tc7wXzx21gzBFV5sfQPf1t21088TWQ6nxdpRyEcXySVWfRbHNprmz
         AWsYz+/M2er3nsQtLOsTtYgaNBercx+atd2IR5CpEDIvr6g754c2HG0fdBSaTe7hQ3kr
         QHoFIzUpy7InpTP5Y2ypI92ok3cI+dMw8NdoHcyuLNi0asEt3VRImp6U9KYWHkY5zuhO
         P6/A==
X-Gm-Message-State: AGRZ1gLlUuPd2UljdtnH7i1CwLdop1Mq2M0PK3lJZ7sObwHJkOPIoABd
        Ksc91O+5ZOZuKOJkOtf6rEpB6sV2UXXeQVrEX+1sbA==
X-Google-Smtp-Source: AJdET5f/AC5siqEZk+cCvLxRAUMkaAemt2PxUZVEKenVUdiORS+5CvLmuaUzGJYtR+oliRgN49f6av6/CP8kHerv8pg=
X-Received: by 2002:a1f:1a83:: with SMTP id a125-v6mr1747269vka.83.1540407251967;
 Wed, 24 Oct 2018 11:54:11 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
 <20181019152932.32462-2-olga.kornievskaia@gmail.com> <fc9619bee3e27d6756ecff9ae143c646d2567b62.camel@kernel.org>
 <CAN-5tyEbGmujqD5Q1FBH9uBWR0YYbW_ojBhdbcD_7TYV9dqMag@mail.gmail.com>
 <1c269f7a09c24638ed3105b1fc934ca2c25383c9.camel@kernel.org>
 <CAN-5tyFW0JRFiEo78bHS97e_7-+POSbfhci0_mcQsQoi-YjNPQ@mail.gmail.com>
 <0b8e3d09268821c286fa3ed58994e325de79ba0f.camel@kernel.org> <CAN-5tyEpLmwYuUwftCaLf1byvTzABL2hOUdrij0yO9JpGiYz=g@mail.gmail.com>
In-Reply-To: <CAN-5tyEpLmwYuUwftCaLf1byvTzABL2hOUdrij0yO9JpGiYz=g@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 24 Oct 2018 14:53:59 -0400
Message-ID: <CAN-5tyEmoTY9HCrhmOoPZ+KmfuFoM-PF90WByW0_8u=ABSDcRw@mail.gmail.com>
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

On Wed, Oct 24, 2018 at 11:59 AM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Wed, Oct 24, 2018 at 7:09 AM Jeff Layton <jlayton@kernel.org> wrote:
> >
> > On Tue, 2018-10-23 at 12:50 -0400, Olga Kornievskaia wrote:
> > > On Mon, Oct 22, 2018 at 7:23 PM Jeff Layton <jlayton@kernel.org> wrot=
e:
> > > >
> > > > On Mon, 2018-10-22 at 14:32 -0400, Olga Kornievskaia wrote:
> > > > > On Sun, Oct 21, 2018 at 10:29 AM Jeff Layton <jlayton@kernel.org>=
 wrote:
> > > > > >
> > > > > > On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > > > > > > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > > > > >
> > > > > > > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > > > > > ---
> > > > > > >  fs/read_write.c | 3 +++
> > > > > > >  1 file changed, 3 insertions(+)
> > > > > > >
> > > > > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > > > > index 39b4a21..c60790f 100644
> > > > > > > --- a/fs/read_write.c
> > > > > > > +++ b/fs/read_write.c
> > > > > > > @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file=
 *file_in, loff_t pos_in,
> > > > > > >       if (unlikely(ret))
> > > > > > >               return ret;
> > > > > > >
> > > > > > > +     if (pos_in >=3D i_size_read(inode_in))
> > > > > > > +             return -EINVAL;
> > > > > > > +
> > > > > > >       if (!(file_in->f_mode & FMODE_READ) ||
> > > > > > >           !(file_out->f_mode & FMODE_WRITE) ||
> > > > > > >           (file_out->f_flags & O_APPEND))
> > > > > >
> > > > > > The patch description could use a bit more fleshing-out. The
> > > > > > copy_file_range manpage says:
> > > > > >
> > > > > >        EINVAL Requested range extends beyond the end of the sou=
rce file; or the flags argument is not 0.
> > > > > >
> > > > > > So I guess this is intended to satisfy that requirement?
> > > > >
> > > > > I agree the description of the patch is poor. It sort of falls un=
der
> > > > > the the man page's description of range beyond the end of the sou=
rce
> > > > > file. But in NFSv4.2, there is an explicit wording for the validi=
ty of
> > > > > the input parameters and having an input source offset that's bey=
ond
> > > > > the end of the file is what this patch is attempting to check.
> > > > >
> > > >
> > > > Side note:
> > > >
> > > > One has to wonder why they decided to make that an -EINVAL conditio=
n?
> > >
> > > To me that sounds like a correct use of -EINVAL error to check for
> > > invalid arguments.
> > >
> > > You can argue that since there were no bytes to copy then returning 0
> > > would be an appropriate "size" of the copy. However, I would argue ho=
w
> > > would a caller distinguish this 0 size which really means don't try t=
o
> > > copy more vs another case when copy_file_range() returned less byte
> > > (0) and so that caller should loop to get the rest.
> > >
> >
> > I don't know -- it seems to run contrary to how read(2) and write(2)
>
> That's because copy_file_range is not just read/write but also lseek.
> I think of it as doing lseek(to source offset)->read()->lseek(to dst
> offset)->write. and lseek() does return EINVAL when position is beyond
> the end of the file.
>
> > work with an EOF condition. I don't see why the implementation wouldn't
> > want to just copy what you can up to the EOF of the source file. Maybe =
I
> > need to go back and review the discussion from when the syscall was
> > merged...
>
> >
> > > > The system call returns ssize_t. Why not just return a fewer number=
 of
> > > > bytes in that situation?
> > > >
> > > > In fact, the RETURN VALUE section of the manpage says:
> > > >
> > > >        Upon successful completion, copy_file_range() will return th=
e number of
> > > >        bytes copied between files.  This could be less than the len=
gth  origi=E2=80=90
> > > >        nally requested.
> > > >
> > > > Under what conditions would that occur that do not include the file
> > > > being shorter than the range you wanted to copy?
> > > >
> > > > I wonder if we ought to lobby to get that changed.
> > >
> > > Do you mean ask NFSv4.2 spec to be changed? I thought that's stuff is
> > > "written in stone".
> > >
> >
> > No, I meant the copy_file_range spec (such as it is). I guess the v4.2
> > spec has this though:
> >
> >    If the source offset or the source offset plus count is greater than
> >    the size of the source file, the operation MUST fail with
> >    NFS4ERR_INVAL.
> >
> > I wonder if you'd be better off not trying to enforce this on the clien=
t
> > and simply let the server return NFS4ERR_INVAL if we're beyond EOF on
> > the source? That way it doesn't matter whether the client's attr cache
> > is up to date or not.
> >
> > > >
> > > > > > If so,
> > > > > > i_size_read is just going to return whatever is in inode->isize=
.
> > > > > > Could a copy_file_range call end up getting issued to copy from=
 a file
> > > > > > that is already open on a range that it doesn't know about yet?=
 i.e.
> > > > > > where the inode cache has not yet been updated.
> > > > >
> > > > > I thought that with NFSv4 cache consistency, the inode->isize is
> > > > > accurate. If previous open had a read delegation, any modificatio=
n on
> > > > > a server would trigger a CB_RECALL and the open for the copy offl=
oad
> > > > > would retrieve the latest size. In case of no delegations, the op=
en
> > > > > retrieves the latest size and the call to copy_file_range() would=
 have
> > > > > an update size.
> > > > >
> > > > > It seems like that could on network filesystems (like NFS). Would=
 this
> > > > > > be better handled in ->copy_file_range instead, where the drive=
r could
> > > > > > make a better determination of the file size?
> > > > >
> > > > > I'm not opposed to moving the size check into the NFS's copy_file=
_size
> > > > > (again in my opinion NFS attribute cache has the same file size a=
s the
> > > > > inode's size). I think the thought was that such check should be =
done
> > > > > at the VFS layer as oppose to doing it by each of the file system=
s.
> > > > >
> > > > >
> > > >
> > > > The attribute cache is not revalidated before the i_size is fetched=
 with
> > > > i_size_read. You're just reading what happens to be in the in-memor=
y
> > > > inode structure. So both clients have the file open already, and ne=
ither
> > > > has a delegation:
> > > >
> > > > client 1: fetches attributes from file and sees a size of 1000
> > > > client 2: writes 20 bytes at offset 1000
> > > > client 1: calls copy file range to copy 1020 bytes starting at offs=
et 0
> > > >
> > > > If client1 didn't get an attribute update before the copy_file_rang=
e
> > > > call came in, then it would still think the size was 1000 and fail =
the
> > > > operation. It may even be many seconds before client1 sees the upda=
ted
> > > > size.
> > > >
> > > > You could argue that we're not using locking here so you're just su=
bject
> > > > to normal open-to-close cache coherency behavior, but that's rather=
 "not
> > > > nice".
> > >
> > > Yes I would argue that locking needs to be used. In case your
> > > describing it is impossible to get an accurate file size. Even if the
> > > client issues a GETATTR there is nothing prevents another client from
> > > changing it right after that GETATTR was already replied to.
> > >
> > > What nfscopy application does is it opens then file and then locks it
> > > (as suggested by the spec), then calls the copy_file_range() system
> > > call. You can argue (if we didn't get a delegation) that a file might
> > > have been changed between the reply to the OPEN and the LOCK operatio=
n
> > > and therefore, we should send another GETATTR just in case. To guard
> > > against that, I can add a getattr call though I think it's an overkil=
l
> > > specially since linux server always grants us a read delegation.
> > >
> >
> > The spec does say you might need to lock the files but they don't say
> > you SHOULD, only that servers need to be able to deal with lock
> > stateids.  hat said, you have a good point. We're not violating anythin=
g
> > by not revalidating the cache beforehand. Maybe we don't need to do thi=
s
> > after all.
> >
> > Personally, I think this would be best enforced by the NFS server. Just
> > fire off the COPY request as-is and let the server vet the lengths.
> >
> > Side note: a delegation is never guaranteed. knfsd won't grant one if
> > the inode falls afoul of the bloom filter, for instance, and that can
> > easily happen if (for example) there is a hash collision between
> > different inodes.
>
> I could push the checking validity of the arguments to the server (but
> to me it sounds lame: a failure will require a network roundtrip). But
> one can argue the server needs to check the validity of the arguments
> anyway (as it can't rely on the client to play nice).
>
> I still think the check should be done in both places (client and
> server). And I feel like VFS is the right place to do so (as this
> check implements what the man page states). But I don't feel strongly
> about dropping the patch all together (I'll add a patch to the
> server).

To add to my case, would it be acceptable to add a check *same as*
it's done for the vfs_clone_file_range()
pos_in+len > i_size_read() return EINVAL.

knfsd just calls in to the vfs to do the copy_file_range when it
receives it, so these checks should be a part of the VFS.

> > > > I think we probably ought to also push this check down into the
> > > > filesystem operations as well, and have copy_file_range ensure that=
 the
> > > > attribute cache is updated. We're dealing with copy offload here so
> > > > doing an extra GETATTR beforehand shouldn't be terribly costly.
> > > > --
> > > > Jeff Layton <jlayton@kernel.org>
> >
> > --
> > Jeff Layton <jlayton@kernel.org>
> >
