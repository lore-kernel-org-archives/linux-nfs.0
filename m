Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:33798 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdEJFY7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 May 2017 01:24:59 -0400
From: Ari Kauppi <Ari.Kauppi@synopsys.com>
To: Colin Ian King <colin.king@canonical.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Dan Carpenter <dan.carpenter@oracle.com>
CC: Ari Kauppi <Ari.Kauppi@synopsys.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: avoid out of bounds read on array nfsd4_layout_ops
Date: Wed, 10 May 2017 05:24:54 +0000
Message-ID: <6B1C9D91-4238-4103-9C0B-F9A2AFFDCC3B@synopsys.com>
References: <20170509133121.26529-1-colin.king@canonical.com>
 <20170509140414.ycw4z6zsdevbkozm@mwanda>
 <20170509210350.GD6289@fieldses.org>
 <5d21cd12-c842-d0ce-34bb-f037d0fd52ba@canonical.com>
In-Reply-To: <5d21cd12-c842-d0ce-34bb-f037d0fd52ba@canonical.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On 10.5.2017, at 0.14, Colin Ian King <colin.king@canonical.com> wrote:
> 
> On 09/05/17 22:03, J . Bruce Fields wrote:
>> On Tue, May 09, 2017 at 05:04:14PM +0300, Dan Carpenter wrote:
>>> On Tue, May 09, 2017 at 02:31:21PM +0100, Colin King wrote:
>>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>>>> index 1dbf62190bee..c453a1998e00 100644
>>>> --- a/fs/nfsd/nfs4proc.c
>>>> +++ b/fs/nfsd/nfs4proc.c
>>>> @@ -1259,7 +1259,8 @@ nfsd4_layout_verify(struct svc_export *exp, unsigned int layout_type)
>>>> 		return NULL;
>>>> 	}
>>>> 
>>>> -	if (layout_type >= 32 || !(exp->ex_layout_types & (1 << layout_type))) {
>>>> +	if (layout_type >= LAYOUT_TYPE_MAX ||
>>>> +	    !(exp->ex_layout_types & (1 << layout_type))) {
>>> 
>>> The 32 is there to prevent a shift wrapping bug.  The bit test prevents
>>> a buffer overflow so this can't actually overflow.
>> 
>> Yes, looks like a false positive for coverity.
>> 
>>> But this change doesn't hurt and is probably cleaner.
>> 
>> Sure.  Hope it's OK if I just merge this into the previous commit:
> 
> Fine by me.  Colin

Looks good to me.

Thanks,

--
Ari