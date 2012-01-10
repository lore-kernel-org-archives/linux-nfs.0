Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:16585 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913Ab2AJKjP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 05:39:15 -0500
Message-ID: <4F0C154E.7040503@parallels.com>
Date: Tue, 10 Jan 2012 14:39:10 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RFC: rpcbind start/stop scripts affects all nested pid namespaces
References: <4EF86DAF.9040804@parallels.com> <4F03177C.1070803@RedHat.com>
In-Reply-To: <4F03177C.1070803@RedHat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for notice, Steve.
Will take it into account.

03.01.2012 18:58, Steve Dickson пишет:
> Please note, the systemV init scripts are  being replaced with
> systemd scripts, at least with Fedora 16 and beyond...
>
> See /lib/systemd/system/rpcbind.service on Fedora 16 for
> the new way rpcbind is started...
>
> steved.
>
> On 12/26/2011 07:50 AM, Stanislav Kinsbursky wrote:
>> When trying to start and stop rpcbind in different pid namespaces I've noticed, that rpcbind stop command kills all rpcbind processes in nested pid namespaces.
>> This is caused by "/sbin/pidof rpcbind" call on rpcbind start. IOW file "/var/run/rpcbind.pid" contains pids of all nested rpcbind processes.
>> The simplest solution I see for now is to add "-c" options to "pidof" command. But I'm not sure about quality of solution and probably "killall5" have to be updated with new option to work only in current pid namespace.
>> Would be glad to hear any opinion about this problem.
>>


-- 
Best regards,
Stanislav Kinsbursky
