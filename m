Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753130Ab2CBTQf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 14:16:35 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q22JGZx6016202
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 14:16:35 -0500
Received: from badhat.bos.devel.redhat.com (vpn-11-150.rdu.redhat.com [10.11.11.150])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q22JGYUc031096
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 14:16:34 -0500
Message-ID: <4F511C95.2040806@RedHat.com>
Date: Fri, 02 Mar 2012 14:16:37 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: strip of extra slashes in device name
References: <1330707221-4005-1-git-send-email-steved@redhat.com> <20120302184556.GA6880@us.ibm.com>
In-Reply-To: <20120302184556.GA6880@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/02/2012 01:45 PM, Malahal Naineni wrote:
> My kernel doesn't seem to strip '/' from its /proc/mounts. What kernel
> are you using? 
a later RHEL6 kernel... but I see the same thing with Fedora f16 kernels (3.2)
as well... What kernel are you using?

> Anyway, how about something similar to the following
> patch that fixes only NFSv4 atm:
> 
> http://www.spinics.net/lists/linux-nfs/msg27351.html
I made a comment on that... Again, sorry for my tartness...

steved.
 
> 
> Regards, Malahal.
> 
> Steve Dickson [steved@redhat.com] wrote:
>> The kernel strips off extra '/' when the  device is entered
>> into /proc/mounts. So that umounts can this devices, strip off
>> any extra '/' before storing the device in the mtab.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/mount/mount.c |   18 ++++++++++++++++++
>>  1 files changed, 18 insertions(+), 0 deletions(-)
>>
>> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
>> index eea00af..eb63f50 100644
>> --- a/utils/mount/mount.c
>> +++ b/utils/mount/mount.c
>> @@ -485,6 +485,24 @@ int main(int argc, char *argv[])
>>  		goto out;
>>  	}
>>  	/*
>> +	 * The kernel strips off extra '/' when the device is entered 
>> +	 * into /proc/mounts. So that umounts can this devices, strip off
>> +	 * any extra '/' before storing the device in the mtab.
>> +	 */
>> +	if (strstr(spec, "//") != NULL) {
>> +		char *colen, *slash;
>> +
>> +		if ((colen = strchr(spec, ':'))) {
>> +			slash = (colen + 1);
>> +			while (*slash && *(slash+1) == '/')
>> +				slash++;
>> +			while (*slash)
>> +				*(++colen) = *(slash++);
>> +			*(colen+1) = '\0';
>> +		}
>> +	}
>> +
>> +	/*
>>  	 * Concatenate mount options from the configuration file
>>  	 */
>>  	mount_opts = mount_config_opts(spec, mount_point, mount_opts);
>> -- 
>> 1.7.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
