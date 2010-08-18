From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 06/50] pnfs_submit: introduce include/linux/nfs4_pnfs.h
Date: Wed, 18 Aug 2010 23:50:13 +0300
Message-ID: <4C6C4785.8040301@panasas.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com> <1281735122-1496-2-git-send-email-andros@netapp.com> <1281735122-1496-3-git-send-email-andros@netapp.com> <1281735122-1496-4-git-send-email-andros@netapp.com> <1281735122-1496-5-git-send-email-andros@netapp.com> <1281735122-1496-6-git-send-email-andros@netapp.com> <1281735122-1496-7-git-send-email-andros@netapp.com> <20100818202718.GB16851@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: andros@netapp.com, linux-nfs@vger.kernel.org,
	Dean Hildebrand <seattleplus@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34729 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754150Ab0HRUuR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:50:17 -0400
In-Reply-To: <20100818202718.GB16851@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 18, 2010, 23:27 +0300, Christoph Hellwig <hch@infradead.org> wrote:
>> +++ b/include/linux/nfs4_pnfs.h
>> @@ -0,0 +1,15 @@
>> +/*
>> + *  include/linux/nfs4_pnfs.h
> 
> Please don't include these kinds of comments, they only purpose they
> serve is frequently getting out of date.  That applies to just about
> every file added in this series.
> 

Agreed.

>> + *
>> + *  Common data structures needed by the pnfs client and pnfs layout driver.
>> + *
>> + *  Copyright (c) 2002 The Regents of the University of Michigan.
>> + *  All rights reserved.
>> + *
>> + *  Dean Hildebrand   <dhildebz-nNDzPDmKTdnSiEDVxGk4TQ@public.gmane.org>
>> + */
>> +
>> +#ifndef LINUX_NFS4_PNFS_H
>> +#define LINUX_NFS4_PNFS_H
>> +
>> +#endif /* LINUX_NFS4_PNFS_H */
> 
> Adding a file that only contains copyrights and inclusion headers is
> rather odd.  I think you want your split a little more corse grained.
> 

Yup. This was originally done for patch mechanics reasons.
It can be just part of the first patch that uses the file.

Benny
