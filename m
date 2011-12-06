Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43389 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933199Ab1LFL16 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 06:27:58 -0500
Received: by bkbzv3 with SMTP id zv3so3350753bkb.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 03:27:57 -0800 (PST)
Message-ID: <4EDDFC39.4090800@tonian.com>
Date: Tue, 06 Dec 2011 13:27:53 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/13] pnfsd-block: reverse boolean_t values so they make
 sense
References: <4EDB79A9.2080109@tonian.com> <1323006496-13542-1-git-send-email-benny@tonian.com> <20111206021059.GB4486@fieldses.org>
In-Reply-To: <20111206021059.GB4486@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-06 04:10, J. Bruce Fields wrote:
> On Sun, Dec 04, 2011 at 03:48:16PM +0200, Benny Halevy wrote:
>> From: Benny Halevy <bhalevy@tonian.com>
>>
>> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>> ---
>>  fs/nfsd/bl_ops.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
>> index 89249c4..4d2939e 100644
>> --- a/fs/nfsd/bl_ops.c
>> +++ b/fs/nfsd/bl_ops.c
>> @@ -57,7 +57,7 @@
>>  #endif
>>  
>>  
>> -typedef enum {True, False} boolean_t;
>> +typedef enum {False = 0, True = !False} boolean_t;
> 
> Shouldn't we just use "bool"?

Yes, in some cases. In others, the boolean status doesn't make sense
and I'd like to replace it with an integer.

Benny

> 
> --b.
> 
>>  /* ---- block layoutget and commit structure ---- */
>>  typedef struct bl_layout_rec {
>>  	struct list_head	blr_hash,
>> -- 
>> 1.7.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
