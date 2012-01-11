Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38504 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756735Ab2AKJsX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 04:48:23 -0500
Message-ID: <4F0D5A9E.5030501@parallels.com>
Date: Wed, 11 Jan 2012 13:47:10 +0400
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
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>	<20111214104449.3991.61989.stgit@localhost6.localdomain6>	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com>	<m1pqfkecw0.fsf@fess.ebiederm.org> <4EEF7364.8000407@parallels.com>	<m1vcotigyb.fsf@fess.ebiederm.org> <4F0C150F.1020007@parallels.com> <m1ehv76v2v.fsf@fess.ebiederm.org>
In-Reply-To: <m1ehv76v2v.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.01.2012 02:39, Eric W. Biederman пишет:
> Stanislav Kinsbursky<skinsbursky@parallels.com>  writes:
>
>> 03.01.2012 07:49, Eric W. Biederman пишет:
>>> Stanislav Kinsbursky<skinsbursky@parallels.com>   writes:
>>>
>>>> 19.12.2011 20:37, Eric W. Biederman пишет:
>>>>> Stanislav Kinsbursky<skinsbursky@parallels.com>    writes:
>>>>>
>>>>> Doing that independently of the rest of the sysctls is pretty horrible
>>>>> and confusing to users.   What I am planning might suit your needs and
>>>>> if not we need to talk some more about how to get the vfs to do
>>>>> something reasonable.
>>>>>
>>>>
>>>> Ok, Eric. Would be glad to discuss your sysctls plans.
>>>> But actually you already know my needs: I would like to make sysctls work in the
>>>> way like sysfs does: i.e. content of files depends on mount maker -
>>>> not viewer.
>>>
>>> What drives the desire to have sysctls depend on the mount maker?
>>
>> Because we can (will, actually) have nested fs root's for containers. IOW,
>> container's root will be accessible from it's creator context. And I want to
>> tune container's fs from creators context.
>
> Tuning the child context from the parent context is an entirely
> reasonable thing to do.  To affect a namespace that is not yours
> the requirement is simply that we don't use current to lookup the
> sysctl.  So what I am proposing should work for your case.
>

Could you explain, what are you proposing?
I still don't know any details about it.

>>> Especially what drives that desire not to have it have a /proc/<pid>/sys
>>> directory that reflects the sysctls for a given process.
>>>
>>
>> This is not so important for me, where to access sysctl's. But I'm worrying
>> about backward compatibility. IOW, I'm afraid of changing path
>> "/proc/sys/sunprc/*" to "/proc/<pid>/sys/sunrpc". This would break a lot of
>> user-space programs.
>
> The part that keeps it all working is by adding a symlink from /proc/sys
> to /proc/self/sys.  That technique has worked well for /proc/net, and I
> don't expect there will be any problems with /proc/sys either.  It is
> possible but is very rare for the introduction of a symlink in a path
> to cause problems.
>

Probably I don't understand you, but as I see it now, symlink to "/proc/self/" 
is unacceptable because of the following:
1) will be used current context (any) instead of desired one
1) if CT has other pid namespace - then we just have broken link.

> Eric
>


-- 
Best regards,
Stanislav Kinsbursky
