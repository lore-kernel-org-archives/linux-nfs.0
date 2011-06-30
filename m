Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189Ab1F3K6S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 06:58:18 -0400
Message-ID: <4E0C56BC.7010606@RedHat.com>
Date: Thu, 30 Jun 2011 06:58:04 -0400
From: Steve Dickson <SteveD@redhat.com>
To: NeilBrown <neilb@suse.de>
CC: Prem Karat <prem.karat@linux.vnet.ibm.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
References: <20110628104138.GB6600@d6fc318.ibm.com>	<4E0B3687.6060209@RedHat.com> <20110630090932.10caeca6@notabene.brown>
In-Reply-To: <20110630090932.10caeca6@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/29/2011 07:09 PM, NeilBrown wrote:
> On Wed, 29 Jun 2011 10:28:23 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 06/28/2011 06:41 AM, Prem Karat wrote:
>>>
>>> Currently souce and destination parameters should be passed as first and 
>>> second paramter while using mount.nfs. This patch allows them to be passed 
>>> anywhere while mounting.
>>>
>>> Current functionality is
>>> 	mount.nfs source destn -o <options>
>>> This patch will allow to do this
>>> 	mount.nfs -o <options> source destn
>>> 		or
>>> 	mount.nfs -o <options> source -o <options> destn
>>>
>>> Signed-off-by: Prem Karat <prem.karat@linux.vnet.ibm.com>
>> Committed...
> 
> Uhmm... that's unfortunate because the patch is badly broken.
> 
> With the patch in place, argv[2] gets destroyed.
> i.e. mount cannot possibly work correctly now.
> 
> And that is just the start of the problems.
> 
> This patch has clearly never been tested.
Hmm... well this is not true... I have 1.2.4 running
on a number of machines and without a problem...

But I will looking what you are saying...

steved.

> 
> I guess we need a 1.2.5 pretty quickly. :-(
> 
> NeilBrown
> 
> 
>>
>> steved.
>>
>>> ---
>>>  utils/mount/mount.c |   13 +++++++++----
>>>  1 files changed, 9 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
>>> index f3f0a83..62115bb 100644
>>> --- a/utils/mount/mount.c
>>> +++ b/utils/mount/mount.c
>>> @@ -374,7 +374,7 @@ static int try_mount(char *spec, char *mount_point, int flags,
>>>  int main(int argc, char *argv[])
>>>  {
>>>  	int c, flags = 0, mnt_err = 1, fake = 0;
>>> -	char *spec, *mount_point, *fs_type = "nfs";
>>> +	char *spec = NULL, *mount_point = NULL, *fs_type = "nfs";
>>>  	char *extra_opts = NULL, *mount_opts = NULL;
>>>  	uid_t uid = getuid();
>>>  
>>> @@ -398,9 +398,6 @@ int main(int argc, char *argv[])
>>>  		exit(EX_USAGE);
>>>  	}
>>>  
>>> -	spec = argv[1];
>>> -	mount_point = argv[2];
>>> -
>>>  	mount_config_init(progname);
>>>  
>>>  	argv[2] = argv[0]; /* so that getopt error messages are correct */
>>> @@ -447,6 +444,14 @@ int main(int argc, char *argv[])
>>>  	if (optind != argc - 2) {
>>>  		mount_usage();
>>>  		goto out_usage;
>>> +	} else {
>>> +		while (optind < argc) {
>>> +			if (!spec)
>>> +				spec = argv[optind];
>>> +			else
>>> +				mount_point = argv[optind];
>>> +			optind++;
>>> +		}
>>>  	}
>>>  
>>>  	if (strcmp(progname, "mount.nfs4") == 0)
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
