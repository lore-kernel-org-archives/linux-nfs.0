Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09750ECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:21:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AE9BA2082F
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:21:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GJaqA+3z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE9BA2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726949AbeJYDu4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Oct 2018 23:50:56 -0400
Received: from mail-vs1-f68.google.com ([209.85.217.68]:43127 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726433AbeJYDu4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2018 23:50:56 -0400
Received: by mail-vs1-f68.google.com with SMTP id k14so2028673vsm.10
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2018 12:21:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=gcet7PGdo3L1SljB5/VcYb1rUnUnmx8Gr2pVmA2nH2Q=;
        b=GJaqA+3zXX8C0SLWS1KtM4Dr0GEYNRpxTtGbh1v89Pr3yGRtUDhyaKCv+JcfLqHTSJ
         ymkrlfBaISok4iQq/HY/H6ofNwbmg3fZysbTbccWWKPABP/ngBCQuawj7dfjq0esNj3O
         dX8pN465g2+OOg+SOKWLiunHZRvLor1P2WXJWHK0eqxoVA0vXO66jm5FormHJvkkMBd8
         97fvs5WIOtqRRcoFXWv1r6p64Z5pTMAh0WKRBzXgX+rxuRPL+OUaQPZGZIhmyD+o2Dwu
         bBIININ5wryALDovcltdGQH7Xt40GuyjpBNcROS5VniulKTeYnctDtBoP4Bc7ZDHHmKK
         MCig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=gcet7PGdo3L1SljB5/VcYb1rUnUnmx8Gr2pVmA2nH2Q=;
        b=ZV3HNncHJMM6KVUKh5acovQZCl67YKIvHTBZ7Mg8q8YLK6OnoH5SPT8JD3gSKwzfcA
         rL3bxZ3qD9mft9ysLSP53NW1oVluBrOB887iOxM+nHugWLrM+kbmjR3B9WPqLX8ZbUW+
         jJx1bw7isrJ1Norhv69/S0ACFSXKOKroqJAWhQI810KRSgK+Cv1mqoovwIzt6FBys3/n
         q+EHUK2ZeKG4Z46AzXT/w6GLYsMNwKU0fVgfez0mk1rL0RvgFk3xZJUKOB2XugqauGEq
         QShOMcHS0nC9uhbFhcqXRt3RQ0lIJ/afXfS//OCRw7clSiTU8PhoUdm+Ilh0mR8wL1gQ
         jbxA==
X-Gm-Message-State: AGRZ1gJeXzMJ0jxtFdZZx+lIdsimLylRY5CQ1I0j3fXyjj/yBAF180gv
        QaK0oE0LMWR3vSp1GGcSff6KckbE9AoFpQbSNp/tZA==
X-Google-Smtp-Source: AJdET5cM/XZdUDWPpcluZeKnsc4OY5tlAy7vZdWzGNhct4E+EEXEwpJQDeVx8tZK1r+riK03JWKd+6mUV7IhGKv0nzQ=
X-Received: by 2002:a67:a858:: with SMTP id r85mr1361485vse.215.1540408896428;
 Wed, 24 Oct 2018 12:21:36 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
 <20181019152932.32462-2-olga.kornievskaia@gmail.com> <fc9619bee3e27d6756ecff9ae143c646d2567b62.camel@kernel.org>
 <CAN-5tyEbGmujqD5Q1FBH9uBWR0YYbW_ojBhdbcD_7TYV9dqMag@mail.gmail.com>
 <1c269f7a09c24638ed3105b1fc934ca2c25383c9.camel@kernel.org>
 <CAN-5tyFW0JRFiEo78bHS97e_7-+POSbfhci0_mcQsQoi-YjNPQ@mail.gmail.com>
 <0b8e3d09268821c286fa3ed58994e325de79ba0f.camel@kernel.org>
 <CAN-5tyEpLmwYuUwftCaLf1byvTzABL2hOUdrij0yO9JpGiYz=g@mail.gmail.com> <CAN-5tyEmoTY9HCrhmOoPZ+KmfuFoM-PF90WByW0_8u=ABSDcRw@mail.gmail.com>
In-Reply-To: <CAN-5tyEmoTY9HCrhmOoPZ+KmfuFoM-PF90WByW0_8u=ABSDcRw@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 24 Oct 2018 15:21:24 -0400
Message-ID: <CAN-5tyFVSOeaC_g6b4ogUaw9QAMtKn===RKQ+x2Tw-LkJ61OnA@mail.gmail.com>
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

On Wed, Oct 24, 2018 at 2:53 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Wed, Oct 24, 2018 at 11:59 AM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > On Wed, Oct 24, 2018 at 7:09 AM Jeff Layton <jlayton@kernel.org> wrote:
> > >
> > > On Tue, 2018-10-23 at 12:50 -0400, Olga Kornievskaia wrote:
> > > > On Mon, Oct 22, 2018 at 7:23 PM Jeff Layton <jlayton@kernel.org> wr=
ote:
> > > > >
> > > > > On Mon, 2018-10-22 at 14:32 -0400, Olga Kornievskaia wrote:
> > > > > > On Sun, Oct 21, 2018 at 10:29 AM Jeff Layton <jlayton@kernel.or=
g> wrote:
> > > > > > >
> > > > > > > On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > > > > > > > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > > > > > >
> > > > > > > > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > > > > > > ---
> > > > > > > >  fs/read_write.c | 3 +++
> > > > > > > >  1 file changed, 3 insertions(+)
> > > > > > > >
> > > > > > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > > > > > index 39b4a21..c60790f 100644
> > > > > > > > --- a/fs/read_write.c
> > > > > > > > +++ b/fs/read_write.c
> > > > > > > > @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct fi=
le *file_in, loff_t pos_in,
> > > > > > > >       if (unlikely(ret))
> > > > > > > >               return ret;
> > > > > > > >
> > > > > > > > +     if (pos_in >=3D i_size_read(inode_in))
> > > > > > > > +             return -EINVAL;
> > > > > > > > +
> > > > > > > >       if (!(file_in->f_mode & FMODE_READ) ||
> > > > > > > >           !(file_out->f_mode & FMODE_WRITE) ||
> > > > > > > >           (file_out->f_flags & O_APPEND))
> > > > > > >
> > > > > > > The patch description could use a bit more fleshing-out. The
> > > > > > > copy_file_range manpage says:
> > > > > > >
> > > > > > >        EINVAL Requested range extends beyond the end of the s=
ource file; or the flags argument is not 0.
> > > > > > >
> > > > > > > So I guess this is intended to satisfy that requirement?
> > > > > >
> > > > > > I agree the description of the patch is poor. It sort of falls =
under
> > > > > > the the man page's description of range beyond the end of the s=
ource
> > > > > > file. But in NFSv4.2, there is an explicit wording for the vali=
dity of
> > > > > > the input parameters and having an input source offset that's b=
eyond
> > > > > > the end of the file is what this patch is attempting to check.
> > > > > >
> > > > >
> > > > > Side note:
> > > > >
> > > > > One has to wonder why they decided to make that an -EINVAL condit=
ion?
> > > >
> > > > To me that sounds like a correct use of -EINVAL error to check for
> > > > invalid arguments.
> > > >
> > > > You can argue that since there were no bytes to copy then returning=
 0
> > > > would be an appropriate "size" of the copy. However, I would argue =
how
> > > > would a caller distinguish this 0 size which really means don't try=
 to
> > > > copy more vs another case when copy_file_range() returned less byte
> > > > (0) and so that caller should loop to get the rest.
> > > >
> > >
> > > I don't know -- it seems to run contrary to how read(2) and write(2)
> >
> > That's because copy_file_range is not just read/write but also lseek.
> > I think of it as doing lseek(to source offset)->read()->lseek(to dst
> > offset)->write. and lseek() does return EINVAL when position is beyond
> > the end of the file.
> >
> > > work with an EOF condition. I don't see why the implementation wouldn=
't
> > > want to just copy what you can up to the EOF of the source file. Mayb=
e I
> > > need to go back and review the discussion from when the syscall was
> > > merged...
> >
> > >
> > > > > The system call returns ssize_t. Why not just return a fewer numb=
er of
> > > > > bytes in that situation?
> > > > >
> > > > > In fact, the RETURN VALUE section of the manpage says:
> > > > >
> > > > >        Upon successful completion, copy_file_range() will return =
the number of
> > > > >        bytes copied between files.  This could be less than the l=
ength  origi=E2=80=90
> > > > >        nally requested.
> > > > >
> > > > > Under what conditions would that occur that do not include the fi=
le
> > > > > being shorter than the range you wanted to copy?
> > > > >
> > > > > I wonder if we ought to lobby to get that changed.
> > > >
> > > > Do you mean ask NFSv4.2 spec to be changed? I thought that's stuff =
is
> > > > "written in stone".
> > > >
> > >
> > > No, I meant the copy_file_range spec (such as it is). I guess the v4.=
2
> > > spec has this though:
> > >
> > >    If the source offset or the source offset plus count is greater th=
an
> > >    the size of the source file, the operation MUST fail with
> > >    NFS4ERR_INVAL.
> > >
> > > I wonder if you'd be better off not trying to enforce this on the cli=
ent
> > > and simply let the server return NFS4ERR_INVAL if we're beyond EOF on
> > > the source? That way it doesn't matter whether the client's attr cach=
e
> > > is up to date or not.
> > >
> > > > >
> > > > > > > If so,
> > > > > > > i_size_read is just going to return whatever is in inode->isi=
ze.
> > > > > > > Could a copy_file_range call end up getting issued to copy fr=
om a file
> > > > > > > that is already open on a range that it doesn't know about ye=
t? i.e.
> > > > > > > where the inode cache has not yet been updated.
> > > > > >
> > > > > > I thought that with NFSv4 cache consistency, the inode->isize i=
s
> > > > > > accurate. If previous open had a read delegation, any modificat=
ion on
> > > > > > a server would trigger a CB_RECALL and the open for the copy of=
fload
> > > > > > would retrieve the latest size. In case of no delegations, the =
open
> > > > > > retrieves the latest size and the call to copy_file_range() wou=
ld have
> > > > > > an update size.
> > > > > >
> > > > > > It seems like that could on network filesystems (like NFS). Wou=
ld this
> > > > > > > be better handled in ->copy_file_range instead, where the dri=
ver could
> > > > > > > make a better determination of the file size?
> > > > > >
> > > > > > I'm not opposed to moving the size check into the NFS's copy_fi=
le_size
> > > > > > (again in my opinion NFS attribute cache has the same file size=
 as the
> > > > > > inode's size). I think the thought was that such check should b=
e done
> > > > > > at the VFS layer as oppose to doing it by each of the file syst=
ems.
> > > > > >
> > > > > >
> > > > >
> > > > > The attribute cache is not revalidated before the i_size is fetch=
ed with
> > > > > i_size_read. You're just reading what happens to be in the in-mem=
ory
> > > > > inode structure. So both clients have the file open already, and =
neither
> > > > > has a delegation:
> > > > >
> > > > > client 1: fetches attributes from file and sees a size of 1000
> > > > > client 2: writes 20 bytes at offset 1000
> > > > > client 1: calls copy file range to copy 1020 bytes starting at of=
fset 0
> > > > >
> > > > > If client1 didn't get an attribute update before the copy_file_ra=
nge
> > > > > call came in, then it would still think the size was 1000 and fai=
l the
> > > > > operation. It may even be many seconds before client1 sees the up=
dated
> > > > > size.
> > > > >
> > > > > You could argue that we're not using locking here so you're just =
subject
> > > > > to normal open-to-close cache coherency behavior, but that's rath=
er "not
> > > > > nice".
> > > >
> > > > Yes I would argue that locking needs to be used. In case your
> > > > describing it is impossible to get an accurate file size. Even if t=
he
> > > > client issues a GETATTR there is nothing prevents another client fr=
om
> > > > changing it right after that GETATTR was already replied to.
> > > >
> > > > What nfscopy application does is it opens then file and then locks =
it
> > > > (as suggested by the spec), then calls the copy_file_range() system
> > > > call. You can argue (if we didn't get a delegation) that a file mig=
ht
> > > > have been changed between the reply to the OPEN and the LOCK operat=
ion
> > > > and therefore, we should send another GETATTR just in case. To guar=
d
> > > > against that, I can add a getattr call though I think it's an overk=
ill
> > > > specially since linux server always grants us a read delegation.
> > > >
> > >
> > > The spec does say you might need to lock the files but they don't say
> > > you SHOULD, only that servers need to be able to deal with lock
> > > stateids.  hat said, you have a good point. We're not violating anyth=
ing
> > > by not revalidating the cache beforehand. Maybe we don't need to do t=
his
> > > after all.
> > >
> > > Personally, I think this would be best enforced by the NFS server. Ju=
st
> > > fire off the COPY request as-is and let the server vet the lengths.
> > >
> > > Side note: a delegation is never guaranteed. knfsd won't grant one if
> > > the inode falls afoul of the bloom filter, for instance, and that can
> > > easily happen if (for example) there is a hash collision between
> > > different inodes.
> >
> > I could push the checking validity of the arguments to the server (but
> > to me it sounds lame: a failure will require a network roundtrip). But
> > one can argue the server needs to check the validity of the arguments
> > anyway (as it can't rely on the client to play nice).
> >
> > I still think the check should be done in both places (client and
> > server). And I feel like VFS is the right place to do so (as this
> > check implements what the man page states). But I don't feel strongly
> > about dropping the patch all together (I'll add a patch to the
> > server).
>
> To add to my case, would it be acceptable to add a check *same as*
> it's done for the vfs_clone_file_range()
> pos_in+len > i_size_read() return EINVAL.

Sigh. this is not what we want either because in previous discussion,
it was agreed that it would be beneficial to just return however much
the copy could do.

The problem is that copy doesn't spell out that copy of size 0 means
"end of copy" like an EOF. So either that needs to agreed upon and
then receiving size 0 would indicate stopping. However, if return of
size 0 copy isn't signaling an end, then we need to enforce if (pos_in
> i_size_read()) EINVAL check.

Question to the community: should the semantics of copy_file_range()
be clarified to give return of 0 a significance?

> knfsd just calls in to the vfs to do the copy_file_range when it
> receives it, so these checks should be a part of the VFS.
>
> > > > > I think we probably ought to also push this check down into the
> > > > > filesystem operations as well, and have copy_file_range ensure th=
at the
> > > > > attribute cache is updated. We're dealing with copy offload here =
so
> > > > > doing an extra GETATTR beforehand shouldn't be terribly costly.
> > > > > --
> > > > > Jeff Layton <jlayton@kernel.org>
> > >
> > > --
> > > Jeff Layton <jlayton@kernel.org>
> > >
