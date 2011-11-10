Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34432 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab1KJG4E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 01:56:04 -0500
Received: by mail-fx0-f46.google.com with SMTP id n18so185212fag.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2011 22:56:03 -0800 (PST)
Message-ID: <4EBB757F.7080509@tonian.com>
Date: Thu, 10 Nov 2011 08:55:59 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint under
 NFSDDBG_PNFS
References: <4EB9F8D6.1080302@panasas.com> <20111109195510.GA2227@fieldses.org>
In-Reply-To: <20111109195510.GA2227@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-09 21:55, J. Bruce Fields wrote:
> On Tue, Nov 08, 2011 at 07:51:50PM -0800, Boaz Harrosh wrote:
>>
>> I've been squinting  at pnfsd dprints for ages and aching under the wait. So I headed
>> up to the nfsd/debug.h to add a PNFS channel, and what do you know? there is one!
>> It's used by nfs4pnfsds.c. Surly  nfs4pnfsd.c is more _PNFS than _PROC.
> 
> Hey now, nfs4pnfsd.c has enough problems of its own without being
> accused of surliness.

:-)

> 
> --b.
> 
>>
>> While at it I changed  nfs4pnfsdlm.c to, also already defined, NFSDDBG_FILELAYOUT
>> which was unused before this patch.
>>
>> CC: Steve Dickson <steved@redhat.com>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>> ---
>>  fs/nfsd/nfs4pnfsd.c   |    2 +-
>>  fs/nfsd/nfs4pnfsdlm.c |    2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
>> index 18b8fca..f514ebe 100644
>> --- a/fs/nfsd/nfs4pnfsd.c
>> +++ b/fs/nfsd/nfs4pnfsd.c
>> @@ -23,7 +23,7 @@
>>  
>>  #include "pnfsd.h"
>>  
>> -#define NFSDDBG_FACILITY                NFSDDBG_PROC
>> +#define NFSDDBG_FACILITY                NFSDDBG_PNFS
>>  
>>  /* Globals */
>>  static u32 current_layoutid = 1;
>> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
>> index abc4d83..0f0441a 100644
>> --- a/fs/nfsd/nfs4pnfsdlm.c
>> +++ b/fs/nfsd/nfs4pnfsdlm.c
>> @@ -30,7 +30,7 @@
>>  #include "nfsfh.h"
>>  #include "nfsd.h"
>>  
>> -#define NFSDDBG_FACILITY                NFSDDBG_PROC
>> +#define NFSDDBG_FACILITY                NFSDDBG_FILELAYOUT
>>  
>>  /* Just use a linked list. Do not expect more than 32 dlm_device_entries
>>   * the first implementation will just use one device per cluster file system
>> -- 
>> 1.7.6.2
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
