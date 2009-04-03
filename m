From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 1/2] nfsstat.c: Print diff stats every N seconds
Date: Fri, 03 Apr 2009 10:10:15 -0700
Message-ID: <49D642F7.3040900@disney.com>
References: <1237225556-27691-1-git-send-email-kevin.constantine@disneyanimation.com> <49D62A92.5090907@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([12.188.26.102]:27600 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757569AbZDCRKW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 13:10:22 -0400
In-Reply-To: <49D62A92.5090907-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Steve Dickson wrote:
> Hey Kevin,
> 
> I apologize for taking so long to look at this... but...
> 
> Question: I notice that the v3 stats are displayed one
> way (in list format) and the v4 stats are display in
> another way (in column format) was this on purpose? 
> Should they be displayed using the same format? 
> 
Steve-
I re-worked, and re-submitted the patches per some suggestions from 
Greg.  I've since found an output bug that if --sleep=1 outputs a 
newline when there's no nfs traffic.  It'd probably just be easiest if I 
re-send the patches at this point if that works for you.

-kevin

> steved. 
> 
> Kevin Constantine wrote:
>> nfsstat.c: Implemented --sleep[interval] option.
>> nfsstat.man: Added information about the --sleep option
>> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
>> ---
>>  utils/nfsstat/nfsstat.c   |  158 +++++++++++++++++++++++++++++++++++++--------
>>  utils/nfsstat/nfsstat.man |    6 ++-
>>  2 files changed, 137 insertions(+), 27 deletions(-)
>>
>> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
>> index 1517414..c25580c 100644
>> --- a/utils/nfsstat/nfsstat.c
>> +++ b/utils/nfsstat/nfsstat.c
>> @@ -167,10 +167,16 @@ DECLARE_SRV(srvinfo, _old);
