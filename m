Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:55528 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751455AbeB0SwA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Feb 2018 13:52:00 -0500
Subject: Re: [PATCH 1/1] mount.nfs: minorversion setting is being ignored with
 -t flag
To: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180226191542.31447-1-steved@redhat.com>
 <20180226191542.31447-2-steved@redhat.com>
 <87zi3vgoza.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <517662da-56b9-5a41-7e3f-25431ced819b@RedHat.com>
Date: Tue, 27 Feb 2018 13:51:59 -0500
MIME-Version: 1.0
In-Reply-To: <87zi3vgoza.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/26/2018 09:12 PM, NeilBrown wrote:
> On Mon, Feb 26 2018, Steve Dickson wrote:
> 
>> mount -t nfs or mount -t nfs4 and setting minorversion
>> should set the v4 minor version. This patch adds a few
>> checks to make sure the minor version is set.
>>
>> The patch also translate the minorversion= option
>> to vers=4.x in the arguments passed to the kernel.
>>
> 
> If you do this, then you break compatibility with v3.4 and earlier.
> (anything without Commit: 0d71b058092f ("NFS: Extend the -overs= mount
> option to allow 4.x minorversions")).
Yeah... I did realized that... 
> 
> Maybe that is OK, but I think that fact should be clearly stated in the
> commit log, and preferably the configure script should warn if you try
> to build on an unsupported kernel.Well I just took a look and it's easy enough to put
a kernel version check in... We do that all over the mount code.
> 
> Do we have any sort of policy on the oldest kernel the nfs-utils still
> supports?  Should we?
No... and IDK... I think it is more of a compilation issue. 
Getting the code to compile on older systems is not easy.
You have to disable a number features as well as hack up
the configure.ac file. 

Question, do packages like glibc have these types of policies?

steved. 
> 
> Thanks,
> NeilBrown
> 
> 
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mount/network.c | 15 ++++++++++-----
>>  utils/mount/stropts.c | 14 ++++++++++++++
>>  2 files changed, 24 insertions(+), 5 deletions(-)
>>
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index 8ab5be8..8d6e4c6 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -1275,8 +1275,8 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
>>  		}
>>  	}
>>  
>> -	if (!found && strcmp(type, "nfs4") == 0)
>> -		version_val = type + 3;
>> +	if (!found && strncmp(type, "nfs", 3) == 0)
>> +		version_val = "4";
>>  	else if (!found)
>>  		return 1;
>>  	else if (i <= 2 ) {
>> @@ -1308,9 +1308,14 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
>>  		if (!(version->minor = strtol(version_val, &cptr, 10)) && cptr == version_val)
>>  			goto ret_error;
>>  		version->v_mode = V_SPECIFIC;
>> -	} else if (version->major > 3 && *cptr == '\0')
>> -		version->v_mode = V_GENERAL;
>> -
>> +	} else if (version->major > 3 && *cptr == '\0') {
>> +		version_val = po_get(options, "minorversion");
>> +		if (version_val != NULL) {
>> +			version->minor = strtol(version_val, &cptr, 10);
>> +			version->v_mode = V_SPECIFIC;
>> +		} else 
>> +			version->v_mode = V_GENERAL;
>> +	}
>>  	if (*cptr != '\0')
>>  		goto ret_error;
>>  
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 777de39..6bbfd71 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -767,6 +767,20 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
>>  			mi->version.minor);
>>  #pragma GCC diagnostic warning "-Wformat-nonliteral"
>>  
>> +		if (po_append(options, version_opt) == PO_FAILED) {
>> +			errno = EINVAL;
>> +			goto out_fail;
>> +		}
>> +	} else if (po_get(options, "minorversion")) {
>> +		/*
>> +	 	 * convert minorversion= into vers=4.x
>> +	 	 */
>> +		po_remove_all(options, "minorversion");
>> +
>> +		snprintf(version_opt, sizeof(version_opt) - 1,
>> +			"vers=%lu.%lu", mi->version.major,
>> +			mi->version.minor);
>> +
>>  		if (po_append(options, version_opt) == PO_FAILED) {
>>  			errno = EINVAL;
>>  			goto out_fail;
>> -- 
>> 2.14.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
