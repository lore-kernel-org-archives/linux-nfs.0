Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691Ab1FHDQS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 23:16:18 -0400
Message-ID: <4DEEE980.3050308@RedHat.com>
Date: Tue, 07 Jun 2011 23:16:16 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Pavel Shilovsky <piastryyy@gmail.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: group length not being set correctly in auth_unix_gid
References: <1307462188-13122-1-git-send-email-steved@redhat.com> <BANLkTikuUNx+opL+8TnS=cM9ASnrJYLuLA@mail.gmail.com>
In-Reply-To: <BANLkTikuUNx+opL+8TnS=cM9ASnrJYLuLA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/07/2011 02:41 PM, Pavel Shilovsky wrote:
> 2011/6/7 Steve Dickson <steved@redhat.com>:
>> From: Rinat Bikov <becase@altlinux.org>
>>
>> Commit 9274e94d introduce dynamic buffering for gids lists.
>> In that patch there was a bug that only used the dynamic
>> length on the first call, resulting in the dynamic length
>> not being dynamic at all.
>>
>> Reported-by: Rinat Bikov <becase@altlinux.org>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mountd/cache.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>> index 0c4a03d..6084893 100644
>> --- a/utils/mountd/cache.c
>> +++ b/utils/mountd/cache.c
>> @@ -147,8 +147,9 @@ static void auth_unix_gid(FILE *f)
>>                if (!groups)
>>                        return;
>>
>> -               groups_len = ngroups = INITIAL_MANAGED_GROUPS;
>> +               groups_len = INITIAL_MANAGED_GROUPS;
>>        }
>> +       ngroups = groups_len;
>>
>>        if (readline(fileno(f), &lbuf, &lbuflen) != 1)
>>                return;
>> --
>> 1.7.5.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> Looks good. It's almost the same, as I sent before "mountd: Fix
> missing varialble assignment in auth_unix_gid"
> (https://patchwork.kernel.org/patch/841452/) but it haven't got any
> comments yet.
> 
yeah.. Rinat sent me some private mail about this regression and
I made this posting before I remember you had already post a 
similar patch... So I did commit your patch...

steved.
