Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42723 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357AbcFUPyB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2016 11:54:01 -0400
Subject: Re: [PATCH 1/1 v2] systemd: Only start the gssd daemons when they are
 enabled
To: Chuck Lever <chuck.lever@oracle.com>
References: <1466520807-4340-1-git-send-email-steved@redhat.com>
 <09ECB137-8EC4-4713-B5F4-44D0405B2700@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <c21d7a5d-853f-1722-53b4-99f66f263d74@RedHat.com>
Date: Tue, 21 Jun 2016 11:43:11 -0400
MIME-Version: 1.0
In-Reply-To: <09ECB137-8EC4-4713-B5F4-44D0405B2700@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/21/2016 11:26 AM, Chuck Lever wrote:
> 
>> On Jun 21, 2016, at 10:53 AM, Steve Dickson <steved@redhat.com> wrote:
>>
>> When Kerberos is enabled, the /etc/krb5.keytab exists
>> which causes the both gssd daemons to start, automatically.
>>
>> With rpc.gssd running, on all NFS mounts, an upcall
>> is done to get GSS security context for SETCLIENTID procedure.
>>
>> When Kerberos is not configured for NFS, meaning
>> there is no host/hostname@REALM principal in
>> the key tab, those upcalls always fall causing
>> the mount to hang for several seconds.
> 
> What is the root cause of the temporary hang?
All the upcalls to rpc.gssd... I think there are
three for every mount.

> 
> When you say "the upcall fails" do you mean there is
> no reply, or that there is a negative reply after a
> delay, or there is an immediate negative reply?
Good point.. the upcalls did not fail, they
just received negative replies. 

steved.

> 
> 
>> This patch added an [Install] section to both
>> services so the services can be enable and disable.
>> The README was also updated.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> systemd/README              | 14 +++++---------
>> systemd/rpc-gssd.service    |  6 ++++++
>> systemd/rpc-svcgssd.service |  7 +++++++
>> 3 files changed, 18 insertions(+), 9 deletions(-)
>>
>> diff --git a/systemd/README b/systemd/README
>> index 7c43df8..58dae42 100644
>> --- a/systemd/README
>> +++ b/systemd/README
>> @@ -59,13 +59,9 @@ information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
>> It is run once by nfs-config.service.
>>
>> rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
>> -is present.
>> -If a site needs this file present but does not want the gss daemons
>> -running, it should create
>> -   /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
>> -and
>> -   /etc/systemd/system/rpc-svcgssd.service.d/01-disable.conf
>> +is present.  If a site needs this file present but does not want 
>> +the gss daemons running, they can be disabled by doing
>> +   
>> +   systemctl disable rpc-gssd
>> +   systemctl disable rpc-svcgssd
>>
>> -containing
>> -   [Unit]
>> -   ConditionNull=false
>> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
>> index d4a3819..681f26a 100644
>> --- a/systemd/rpc-gssd.service
>> +++ b/systemd/rpc-gssd.service
>> @@ -17,3 +17,9 @@ EnvironmentFile=-/run/sysconfig/nfs-utils
>>
>> Type=forking
>> ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
>> +
>> +# Only start if the service is enabled 
>> +# and /etc/krb5.keytab exists 
>> +[Install]
>> +WantedBy=multi-user.target
>> +
>> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
>> index 41177b6..4433ed7 100644
>> --- a/systemd/rpc-svcgssd.service
>> +++ b/systemd/rpc-svcgssd.service
>> @@ -18,3 +18,10 @@ After=nfs-config.service
>> EnvironmentFile=-/run/sysconfig/nfs-utils
>> Type=forking
>> ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
>> +
>> +# Only start if the service is enabled 
>> +# and /etc/krb5.keytab exists 
>> +# and when gss-proxy is not runing
>> +[Install]
>> +WantedBy=multi-user.target
>> +
>> -- 
>> 2.5.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
