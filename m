Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755784Ab1IBUwx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Sep 2011 16:52:53 -0400
Message-ID: <4E614222.8050309@RedHat.com>
Date: Fri, 02 Sep 2011 16:52:50 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Masatake YAMATO <yamato@redhat.com>
CC: vapier@gentoo.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] exportfs: do not warn if /etc/exports.d/ does not
 exist
References: <1314890192-11075-1-git-send-email-vapier@gentoo.org>	<1314890192-11075-2-git-send-email-vapier@gentoo.org>	<4E5FA65C.6090201@RedHat.com> <20110902.094007.1073363300085597776.yamato@redhat.com>
In-Reply-To: <20110902.094007.1073363300085597776.yamato@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/01/2011 08:40 PM, Masatake YAMATO wrote:
> I've tried this issue in different way:)
> Steve, could you see this bug?
> 
>       https://bugzilla.redhat.com/show_bug.cgi?id=697006
Fair enough....  but the patch in that bz is distro specific, 
means it would have no affect on other distros... With that
said, your patch is a good idea so I will added my todo list

steved.
> 
> Masatake YAMATO
> 
> 
> On Thu, 01 Sep 2011 11:35:56 -0400, Steve Dickson <SteveD@redhat.com> wrote
>>
>>
>> On 09/01/2011 11:16 AM, Mike Frysinger wrote:
>>> It isn't uncommon for /etc/exports.d/ to not exist, and imo, it's not
>>> that big of a deal as often times, a simple /etc/exports is sufficient.
>>> So silently skip the case where the dir is missing.
>>>
>>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>> Committed...
>>
>> steved.
>>
>>> ---
>>>  utils/exportfs/exportfs.c |    7 +++++--
>>>  1 files changed, 5 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
>>> index 986a272..7432a65 100644
>>> --- a/utils/exportfs/exportfs.c
>>> +++ b/utils/exportfs/exportfs.c
>>> @@ -529,9 +529,12 @@ export_d_read(const char *dname)
>>>  
>>>  
>>>  	n = scandir(dname, &namelist, NULL, versionsort);
>>> -	if (n < 0)
>>> +	if (n < 0) {
>>> +		if (errno == ENOENT)
>>> +			/* Silently return */
>>> +			return;
>>>  		xlog(L_NOTICE, "scandir %s: %s", dname, strerror(errno));
>>> -	else if (n == 0)
>>> +	} else if (n == 0)
>>>  		return;
>>>  
>>>  	for (i = 0; i < n; i++) {
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
