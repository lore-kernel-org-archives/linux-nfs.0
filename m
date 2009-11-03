From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Fixed compile errors when the mount config file is not
 enabled
Date: Tue, 03 Nov 2009 09:54:52 -0500
Message-ID: <4AF0443C.50503@RedHat.com>
References: <4AE751CE.1050300@RedHat.com> <4AE836F2.7020905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbZKCOyr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2009 09:54:47 -0500
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nA3EsrLO024542
	for <linux-nfs@vger.kernel.org>; Tue, 3 Nov 2009 09:54:53 -0500
In-Reply-To: <4AE836F2.7020905@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delayed response... 

On 10/28/2009 08:20 AM, Peter Staubach wrote:
> Steve Dickson wrote:
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Tue Oct 27 15:47:27 2009 -0400
>>
>>     Added wrappers around the setting of default values
>>     from the config file which will be compiled out
>>     when the config file is not enabled.
>>     
>>     Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> diff --git a/support/include/conffile.h b/support/include/conffile.h
>> index fe23ec2..ce7aa21 100644
>> --- a/support/include/conffile.h
>> +++ b/support/include/conffile.h
>> @@ -76,10 +76,5 @@ static inline void upper2lower(char *str)
>>  		*str++ = c;
>>  }
>>  
>> -/*
>> - * Default Mount options
>> - */
>> -extern unsigned long config_default_vers;
>> -extern unsigned long config_default_proto;
>>  
>>  #endif				/* _CONFFILE_H_ */
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index e651167..d4ecbc9 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -172,6 +172,27 @@ static const unsigned long probe_mnt3_first[] = {
>>  	0,
>>  };
>>  
>> +inline const unsigned int *set_default_proto(void);
>> +#ifdef MOUNT_CONFIG
>> +inline const unsigned int *set_default_proto()
>> +{
>> +	extern unsigned long config_default_proto;
>> +	/*
>> +	 * If the default proto has been set and 
>> +	 * its not TCP, start with UDP
>> +	 */
>> +	if (config_default_proto && config_default_proto != IPPROTO_TCP)
>> +		return probe_udp_first;
>> +
> 
> Shouldn't there be something to account for NFSv4 only being
> supported over TCP and not UDP by specification?  The Linux
> server still supports NFSv4 over UDP, although it is not
> supposed to and should not.  Even if the default transport
> is set to UDP, NFSv4 should always be mounted over TCP.
set_default_proto() is only called from nfs_probe_nfsport() which
figures out what protocol the server supports. With v4 mounts,
that type of probing is not done. Just TCP is used.

steved.

