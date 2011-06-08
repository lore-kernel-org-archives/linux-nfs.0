Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38301 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822Ab1FHEA5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 00:00:57 -0400
Message-ID: <4DEEF3F6.8090609@candelatech.com>
Date: Tue, 07 Jun 2011 21:00:54 -0700
From: Ben Greear <greearb@candelatech.com>
To: Thomas Haynes <thomas@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: What RPM meets the libgssapi requirement on Fedora?
References: <4DEE57AD.8050408@candelatech.com> <357A5DD9-991B-445B-8CF8-7C0A0B8F54D9@netapp.com>
In-Reply-To: <357A5DD9-991B-445B-8CF8-7C0A0B8F54D9@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/07/2011 06:39 PM, Thomas Haynes wrote:
> On my FC 13 and FC 14 systems, I need to install the following to test NFSv4 XDR code:
>
> sudo yum -y install libgssglue-devel
> sudo yum -y install nfs-utils-lib-devel

Yeah, that works.  I was accidentally using a very ancient
nfs-utils git tree.

Thanks,
Ben

>
>
> On Jun 7, 2011, at 9:54 AM, Ben Greear wrote:
>
>> ./configure
>> ....
>> checking pkg-config is at least version 0.9.0... yes
>> checking for RPCSECGSS... yes
>> checking for GSSAPI... configure: error: Package requirements (libgssapi >= 0.11) were not met:
>>
>> No package 'libgssapi' found
>>
>> I tried:
>>
>> [root@fs3 linux-2.6.38.x64-dbg]# yum install libgssapi-devel
>> Loaded plugins: presto, refresh-packagekit
>> Setting up Install Process
>> Nothing to do
>>
>> This is on Fedora 13...
>>
>> Thanks,
>> Ben
>>
>> --
>> Ben Greear <greearb@candelatech.com <mailto:greearb@candelatech.com>>
>> Candela Technologies Inc http://www.candelatech.com
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org <mailto:majordomo@vger.kernel.org>
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
