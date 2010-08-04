Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27803 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758588Ab0HDU7u convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 16:59:50 -0400
Subject: Re: Write delegation
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
Date: Wed, 4 Aug 2010 16:59:49 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <97A00951-577C-4365-AA38-3C6E2D03B372@netapp.com>
References: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com> <AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
To: Yudong Gao <stgyd@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 4, 2010, at 3:21 PM, Yudong Gao wrote:

> Hi,
> 
> I am not able to find the implementation of directory delegation,
> either. Similarly, the callback functions CB_NOTIFY is not
> implemented, either. I find that in preprocss_nfs41_op() in
> callback_xdr.c, whenever a CB_NOTIFY is encountered, an
> NFS4ERR_NOTSUPP is returned directly.

CB_NOTIFY is not currently supported on the Linux NFS client.

> 
> Am I missing something? Or they are just not supported in the current version?
> 
> Thanks a lot!
> 
> best,
> 
> Yudong
> 
> On Mon, Aug 2, 2010 at 5:17 PM, Yudong Gao <stgyd@umich.edu> wrote:
>> Hi,
>> 
>> I am looking at the delegation implementation in the source code of
>> NFS 4.1 in kernel 2.6.32.15. I can find the code for read delegation,
>> which is working and can serve the read requests locally. But I can
>> never find the code about write delegation, which is supposed to cache
>> the write update locally. I try to look at the functions including
>> nfs_writepage(s), nfs_file_flush() but none of them checks or uses the
>> write delegation.
>> 
>> Is write delegation currently implemented in NFS 4.1?

Write delegation is supported but I don't think write behavior changes - writes are still cached and flushed as without a write delegation. The write delegation does prevent open/close and lock/locku from being put on the wire.

-->Andy

>> 
>> Thanks!
>> 
>> best,
>> 
>> Yudong
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

