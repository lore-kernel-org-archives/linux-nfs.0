Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f175.google.com ([209.85.128.175]:63075 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbaE1XAJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 19:00:09 -0400
Received: by mail-ve0-f175.google.com with SMTP id jw12so13179678veb.6
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 16:00:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140527160044.GA17587@infradead.org>
References: <20140421172917.GA20036@infradead.org>
	<20140505065624.GA32658@infradead.org>
	<20140527160044.GA17587@infradead.org>
Date: Wed, 28 May 2014 19:00:08 -0400
Message-ID: <CAHQdGtSKHRt3DZad9ezvF0Wx+i5SfQuJTHzHUOOwdgi1GoscKw@mail.gmail.com>
Subject: Re: [PATCH] nfs: commit layouts in fdatasync
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 27, 2014 at 12:00 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Sun, May 04, 2014 at 11:56:24PM -0700, Christoph Hellwig wrote:
>> ping?  This is a fairly serious data integrity issue for pnfs users.
>
> ping^2
>
> without this fdatasync and O_DSYNC writes on pnfs are more or less
> noops, so at least getting a review would be helpful, nevermind
> forwarding it to Linus and -stable.

Applied for 3.16. Not sure about -stable eligibility, since this only
affects pnfs blocks for now (files and objects should both be able to
recover in case of client failure). Are you seeing this in production
environments?

Cheers
  Trond

>> On Mon, Apr 21, 2014 at 10:29:17AM -0700, Christoph Hellwig wrote:
>> > >From fdatasync(2):
>> >
>> >  "fdatasync() is similar to fsync(), but does not flush modified metadata
>> >   unless that metadata is needed in order  to  allow  a  subsequent  data
>> >   retrieval to be correctly handled."
>> >
>> > We absolutely need to commit the layouts to be able to retrieve the data
>> > in case either the client, the server or the storage subsystem go down.
>> >
>> > Signed-off-by: Christoph Hellwig <hch@lst.de>
>> >
>> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
>> > index 8de3407..464db9d 100644
>> > --- a/fs/nfs/nfs4file.c
>> > +++ b/fs/nfs/nfs4file.c
>> > @@ -100,8 +100,7 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
>> >                     break;
>> >             mutex_lock(&inode->i_mutex);
>> >             ret = nfs_file_fsync_commit(file, start, end, datasync);
>> > -           if (!ret && !datasync)
>> > -                   /* application has asked for meta-data sync */
>> > +           if (!ret)
>> >                     ret = pnfs_layoutcommit_inode(inode, true);
>> >             mutex_unlock(&inode->i_mutex);
>> >             /*
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> ---end quoted text---
> ---end quoted text---



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
