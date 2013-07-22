Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:14241 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933090Ab3GVTCU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jul 2013 15:02:20 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 Increase NFS4_DEF_SLOT_TABLE_SIZE
Date: Mon, 22 Jul 2013 19:02:03 +0000
Message-ID: <B0405D50-D8BE-496D-8B72-0E09B13B7D77@netapp.com>
References: <1374268191-4469-1-git-send-email-andros@netapp.com>
 <1374518181.7972.14.camel@leira.trondhjem.org>
In-Reply-To: <1374518181.7972.14.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2013, at 2:36 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Fri, 2013-07-19 at 17:09 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> max_session_slots is a ushort. Bump NFS4_DEF_SLOT_TABLE_SIZE to the max ushort
>> value: e.g. ask for 256 slots and let the server negotiate down if needed.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/nfs4session.h | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
>> index 3a153d8..8b7899f 100644
>> --- a/fs/nfs/nfs4session.h
>> +++ b/fs/nfs/nfs4session.h
>> @@ -8,7 +8,7 @@
>> #define __LINUX_FS_NFS_NFS4SESSION_H
>> 
>> /* maximum number of slots to use */
>> -#define NFS4_DEF_SLOT_TABLE_SIZE (16U)
>> +#define NFS4_DEF_SLOT_TABLE_SIZE (256U)
> 
> Could we please make this smaller? I agree that 16 is too small (as long
> as servers don't do dynamic slot allocation), but 256 is very high for a
> default.
> 
> How about 64?

IIIRC the (non-dynamic) session implemenations that I've seen treat the ca_maxrequests coming from the client as the maximum number of session slots that the client can handle - IOW I don't see servers returning a higher ca_maxrequests than was sent by the client. This is why I chose a larger number for the default. It is, after all, a server resource and shouldn't the client grab as many session slots as it can?

-->Andy

> 
>> #define NFS4_MAX_SLOT_TABLE (1024U)
>> #define NFS4_NO_SLOT ((u32)-1)
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

