From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 06/50] pnfs_submit: introduce include/linux/nfs4_pnfs.h
Date: Wed, 18 Aug 2010 16:48:40 -0400
Message-ID: <AANLkTimLTm91fXZdf6-=8LAAZ2YDLn3NMPS1cbO9vGey@mail.gmail.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
	<1281735122-1496-2-git-send-email-andros@netapp.com>
	<1281735122-1496-3-git-send-email-andros@netapp.com>
	<1281735122-1496-4-git-send-email-andros@netapp.com>
	<1281735122-1496-5-git-send-email-andros@netapp.com>
	<1281735122-1496-6-git-send-email-andros@netapp.com>
	<1281735122-1496-7-git-send-email-andros@netapp.com>
	<20100818202718.GB16851@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org,
	Dean Hildebrand <seattleplus@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35777 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655Ab0HRUsl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:48:41 -0400
Received: by iwn7 with SMTP id 7so987544iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 18 Aug 2010 13:48:40 -0700 (PDT)
In-Reply-To: <20100818202718.GB16851@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 18, 2010 at 4:27 PM, Christoph Hellwig <hch@infradead.org> =
wrote:
>> +++ b/include/linux/nfs4_pnfs.h
>> @@ -0,0 +1,15 @@
>> +/*
>> + * =A0include/linux/nfs4_pnfs.h
>
> Please don't include these kinds of comments, they only purpose they
> serve is frequently getting out of date. =A0That applies to just abou=
t
> every file added in this series.
>
>> + *
>> + * =A0Common data structures needed by the pnfs client and pnfs lay=
out driver.
>> + *
>> + * =A0Copyright (c) 2002 The Regents of the University of Michigan.
>> + * =A0All rights reserved.
>> + *
>> + * =A0Dean Hildebrand =A0 <dhildebz-nNDzPDmKTdnSiEDVxGk4TQ@public.gmane.org>
>> + */
>> +
>> +#ifndef LINUX_NFS4_PNFS_H
>> +#define LINUX_NFS4_PNFS_H
>> +
>> +#endif /* LINUX_NFS4_PNFS_H */
>
> Adding a file that only contains copyrights and inclusion headers is
> rather odd. =A0I think you want your split a little more corse graine=
d.

Agreed. This patch set is really a first go at squashing 281 patches
into 50. We have more know re-org and cleanup, just wanted to do an
initial re-org keeping the tree the same as a first step.

Thanks for your comments.

-->Andy

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
