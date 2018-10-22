Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCD5DC004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 23:23:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CFAF0205F4
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 23:23:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bSE0GySH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFAF0205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726073AbeJWHoL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 03:44:11 -0400
Received: from mail.kernel.org ([198.145.29.99]:52294 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725998AbeJWHoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Oct 2018 03:44:11 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 08168205F4;
        Mon, 22 Oct 2018 23:23:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1540250613;
        bh=1Yg9l2Lmmcp4TuT0gJXLUFaraL1vUBe+5ilPp/KJ70o=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=bSE0GySHfSvEb58LUcpvJVHydYPM7wMMYBT62qGueV7Sjw/hngjGyiMrHZvLUzv/v
         tyKdpEP8qRVnlk2eBFWF90MFmrNK8F740kYVWULb9k8kzRlxckzeavZqAemR+GitYZ
         7VtwbrIhnqdi/cevSpJXhacoJKXTRd++T34IwFno=
Message-ID: <1c269f7a09c24638ed3105b1fc934ca2c25383c9.camel@kernel.org>
Subject: Re: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
From:   Jeff Layton <jlayton@kernel.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date:   Mon, 22 Oct 2018 19:23:31 -0400
In-Reply-To: <CAN-5tyEbGmujqD5Q1FBH9uBWR0YYbW_ojBhdbcD_7TYV9dqMag@mail.gmail.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
         <20181019152932.32462-2-olga.kornievskaia@gmail.com>
         <fc9619bee3e27d6756ecff9ae143c646d2567b62.camel@kernel.org>
         <CAN-5tyEbGmujqD5Q1FBH9uBWR0YYbW_ojBhdbcD_7TYV9dqMag@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-10-22 at 14:32 -0400, Olga Kornievskaia wrote:
> On Sun, Oct 21, 2018 at 10:29 AM Jeff Layton <jlayton@kernel.org> wrote:
> > 
> > On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > 
> > > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > ---
> > >  fs/read_write.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > index 39b4a21..c60790f 100644
> > > --- a/fs/read_write.c
> > > +++ b/fs/read_write.c
> > > @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> > >       if (unlikely(ret))
> > >               return ret;
> > > 
> > > +     if (pos_in >= i_size_read(inode_in))
> > > +             return -EINVAL;
> > > +
> > >       if (!(file_in->f_mode & FMODE_READ) ||
> > >           !(file_out->f_mode & FMODE_WRITE) ||
> > >           (file_out->f_flags & O_APPEND))
> > 
> > The patch description could use a bit more fleshing-out. The
> > copy_file_range manpage says:
> > 
> >        EINVAL Requested range extends beyond the end of the source file; or the flags argument is not 0.
> > 
> > So I guess this is intended to satisfy that requirement?
> 
> I agree the description of the patch is poor. It sort of falls under
> the the man page's description of range beyond the end of the source
> file. But in NFSv4.2, there is an explicit wording for the validity of
> the input parameters and having an input source offset that's beyond
> the end of the file is what this patch is attempting to check.
> 

Side note:

One has to wonder why they decided to make that an -EINVAL condition?
The system call returns ssize_t. Why not just return a fewer number of
bytes in that situation?

In fact, the RETURN VALUE section of the manpage says:

       Upon successful completion, copy_file_range() will return the number of
       bytes copied between files.  This could be less than the length  origi‐
       nally requested.

Under what conditions would that occur that do not include the file
being shorter than the range you wanted to copy?

I wonder if we ought to lobby to get that changed.

> > If so,
> > i_size_read is just going to return whatever is in inode->isize.
> > Could a copy_file_range call end up getting issued to copy from a file
> > that is already open on a range that it doesn't know about yet? i.e.
> > where the inode cache has not yet been updated.
> 
> I thought that with NFSv4 cache consistency, the inode->isize is
> accurate. If previous open had a read delegation, any modification on
> a server would trigger a CB_RECALL and the open for the copy offload
> would retrieve the latest size. In case of no delegations, the open
> retrieves the latest size and the call to copy_file_range() would have
> an update size.
> 

> It seems like that could on network filesystems (like NFS). Would this
> > be better handled in ->copy_file_range instead, where the driver could
> > make a better determination of the file size?
> 
> I'm not opposed to moving the size check into the NFS's copy_file_size
> (again in my opinion NFS attribute cache has the same file size as the
> inode's size). I think the thought was that such check should be done
> at the VFS layer as oppose to doing it by each of the file systems.
> 
> 

The attribute cache is not revalidated before the i_size is fetched with
i_size_read. You're just reading what happens to be in the in-memory
inode structure. So both clients have the file open already, and neither
has a delegation:

client 1: fetches attributes from file and sees a size of 1000
client 2: writes 20 bytes at offset 1000
client 1: calls copy file range to copy 1020 bytes starting at offset 0

If client1 didn't get an attribute update before the copy_file_range
call came in, then it would still think the size was 1000 and fail the
operation. It may even be many seconds before client1 sees the updated
size.

You could argue that we're not using locking here so you're just subject
to normal open-to-close cache coherency behavior, but that's rather "not
nice".

I think we probably ought to also push this check down into the
filesystem operations as well, and have copy_file_range ensure that the
attribute cache is updated. We're dealing with copy offload here so
doing an extra GETATTR beforehand shouldn't be terribly costly.
-- 
Jeff Layton <jlayton@kernel.org>

