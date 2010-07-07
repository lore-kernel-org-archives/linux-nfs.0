Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:52109 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab0GGRzB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 13:55:01 -0400
Message-ID: <4C34BF35.4060802@oracle.com>
Date: Wed, 07 Jul 2010 13:53:57 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>, hch@infradead.org,
        viro@zeniv.linux.org.uk, casey@schaufler-ca.com, sds@tycho.nsa.gov,
        matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 05/10] KConfig: Add KConfig entries for Labeled NFS
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov> <1278513086-23964-6-git-send-email-dpquigl@tycho.nsa.gov> <20100707165602.GC28815@fieldses.org>
In-Reply-To: <20100707165602.GC28815@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/ 7/10 12:56 PM, J. Bruce Fields wrote:
> On Wed, Jul 07, 2010 at 10:31:21AM -0400, David P. Quigley wrote:
>> This patch adds two entries into the fs/KConfig file. The first entry
>> NFS_V4_SECURITY_LABEL enables security label support for the NFSv4 client while
>> the second entry NFSD_V4_SECURITY_LABEL enables security labeling support on
>> the server side.
>
> Will there also be some way to turn these on and off at run-time (maybe
> for particular exports or filesystems?)
>
> And if so, will there be any reason not to have this on all the time?  I
> don't think we'll want a config option for every future possible NFSv4.x
> feature.

I would guess that the ability to build without this feature would be 
desirable if it added significant bulk to the object code.  If it 
doesn't, then I agree with you that having it adds unneeded clutter to 
the code, and additional complexity to kernel configuration that most 
people will ignore and/or get wrong.

>>
>> Signed-off-by: Matthew N. Dodd<Matthew.Dodd@sparta.com>
>> Signed-off-by: David P. Quigley<dpquigl@tycho.nsa.gov>
>> ---
>>   fs/nfs/Kconfig  |   16 ++++++++++++++++
>>   fs/nfsd/Kconfig |   13 +++++++++++++
>>   2 files changed, 29 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index a43d07e..67b158c 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -83,6 +83,22 @@ config NFS_V4_1
>>
>>   	  Unless you're an NFS developer, say N.
>>
>> +config NFS_V4_SECURITY_LABEL
>> +	bool "Provide Security Label support for NFSv4 client"
>> +	depends on NFS_V4&&  SECURITY
>> +	help
>> +
>> +	Say Y here if you want enable fine-grained security label attribute
>> +	support for NFS version 4.  Security labels allow security modules like
>> +	SELinux and Smack to label files to facilitate enforcement of their policies.
>> +	Without this an NFSv4 mount will have the same label on each file.
>> +
>> +	If you do not wish to enable fine-grained security labels SELinux or
>> +	Smack policies on NFSv4 files, say N.
>> +
>> +
>> +	  If unsure, say N.
>> +
>>   config ROOT_NFS
>>   	bool "Root file system on NFS"
>>   	depends on NFS_FS=y&&  IP_PNP
>> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
>> index 503b9da..3a282f8 100644
>> --- a/fs/nfsd/Kconfig
>> +++ b/fs/nfsd/Kconfig
>> @@ -79,3 +79,16 @@ config NFSD_V4
>>   	  available from http://linux-nfs.org/.
>>
>>   	  If unsure, say N.
>> +
>> +config NFSD_V4_SECURITY_LABEL
>> +	bool "Provide Security Label support for NFSv4 server"
>> +	depends on NFSD_V4&&  SECURITY
>> +	help
>> +
>> +	Say Y here if you want enable fine-grained security label attribute
>> +	support for NFS version 4.  Security labels allow security modules like
>> +	SELinux and Smack to label files to facilitate enforcement of their policies.
>> +	Without this an NFSv4 mount will have the same label on each file.
>> +
>> +	If you do not wish to enable fine-grained security labels SELinux or
>> +	Smack policies on NFSv4 files, say N.
>> --
>> 1.6.2.5
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

