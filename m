Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53425 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab0I2Sfz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 14:35:55 -0400
Received: by bwz11 with SMTP id 11so781141bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 11:35:53 -0700 (PDT)
In-Reply-To: <4CA36FDD.1020102@desy.de>
References: <4C7BDD8C.40509@panasas.com>
	<4CA31DC3.8070300@panasas.com>
	<4CA34830.1040703@desy.de>
	<4CA34883.40005@desy.de>
	<4CA34B93.2010100@panasas.com>
	<4CA34F05.3020809@desy.de>
	<4CA35A59.9020303@panasas.com>
	<4CA36FDD.1020102@desy.de>
Date: Wed, 29 Sep 2010 14:35:53 -0400
Message-ID: <AANLkTi=-3VoNBj6_FAD0UO672fELYJNdVhNUmOBddHh_@mail.gmail.com>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
From: Fred Isaman <iisaman@netapp.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Tigran, are you sure you are running with Benny's suggested patch?
The two oopses you posted from before and after look suspiciously
similar.

Fred

On Wed, Sep 29, 2010 at 12:57 PM, Tigran Mkrtchyan
<tigran.mkrtchyan@desy.de> wrote:
>
>> Tigran, do you have a new trace maybe?
>> I cross referenced the dump you sent to the
>> disassembled code and it seems like it hit NULL dereference on
>> size = fl->stripe_unit;
>>
>> I'm going to commit this patch anyway but I want to
>> understand what else I missed...
>>
>> Benny
>>
>
> The stack attached.  Shall I compile the kernel with some debug options for
> better debugging?
>
> Tigran.
>>>>
>>>> git diff --stat -p -M
>>>>   fs/nfs/nfs4filelayout.c |    2 ++
>>>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>>> index 75e07c8..8fbb0db 100644
>>>> --- a/fs/nfs/nfs4filelayout.c
>>>> +++ b/fs/nfs/nfs4filelayout.c
>>>> @@ -636,6 +636,8 @@ filelayout_get_stripesize(struct pnfs_layout_hdr
>>>> *lo)
>>>>
>>>>        /* Horrible hack...ideally upper layer would send lseg */
>>>>        lseg = pnfs_has_layout(lo,&range);
>>>> +       if (!lseg)
>>>> +               return 0;
>>>>        fl = container_of(lseg, struct nfs4_filelayout_segment,
>>>> generic_hdr);
>>>>        size = fl->stripe_unit;
>>>>        put_lseg_locked(lseg);
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
