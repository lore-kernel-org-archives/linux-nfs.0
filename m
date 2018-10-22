Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 286FEC004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 18:33:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1A27F20652
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 18:33:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PjBXg62B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A27F20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728524AbeJWCwt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 22:52:49 -0400
Received: from mail-vk1-f194.google.com ([209.85.221.194]:43907 "EHLO
        mail-vk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727218AbeJWCwt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 22:52:49 -0400
Received: by mail-vk1-f194.google.com with SMTP id q7so2653753vke.10
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2018 11:33:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YgagM8sRCR7S5r7nifQ1QdP1ijaTXUlxjGuwYfsBF94=;
        b=PjBXg62BtvLVFlcRc/ygAAnBvf27WRWVj8I/AfVyFcOCwmkbaKBd69DrNY3nwAZa0B
         azNEH3Nj0+wCcN2PLFFqOBxuhMlS3vSjS+4MhANN0Juk38+hWLjU5kHY9QBGQ2ZAKrEf
         Ig7Ae0tI3F5i3fKEftUNeHbKbiP0gH6zIxoVECbHldqoab/aRqZfjTcti27saIByPZU5
         LAlo47TcIprOKmw9q225emobvhlnIW0p60Lz1uwItMuWlwTUKIBWFqloVL0lYmXV37t/
         oTNMya/CjVZibDUtWUK+CzLDNF02knqwjubX2+p8kHZkaLJsjqY1CKsJ9/CmaHff4dVa
         zkvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=YgagM8sRCR7S5r7nifQ1QdP1ijaTXUlxjGuwYfsBF94=;
        b=h/RFxlRH5Xt7Z1RnS8jCXJMc7r+99Ia4X2zoYShzcQUg89WszwTPAj0yOzFSMScesH
         ACQE01tjGB5Mms3EiVBxb5RkBZU5N7bkuaK0Cu054nII5DL65ij7W4rQ79bmh20kUnpr
         /5g/bwO0x/bXqU8HlQ/JBg8Epw0X6dN5yjnSSBwpKCqznG2sJTQTpiMux3NRpn4iSShO
         oqjddykelK6ItYGhpA/jBSX5IaYRwt/tRi1RZ43pS0JvoIzegr3BvwU3YS/FbLQPjMCr
         krR33th8FgrZSlcyH6rQbacJiGBJnLWybY9O27EcHA9E+Q2mfGPtSEbii0phFaO8dvOQ
         vYtw==
X-Gm-Message-State: ABuFfog35xGq9nIyTRh1rSvUJ7qUntCpIqVG/ku/iCFCULusCB/pdPw3
        oTxg2RSnOfOfdRbJO6SKAqTJo1K2cNK+BGk5bvkV5w==
X-Google-Smtp-Source: ACcGV60b49gbgEec7cPXvrlSjXNiqKpX0sgYVZNITJDmKapOfJKBaKuMHGd3m3rwd6lb1VkeilBhBU7+6SzbYwzy9AI=
X-Received: by 2002:a1f:5503:: with SMTP id j3-v6mr19178075vkb.34.1540233190308;
 Mon, 22 Oct 2018 11:33:10 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
 <20181019152932.32462-2-olga.kornievskaia@gmail.com> <fc9619bee3e27d6756ecff9ae143c646d2567b62.camel@kernel.org>
In-Reply-To: <fc9619bee3e27d6756ecff9ae143c646d2567b62.camel@kernel.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 22 Oct 2018 14:32:58 -0400
Message-ID: <CAN-5tyEbGmujqD5Q1FBH9uBWR0YYbW_ojBhdbcD_7TYV9dqMag@mail.gmail.com>
Subject: Re: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
To:     jlayton@kernel.org
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Oct 21, 2018 at 10:29 AM Jeff Layton <jlayton@kernel.org> wrote:
>
> On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> >
> > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > ---
> >  fs/read_write.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 39b4a21..c60790f 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >       if (unlikely(ret))
> >               return ret;
> >
> > +     if (pos_in >= i_size_read(inode_in))
> > +             return -EINVAL;
> > +
> >       if (!(file_in->f_mode & FMODE_READ) ||
> >           !(file_out->f_mode & FMODE_WRITE) ||
> >           (file_out->f_flags & O_APPEND))
>
> The patch description could use a bit more fleshing-out. The
> copy_file_range manpage says:
>
>        EINVAL Requested range extends beyond the end of the source file; or the flags argument is not 0.
>
> So I guess this is intended to satisfy that requirement?

I agree the description of the patch is poor. It sort of falls under
the the man page's description of range beyond the end of the source
file. But in NFSv4.2, there is an explicit wording for the validity of
the input parameters and having an input source offset that's beyond
the end of the file is what this patch is attempting to check.

> If so,
> i_size_read is just going to return whatever is in inode->isize.

> Could a copy_file_range call end up getting issued to copy from a file
> that is already open on a range that it doesn't know about yet? i.e.
> where the inode cache has not yet been updated.

I thought that with NFSv4 cache consistency, the inode->isize is
accurate. If previous open had a read delegation, any modification on
a server would trigger a CB_RECALL and the open for the copy offload
would retrieve the latest size. In case of no delegations, the open
retrieves the latest size and the call to copy_file_range() would have
an update size.

> It seems like that could on network filesystems (like NFS). Would this
> be better handled in ->copy_file_range instead, where the driver could
> make a better determination of the file size?

I'm not opposed to moving the size check into the NFS's copy_file_size
(again in my opinion NFS attribute cache has the same file size as the
inode's size). I think the thought was that such check should be done
at the VFS layer as oppose to doing it by each of the file systems.

> --
> Jeff Layton <jlayton@kernel.org>
>
