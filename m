Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:14460 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757937Ab2AKSDJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 13:03:09 -0500
Message-ID: <4F0DCEA8.7040205@parallels.com>
Date: Wed, 11 Jan 2012 22:02:16 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Eric W. Biederman" <ebiederm@xmission.com>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>	<20111214104449.3991.61989.stgit@localhost6.localdomain6>	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com>	<m1pqfkecw0.fsf@fess.ebiederm.org> <4EEF7364.8000407@parallels.com>	<m1vcotigyb.fsf@fess.ebiederm.org> <4F0C150F.1020007@parallels.com>	<m1ehv76v2v.fsf@fess.ebiederm.org> <4F0D5A9E.5030501@parallels.com> <m1sjjm40k8.fsf@fess.ebiederm.org>
In-Reply-To: <m1sjjm40k8.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.01.2012 21:21, Eric W. Biederman пишет:
>>>>> Especially what drives that desire not to have it have a /proc/<pid>/sys
>>>>> directory that reflects the sysctls for a given process.
>>>>>
>>>>
>>>> This is not so important for me, where to access sysctl's. But I'm worrying
>>>> about backward compatibility. IOW, I'm afraid of changing path
>>>> "/proc/sys/sunprc/*" to "/proc/<pid>/sys/sunrpc". This would break a lot of
>>>> user-space programs.
>>>
>>> The part that keeps it all working is by adding a symlink from /proc/sys
>>> to /proc/self/sys.  That technique has worked well for /proc/net, and I
>>> don't expect there will be any problems with /proc/sys either.  It is
>>> possible but is very rare for the introduction of a symlink in a path
>>> to cause problems.
>>>
>>
>> Probably I don't understand you, but as I see it now, symlink to "/proc/self/"
>> is unacceptable because of the following:
>> 1) will be used current context (any) instead of desired one
> (Using the current context is the desirable outcome for existing tools).
>> 1) if CT has other pid namespace - then we just have broken link.
>
> Assuming the process in question is not in the pid namespace available
> to proc then yes you will indeed have a broken link.  But a broken
> link is only a problem for new applications that are doing something strange.
>

I believe, that container is assuming to work in  it's own network and pid 
namespaces.
With your approach, if I'm not mistaken, container's /proc/net and /proc/sys 
tunables will be unaccessible from parent environment. Or I'm wrong here?

> I am proposing treating /proc/sys like /proc/net has already been
> treated.  Aka move have the version of /proc/sys that relative to a
> process be visible at: /proc/<pid>/sys, and with a compat symlink
> from /proc/sys ->  /proc/self/sys.
>
> Just like has already been done with /proc/net.
>

1) On one hand it looks logical, that any nested dentries in /proc are tied to 
pid namespace. But on the other hand we have a lot of tunables in /proc/net, 
/proc/sys, etc. which have nothing with processes or whatever similar.
2) currently /proc processes directories (i.e. /proc/1/, etc) depends on mount 
maker context. But /proc/sys and /proc/net doesn't. This looks weird and 
despondently, from my pow. What do you think about it?

And what do you think about "conteinerization" of /proc contents in the way like 
"sysfs" was done?
Implementing /proc "conteinerization" in this way can give us great flexibility.
For example, /proc/net (and /proc/sys/sunrpc) depends on mount owner net 
namespace, /proc/sysvipc depends on mount owner ipc namespace, etc.
And this approach doesn't break backward compatibility as well.

> Semantically this should be easy to understand, and about as backwards
> compatible as it gets.
>
> Eric


-- 
Best regards,
Stanislav Kinsbursky
