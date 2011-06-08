Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754735Ab1FHLgj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2011 07:36:39 -0400
Message-ID: <4DEF5EAC.9090603@RedHat.com>
Date: Wed, 08 Jun 2011 07:36:12 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Ben Greear <greearb@candelatech.com>
CC: Thomas Haynes <thomas@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: What RPM meets the libgssapi requirement on Fedora?
References: <4DEE57AD.8050408@candelatech.com> <357A5DD9-991B-445B-8CF8-7C0A0B8F54D9@netapp.com> <4DEEF3F6.8090609@candelatech.com>
In-Reply-To: <4DEEF3F6.8090609@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/08/2011 12:00 AM, Ben Greear wrote:
> On 06/07/2011 06:39 PM, Thomas Haynes wrote:
>> On my FC 13 and FC 14 systems, I need to install the following to test NFSv4 XDR code:
>>
>> sudo yum -y install libgssglue-devel
>> sudo yum -y install nfs-utils-lib-devel
Please note, that nfs-utils-lib will be going away in Fedora 15.

The rpm was a combination of two libraries. librpcsecgss and  libnfsidmap.
librpcsecgss is no longer needed now that we have libtirpc so I
broke libnfsidmap out into its own rpm... 

steved.

> 
> Yeah, that works.  I was accidentally using a very ancient
> nfs-utils git tree.

> 
> Thanks,
> Ben
> 
>>
>>
>> On Jun 7, 2011, at 9:54 AM, Ben Greear wrote:
>>
>>> ./configure
>>> ....
>>> checking pkg-config is at least version 0.9.0... yes
>>> checking for RPCSECGSS... yes
>>> checking for GSSAPI... configure: error: Package requirements (libgssapi >= 0.11) were not met:
>>>
>>> No package 'libgssapi' found
>>>
>>> I tried:
>>>
>>> [root@fs3 linux-2.6.38.x64-dbg]# yum install libgssapi-devel
>>> Loaded plugins: presto, refresh-packagekit
>>> Setting up Install Process
>>> Nothing to do
>>>
>>> This is on Fedora 13...
>>>
>>> Thanks,
>>> Ben
>>>
>>> -- 
>>> Ben Greear <greearb@candelatech.com <mailto:greearb@candelatech.com>>
>>> Candela Technologies Inc http://www.candelatech.com
>>>
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org <mailto:majordomo@vger.kernel.org>
>>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
> 
> 
