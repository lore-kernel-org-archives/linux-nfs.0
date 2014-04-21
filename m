Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:57742 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbaDUQY0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 12:24:26 -0400
Received: by mail-qc0-f172.google.com with SMTP id i8so4168202qcq.17
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 09:24:26 -0700 (PDT)
Message-ID: <53554637.1080006@gmail.com>
Date: Mon, 21 Apr 2014 12:24:23 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
CC: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/17] NFS: Create a common rw_header_alloc and rw_header_free
 function
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com> <1397768981-12856-8-git-send-email-Anna.Schumaker@Netapp.com> <20140421133252.GA30954@infradead.org> <535522B2.9030401@gmail.com>
In-Reply-To: <535522B2.9030401@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/21/2014 09:52 AM, Anna Schumaker wrote:
> On 04/21/2014 09:32 AM, Christoph Hellwig wrote:
>> On Thu, Apr 17, 2014 at 05:09:31PM -0400, Anna Schumaker wrote:
>>> From: Anna Schumaker <Anna.Schumaker@netapp.com>
>>>
>>> I create a new struct nfs_rw_ops to decide the differences between reads
>>> and writes.  This struct will be set when initializing a new
>>> nfs_pgio_descriptor, and then passed on to the nfs_rw_header when a new
>>> header is allocated.
>> To me it seems like adding this new vector confuses things.  From a look
>> at your whole tree it seems like all methods added to it could as well
>> be added to nfs_pageio_ops.  In that case we'd still keep separate
>> instances of nfs_pageio_ops for reads and writes, but most methods would
>> be that same.  I'm also defintively curious what you have on your
>> sleeves for pnfs.
> Okay.  I'll rework everything into the pageio_ops and see how it looks!  Maybe I'll see what I can do about updating the pnfs patches while I'm at it.
I remember my issue with adding to the nfs_pageio_ops now.  The file, object and block layouts along with the generic pnfs code all have their own read and write pageio_ops.  Changing all of these seemed more tedious than adding a new struct  only in the read and write code.

>
> Thanks for reviewing all of these!
>
> Anna
>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

