From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Fixed compile errors when the mount config file is not
 enabled
Date: Mon, 16 Nov 2009 13:28:54 -0500
Message-ID: <4B0199E6.20405@RedHat.com>
References: <4AE751CE.1050300@RedHat.com> <36FDE8D9-4D83-447F-A2AF-516B5FEFDAD7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbZKPS2w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 13:28:52 -0500
In-Reply-To: <36FDE8D9-4D83-447F-A2AF-516B5FEFDAD7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/27/2009 04:20 PM, Chuck Lever wrote:
> Hi-
> 
> On Oct 27, 2009, at 4:02 PM, Steve Dickson wrote:
> 
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Tue Oct 27 15:47:27 2009 -0400
>>
>>    Added wrappers around the setting of default values
>>    from the config file which will be compiled out
>>    when the config file is not enabled.
>>
>>    Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> diff --git a/support/include/conffile.h b/support/include/conffile.h
>> index fe23ec2..ce7aa21 100644
>> --- a/support/include/conffile.h
>> +++ b/support/include/conffile.h
>> @@ -76,10 +76,5 @@ static inline void upper2lower(char *str)
>>         *str++ = c;
>> }
>>
>> -/*
>> - * Default Mount options
>> - */
>> -extern unsigned long config_default_vers;
>> -extern unsigned long config_default_proto;
>>
>> #endif                /* _CONFFILE_H_ */
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index e651167..d4ecbc9 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -172,6 +172,27 @@ static const unsigned long probe_mnt3_first[] = {
>>     0,
>> };
>>
>> +inline const unsigned int *set_default_proto(void);
> 
> The "inline" directives are visual clutter, really... shouldn't this be
> "static" instead (which in most normal cases implies "inline")? 
> Otherwise, you also clutter up the linker's symbol name space with these
> generic function names.  I've been prefixing function names with "nfs_"
> for most global functions, to make debugging easier.
I made these changes a while ago... I guess I forgot to mention 
it... thanks of the input!

steved.
